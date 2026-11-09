# --- Окно настроек ---
$script:setXaml = Get-Content -LiteralPath (Join-Path $script:srcDir 'SettingsWindow.xaml') -Raw -Encoding UTF8

# Список приложений: строка с названием и переключателем
function Fill-List {
    if (-not $script:setWin) { return }
    $bc = New-Object Windows.Media.BrushConverter
    $f = $script:SetFilter.Text.Trim().ToLower()
    $script:SetList.Children.Clear()
    $switchStyle = $script:setWin.FindResource('Switch')
    $shown = 0
    foreach ($a in ($script:apps.Values | Sort-Object Name)) {
        if ($f -and -not ($a.Name.ToLower().Contains($f) -or $a.Id.ToLower().Contains($f))) { continue }
        $shown++
        $row = New-Object Windows.Controls.Border
        $row.Background = $bc.ConvertFromString('#FF2C2C2E')
        $row.CornerRadius = New-Object Windows.CornerRadius(10)
        $row.Padding = New-Object Windows.Thickness(12, 8, 12, 8)
        $row.Margin = New-Object Windows.Thickness(0, 0, 0, 6)

        $g = New-Object Windows.Controls.Grid
        $c1 = New-Object Windows.Controls.ColumnDefinition; $c1.Width = New-Object Windows.GridLength(1, [Windows.GridUnitType]::Star)
        $c2 = New-Object Windows.Controls.ColumnDefinition; $c2.Width = [Windows.GridLength]::Auto
        [void]$g.ColumnDefinitions.Add($c1); [void]$g.ColumnDefinitions.Add($c2)

        $sp = New-Object Windows.Controls.StackPanel
        $sp.Margin = New-Object Windows.Thickness(0, 0, 12, 0)
        $sp.VerticalAlignment = 'Center'
        $t1 = New-Object Windows.Controls.TextBlock
        $t1.Text = $a.Name; $t1.FontSize = 13; $t1.Foreground = [Windows.Media.Brushes]::White
        $t1.TextTrimming = 'CharacterEllipsis'
        $t2 = New-Object Windows.Controls.TextBlock
        $t2.Text = $a.Id; $t2.FontSize = 11; $t2.Foreground = $bc.ConvertFromString('#FF9A9AA0')
        $t2.TextTrimming = 'CharacterEllipsis'
        [void]$sp.Children.Add($t1); [void]$sp.Children.Add($t2)

        $tg = New-Object Windows.Controls.Primitives.ToggleButton
        $tg.Style = $switchStyle
        $tg.Tag = $a.Id
        $tg.IsChecked = $a.Enabled
        $tg.Add_Click({ $script:apps[[string]$this.Tag].Enabled = [bool]$this.IsChecked; Apply-Banners })
        [Windows.Controls.Grid]::SetColumn($tg, 1)

        [void]$g.Children.Add($sp); [void]$g.Children.Add($tg)
        $row.Child = $g
        [void]$script:SetList.Children.Add($row)
    }
    if ($shown -eq 0) {
        $e = New-Object Windows.Controls.TextBlock
        $e.Text = 'Ничего не найдено'
        $e.Foreground = $bc.ConvertFromString('#FF9A9AA0')
        $e.Margin = New-Object Windows.Thickness(4, 8, 0, 0)
        [void]$script:SetList.Children.Add($e)
    }
}

# Вкладки: показываем одну страницу, остальные прячем
function Show-SettingsPage($name) {
    foreach ($p in 'PageGeneral', 'PageNotif', 'PageClip', 'PageApps') {
        $el = $script:setWin.FindName($p)
        if ($el) { $el.Visibility = $(if ($p -eq $name) { 'Visible' } else { 'Collapsed' }) }
    }
}

# Пояснение под выбором действия островка справа
function Update-ActionHint {
    $h = $script:setWin.FindName('ActHint')
    if (-not $h) { return }
    if ($script:screenAction -eq 'dnd') {
        $h.Text = 'Клик по островку включает и выключает «Не беспокоить». Значок светится ярче, когда режим включён. В раскрытом острове кнопки 🌙 и 📷 остаются обе.'
    } else {
        $h.Text = 'Клик делает снимок всего экрана. Файл сохраняется в «Изображения\DynamicIsland» и сразу копируется в буфер обмена. В раскрытом острове кнопки 🌙 и 📷 остаются обе.'
    }
}

function Open-Settings {
    if ($script:setWin) { $script:setWin.Activate(); return }
    Discover-Apps
    $w = [Windows.Markup.XamlReader]::Parse($script:setXaml)
    $script:setWin = $w
    $script:SetList = $w.FindName('AppList')
    $script:SetFilter = $w.FindName('Filter')

    # --- Шапка: источник уведомлений ---
    $srcNames = @{ listener = 'системный доступ к уведомлениям'; db = 'база уведомлений Windows'; uia = 'перехват всплывающих окон (запасной режим)'; none = 'недоступны' }
    $w.FindName('SrcText').Text = 'Источник уведомлений: ' + $srcNames[$script:source]

    # --- Вкладки ---
    foreach ($n in 'TabGeneral', 'TabNotif', 'TabClip', 'TabApps') {
        $w.FindName($n).Add_Checked({ Show-SettingsPage ([string]$this.Tag) })
    }

    # --- Общие: положение ---
    $w.FindName('PosCenter').IsChecked = ($script:posMode -eq 'center')
    $w.FindName('PosLeft').IsChecked = ($script:posMode -ne 'center')
    foreach ($n in 'PosCenter', 'PosLeft') {
        $w.FindName($n).Add_Checked({
            $script:posMode = [string]$this.Tag
            Save-Settings
            Update-Position
        })
    }
    $lc = $w.FindName('LockChk')
    $lc.IsChecked = $script:dockLocked
    $lc.Add_Click({ $script:dockLocked = [bool]$this.IsChecked; Save-Settings; Update-Position })
    $gc = $w.FindName('GameChk')
    $gc.IsChecked = $script:hideInGames
    $gc.Add_Click({ $script:hideInGames = [bool]$this.IsChecked; Save-Settings; Update-Position })

    # --- Общие: раскрытый остров ---
    $sst = $w.FindName('ShowStatsChk')
    $sst.IsChecked = $script:showStats
    $sst.Add_Click({ $script:showStats = [bool]$this.IsChecked; Save-Settings; $script:BigR.Visibility = $(if ($script:showStats) { 'Visible' } else { 'Collapsed' }) })
    $smc = $w.FindName('ShowMusicChk')
    $smc.IsChecked = $script:showMusic
    $smc.Add_Click({ $script:showMusic = [bool]$this.IsChecked; Save-Settings })

    # --- Общие: действие островка справа (скриншот или «Не беспокоить») ---
    $w.FindName('ActShot').IsChecked = ($script:screenAction -ne 'dnd')
    $w.FindName('ActDnd').IsChecked = ($script:screenAction -eq 'dnd')
    Update-ActionHint
    foreach ($n in 'ActShot', 'ActDnd') {
        $w.FindName($n).Add_Checked({
            $script:screenAction = [string]$this.Tag
            Save-Settings
            Apply-ScreenAction
            Update-ActionHint
        })
    }

    # --- Уведомления ---
    $snt = $w.FindName('ShowNotifTextChk')
    $snt.IsChecked = $script:showNotifText
    $snt.Add_Click({ $script:showNotifText = [bool]$this.IsChecked; Save-Settings })
    $dc = $w.FindName('DndChk')
    $dc.IsChecked = $script:dnd
    $dc.Add_Click({ Set-Dnd ([bool]$this.IsChecked) 0 })
    $hide = $w.FindName('HideChk')
    $hide.IsChecked = $script:hideBanners
    if ($script:source -ne 'listener' -and $script:source -ne 'db') {
        $hide.IsEnabled = $false
        $w.FindName('HideDesc').Text = 'Недоступно в этом режиме: нужен системный доступ к уведомлениям или база Windows.'
    }
    $hide.Add_Click({ $script:hideBanners = [bool]$this.IsChecked; Apply-Banners })
    $w.FindName('BtnTest').Add_Click({
        Enqueue-Notif ([pscustomobject]@{ App = 'Dynamic Island'; Title = 'Тестовое уведомление'; Body = 'Если вы это видите, остров работает'; Icon = $null; Key = ('t' + (Get-Date).Ticks) })
    })
    $w.FindName('BtnRestore').Add_Click({
        $script:hideBanners = $false
        foreach ($k in @($script:backup.Keys)) { Set-Banner $k $false }
        Save-Settings
        $h = $script:setWin.FindName('HideChk'); $h.IsChecked = $false
    })

    # --- Буфер обмена ---
    $cm = $w.FindName('CopyMsgChk')
    $cm.IsChecked = $script:copyMsgs
    $cm.Add_Click({ $script:copyMsgs = [bool]$this.IsChecked; Save-Settings })
    $cc = $w.FindName('ClipChk')
    $cc.IsChecked = $script:clipPersist
    $cc.Add_Click({ $script:clipPersist = [bool]$this.IsChecked; Save-Settings; Save-Clips })
    $w.FindName('BtnClipClear').Add_Click({ $script:clips.Clear(); Save-Clips; if ($script:clipOpen) { Fill-Clips } })

    # --- Приложения ---
    $script:SetFilter.Add_TextChanged({ Fill-List })
    $w.FindName('BtnAll').Add_Click({ foreach ($a in @($script:apps.Values)) { $a.Enabled = $true }; Apply-Banners; Fill-List })
    $w.FindName('BtnNone').Add_Click({ foreach ($a in @($script:apps.Values)) { $a.Enabled = $false }; Apply-Banners; Fill-List })

    $w.Add_Closed({ $script:setWin = $null })
    Fill-List
    $w.Show()
}
