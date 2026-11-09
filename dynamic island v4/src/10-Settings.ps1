# --- Настройки ---
$script:source = ''
$script:cfgDir = Join-Path $env:APPDATA 'DynamicIsland'
$script:cfgFile = Join-Path $script:cfgDir 'settings.json'
$script:apps = @{}
$script:hideBanners = $false
$script:posMode = 'left'
$script:dockLocked = $false
$script:wantLeft = $false
$script:dock = 'top'
$script:dockBusy = $false
$script:hideInGames = $true
$script:clipPersist = $true
$script:copyMsgs = $true
$script:showNotifText = $true
$script:showStats = $true
$script:showMusic = $true
$script:screenAction = 'screenshot'
$script:clipFirst = $true
$script:pasteHeld = $false
$script:lastClipText = $null
$script:clipOpen = $false
$script:dndOpen = $false
$script:clipPaused = $false
$script:clipConfirm = $false
$script:clipSeq = 0
$script:clips = New-Object System.Collections.ArrayList
$script:gameHidden = $false
$script:backup = @{}
$script:regBase = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings'
$script:firstRun = -not (Test-Path -LiteralPath $script:cfgFile)
$script:setWin = $null

function Save-Settings {
    try {
        if (-not (Test-Path -LiteralPath $script:cfgDir)) { [void](New-Item -ItemType Directory -Path $script:cfgDir) }
        $o = @{
            hideBanners   = $script:hideBanners
            posMode       = $script:posMode
            dockLocked    = $script:dockLocked
            hideInGames   = $script:hideInGames
            clipPersist   = $script:clipPersist
            copyMsgs      = $script:copyMsgs
            showNotifText = $script:showNotifText
            showStats     = $script:showStats
            showMusic     = $script:showMusic
            screenAction  = $script:screenAction
            apps          = @($script:apps.Values | ForEach-Object { @{ id = $_.Id; name = $_.Name; enabled = $_.Enabled } })
            backup        = @($script:backup.Keys | ForEach-Object { @{ id = $_; value = "$($script:backup[$_])" } })
        }
        ($o | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $script:cfgFile -Encoding UTF8
    } catch {}
}

function Load-Settings {
    try {
        if (-not (Test-Path -LiteralPath $script:cfgFile)) { return }
        $o = Get-Content -LiteralPath $script:cfgFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $script:hideBanners = [bool]$o.hideBanners
        if ($null -ne $o.copyMsgs) { $script:copyMsgs = [bool]$o.copyMsgs }
        if ($null -ne $o.clipPersist) { $script:clipPersist = [bool]$o.clipPersist }
        if ($null -ne $o.hideInGames) { $script:hideInGames = [bool]$o.hideInGames }
        if ($null -ne $o.dockLocked) { $script:dockLocked = [bool]$o.dockLocked }
        if ($null -ne $o.showNotifText) { $script:showNotifText = [bool]$o.showNotifText }
        if ($null -ne $o.showStats) { $script:showStats = [bool]$o.showStats }
        if ($null -ne $o.showMusic) { $script:showMusic = [bool]$o.showMusic }
        if ($o.screenAction -eq 'screenshot' -or $o.screenAction -eq 'dnd') { $script:screenAction = [string]$o.screenAction }
        if ($o.posMode -eq 'center' -or $o.posMode -eq 'left') { $script:posMode = [string]$o.posMode }
        foreach ($x in @($o.apps)) { if ($x.id) { $script:apps[[string]$x.id] = [pscustomobject]@{ Id = [string]$x.id; Name = [string]$x.name; Enabled = [bool]$x.enabled } } }
        foreach ($x in @($o.backup)) { if ($x.id) { $script:backup[[string]$x.id] = [string]$x.value } }
    } catch {}
}

function Get-AppName($id) {
    if (-not $id) { return 'Уведомление' }
    $n = ($id -split '!')[0]
    $n = ($n -split '\\')[0]
    $parts = @($n -split '[./]' | Where-Object { $_ })
    if ($parts.Count -gt 0) { return $parts[-1] }
    return $id
}

function Set-Banner($id, $hide) {
    if ($id -match '[/]') { return }
    $path = "$($script:regBase)\$id"
    try {
        if ($hide) {
            if (-not $script:backup.ContainsKey($id)) {
                $cur = (Get-ItemProperty -LiteralPath $path -Name ShowBanner -ErrorAction SilentlyContinue).ShowBanner
                $script:backup[$id] = $(if ($null -eq $cur) { 'none' } else { "$cur" })
            }
            if (-not (Test-Path -LiteralPath $path)) { [void](New-Item -Path $path -Force) }
            Set-ItemProperty -LiteralPath $path -Name ShowBanner -Value 0 -Type DWord
        } elseif ($script:backup.ContainsKey($id)) {
            if ($script:backup[$id] -eq 'none') { Remove-ItemProperty -LiteralPath $path -Name ShowBanner -ErrorAction SilentlyContinue }
            else { Set-ItemProperty -LiteralPath $path -Name ShowBanner -Value ([int]$script:backup[$id]) -Type DWord }
            [void]$script:backup.Remove($id)
        }
    } catch {}
}

function Apply-Banners {
    $canHide = $script:hideBanners -and ($script:source -eq 'listener' -or $script:source -eq 'db')
    foreach ($a in @($script:apps.Values)) { Set-Banner $a.Id ($canHide -and $a.Enabled) }
    if (-not $canHide) { foreach ($k in @($script:backup.Keys)) { Set-Banner $k $false } }
    Save-Settings
}

function Discover-Apps {
    try {
        foreach ($k in (Get-ChildItem -LiteralPath $script:regBase -ErrorAction Stop)) {
            $id = $k.PSChildName
            if (-not $script:apps.ContainsKey($id)) { $script:apps[$id] = [pscustomobject]@{ Id = $id; Name = (Get-AppName $id); Enabled = $true } }
        }
    } catch {}
}

function Register-App($id, $name) {
    if (-not $script:apps.ContainsKey($id)) {
        $nm = $(if ($name) { $name } else { Get-AppName $id })
        $script:apps[$id] = [pscustomobject]@{ Id = $id; Name = $nm; Enabled = $true }
        Apply-Banners
    } elseif ($name -and $script:apps[$id].Name -ne $name) { $script:apps[$id].Name = $name }
    return $script:apps[$id]
}

function Enqueue-Notif($n) {
    if ($script:dnd) { $script:missed++; return }
    $script:queue.Enqueue($n)
    if ($script:pop -eq 'none') { Show-Notif ($script:queue.Dequeue()) }
}

function Show-Notif($n) {
    $script:NotifApp.Text = $n.App
    $script:NotifTitle.Text = $n.Title
    $script:NotifBody.Text = $n.Body
    if ($n.Icon) { $script:NotifIcon.ImageSource = $n.Icon }
    Start-Pop 'notif' $n.Key 5
}

function Handle-Incoming($id, $name, $title, $body, $icon, $key) {
    $enabled = $true
    if ($id) {
        $a = Register-App $id $name
        $enabled = $a.Enabled
        if (-not $name) { $name = $a.Name }
    } elseif ($name) {
        $m = $script:apps.Values | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($m) { $enabled = $m.Enabled }
    }
    if (-not $name) { $name = 'Уведомление' }
    if (-not $enabled) { return }
    Enqueue-Notif ([pscustomobject]@{ App = $name; Title = $title; Body = $body; Icon = $icon; Key = $key })
}

