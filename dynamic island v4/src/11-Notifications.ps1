# --- Источники уведомлений ---
Load-Settings
Discover-Apps

try {
    [void][Windows.UI.Notifications.Management.UserNotificationListener, Windows.UI.Notifications.Management, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.Management.UserNotificationListenerAccessStatus, Windows.UI.Notifications.Management, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.UserNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.NotificationKinds, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.KnownNotificationBindings, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.Foundation.Size, Windows.Foundation, ContentType = WindowsRuntime]
    
    $l = [Windows.UI.Notifications.Management.UserNotificationListener]::Current
    $st = Await ($l.RequestAccessAsync()) ([Windows.UI.Notifications.Management.UserNotificationListenerAccessStatus])
    if ("$st" -eq 'Allowed') { $script:listener = $l; $script:source = 'listener' }
} catch {}

$script:cs = Get-Content -LiteralPath (Join-Path $script:srcDir 'NotifDb.cs') -Raw -Encoding UTF8

$script:dbOrig = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Notifications\wpndatabase.db'
$script:dbTmp = Join-Path $env:TEMP 'di_wpn.db'
$script:dbPath = $script:dbOrig; $script:dbFlags = 1; $script:dbCopy = $false; $script:dbLast = 0

function Copy-Db {
    try {
        Copy-Item -LiteralPath $script:dbOrig -Destination $script:dbTmp -Force
        if (Test-Path -LiteralPath "$($script:dbOrig)-wal") { Copy-Item -LiteralPath "$($script:dbOrig)-wal" -Destination "$($script:dbTmp)-wal" -Force }
        Remove-Item -LiteralPath "$($script:dbTmp)-shm" -Force -ErrorAction SilentlyContinue
    } catch {}
}

if (-not $script:source) {
    try {
        Add-Type -TypeDefinition $script:cs -Language CSharp
        $err = ''
        $m = [WpnDb]::MaxOrder($script:dbPath, 1, [ref]$err)
        if ($m -lt 0) {
            Copy-Db
            $script:dbPath = $script:dbTmp; $script:dbFlags = 2; $script:dbCopy = $true
            $m = [WpnDb]::MaxOrder($script:dbPath, 2, [ref]$err)
        }
        if ($m -ge 0) { $script:dbLast = $m; $script:source = 'db' }
    } catch {}
}

if (-not $script:source) {
    try {
        $script:uiaRoot = [Windows.Automation.AutomationElement]::RootElement
        $script:uiaCond = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ClassNameProperty, 'Windows.UI.Core.CoreWindow')
        $script:uiaText = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ControlTypeProperty, [Windows.Automation.ControlType]::Text)
        $script:source = 'uia'
    } catch { $script:source = 'none' }
}

if ($script:firstRun -and ($script:source -eq 'listener' -or $script:source -eq 'db')) { $script:hideBanners = $true }
Apply-Banners

function Poll-Notifications {
    if (-not $script:showNotifText) { return }
    if ($script:source -eq 'listener') {
        try {
            $list = Await ($script:listener.GetNotificationsAsync([Windows.UI.Notifications.NotificationKinds]::Toast)) ([System.Collections.Generic.IReadOnlyList[Windows.UI.Notifications.UserNotification]])
            if (-not $list) { return }
            foreach ($un in $list) {
                $id = [uint32]$un.Id
                if ($script:seen.Contains($id)) { continue }
                [void]$script:seen.Add($id)
                if ($script:firstScan) { continue }
                $b = $un.Notification.Visual.GetBinding([Windows.UI.Notifications.KnownNotificationBindings]::ToastGeneric)
                $texts = @($b.GetTextElements() | ForEach-Object { $_.Text })
                $icon = $null
                try { $icon = Load-Stream ($un.AppInfo.DisplayInfo.GetLogo([Windows.Foundation.Size]::new(48, 48))) } catch {}
                Handle-Incoming $un.AppInfo.AppUserModelId $un.AppInfo.DisplayInfo.DisplayName $texts[0] (($texts | Select-Object -Skip 1) -join ' ') $icon "n$id"
            }
            $script:firstScan = $false
        } catch {}
    }
    elseif ($script:source -eq 'db') {
        try {
            if ($script:dbCopy) { Copy-Db }
            $err = ''
            $rows = [WpnDb]::ReadAfter($script:dbPath, $script:dbLast, $script:dbFlags, [ref]$err)
            foreach ($r in $rows) {
                if ($r.Order -gt $script:dbLast) { $script:dbLast = $r.Order }
                if ($r.Type -ne 'toast' -or -not $r.Payload) { continue }
                try {
                    $xml = New-Object Xml.XmlDocument
                    $xml.LoadXml($r.Payload.Trim())
                    $texts = @($xml.SelectNodes('//binding/text') | Where-Object { $_.GetAttribute('placement') -ne 'attribution' } | ForEach-Object { $_.InnerText } | Where-Object { $_ })
                    if ($texts.Count -eq 0) { continue }
                    $icon = $null
                    try {
                        $img = $xml.SelectSingleNode("//binding/image[@placement='appLogoOverride']")
                        if ($img) {
                            $src = $img.GetAttribute('src')
                            if ($src -match '^file:') { $src = ([Uri]$src).LocalPath }
                            if ($src -and (Test-Path -LiteralPath $src)) {
                                $bmp = New-Object Windows.Media.Imaging.BitmapImage
                                $bmp.BeginInit(); $bmp.UriSource = [Uri]$src; $bmp.CacheOption = 'OnLoad'; $bmp.EndInit(); $bmp.Freeze()
                                $icon = $bmp
                            }
                        }
                    } catch {}
                    Handle-Incoming $r.AppId $null $texts[0] (($texts | Select-Object -Skip 1) -join ' ') $icon "d$($r.Order)"
                } catch {}
            }
        } catch {}
    }
    elseif ($script:source -eq 'uia') {
        try {
            $now = Get-Date
            foreach ($k in @($script:uiaSeen.Keys)) { if (($now - $script:uiaSeen[$k]).TotalSeconds -gt 15) { $script:uiaSeen.Remove($k) } }
            $wins = $script:uiaRoot.FindAll([Windows.Automation.TreeScope]::Children, $script:uiaCond)
            foreach ($w in $wins) {
                if ($w.Current.Name -notmatch 'уведомл|notification') { continue }
                $texts = @($w.FindAll([Windows.Automation.TreeScope]::Descendants, $script:uiaText) | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
                if ($texts.Count -eq 0) { continue }
                $key = $texts -join '|'
                if ($script:uiaSeen.ContainsKey($key)) { continue }
                $script:uiaSeen[$key] = $now
                Handle-Incoming $null $texts[0] $(if ($texts.Count -gt 1) { $texts[1] } else { '' }) (($texts | Select-Object -Skip 2) -join ' ') $null "u$key"
            }
        } catch {}
    }
}

