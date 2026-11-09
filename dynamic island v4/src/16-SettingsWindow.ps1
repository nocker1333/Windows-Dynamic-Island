# --- Окно настроек ---
$script:setXaml = Get-Content -LiteralPath (Join-Path $script:srcDir 'SettingsWindow.xaml') -Raw -Encoding UTF8

function Fill-List {
    if (-not $script:setWin) { return }
    $f = $script:SetFilter.Text.Trim().ToLower()
    $script:SetList.Children.Clear()
    foreach ($a in ($script:apps.Values | Sort-Object Name)) {
        if ($f -and -not ($a.Name.ToLower().Contains($f) -or $a.Id.ToLower().Contains($f))) { continue }
        $cb = New-Object Windows.Controls.CheckBox
        $cb.Content = "$($a.Name)   ($($a.Id))"
        $cb.Tag = $a.Id
        $cb.IsChecked = $a.Enabled
        $cb.Margin = '0,3,0,3'
        $cb.Foreground = [Windows.Media.Brushes]::White
        $cb.Add_Click({ $script:apps[[string]$this.Tag].Enabled = [bool]$this.IsChecked; Apply-Banners })
        [void]$script:SetList.Children.Add($cb)
    }
}

function Open-Settings {
    if ($script:setWin) { $script:setWin.Activate(); return }
    Discover-Apps
    $w = [Windows.Markup.XamlReader]::Parse($script:setXaml)
    $script:setWin = $w
    $script:SetList = $w.FindName('AppList')
    $script:SetFilter = $w.FindName('Filter')
    $hide = $w.FindName('HideChk')
    $srcNames = @{ listener = 'системный доступ к уведомлениям'; db = 'база уведомлений Windows'; uia = 'перехват всплывающих окон (запасной режим)'; none = 'недоступны' }
    $w.FindName('SrcText').Text = 'Источник уведомлений: ' + $srcNames[$script:source]
    $hide.IsChecked = $script:hideBanners
    if ($script:source -ne 'listener' -and $script:source -ne 'db') {
        $hide.IsEnabled = $false
        $hide.Content = $hide.Content + ' (недоступно в этом режиме)'
    }
    $dc = $w.FindName('DndChk')
    $dc.IsChecked = $script:dnd
    $dc.Add_Click({ Set-Dnd ([bool]$this.IsChecked) 0 })
    $lc = $w.FindName('LockChk')
    $lc.IsChecked = $script:dockLocked
    $lc.Add_Click({ $script:dockLocked = [bool]$this.IsChecked; Save-Settings; Update-Position })
    $cm = $w.FindName('CopyMsgChk')
    $cm.IsChecked = $script:copyMsgs
    $cm.Add_Click({ $script:copyMsgs = [bool]$this.IsChecked; Save-Settings })
    $snt = $w.FindName('ShowNotifTextChk')
    $snt.IsChecked = $script:showNotifText
    $snt.Add_Click({ $script:showNotifText = [bool]$this.IsChecked; Save-Settings })
    $sst = $w.FindName('ShowStatsChk')
    $sst.IsChecked = $script:showStats
    $sst.Add_Click({ $script:showStats = [bool]$this.IsChecked; Save-Settings; $script:BigR.Visibility = $(if ($script:showStats) { 'Visible' } else { 'Collapsed' }) })
    $smc = $w.FindName('ShowMusicChk')
    $smc.IsChecked = $script:showMusic
    $smc.Add_Click({ $script:showMusic = [bool]$this.IsChecked; Save-Settings })
    $cc = $w.FindName('ClipChk')
    $cc.IsChecked = $script:clipPersist
    $cc.Add_Click({ $script:clipPersist = [bool]$this.IsChecked; Save-Settings; Save-Clips })
    $w.FindName('BtnClipClear').Add_Click({ $script:clips.Clear(); Save-Clips; if ($script:clipOpen) { Fill-Clips } })
    $gc = $w.FindName('GameChk')
    $gc.IsChecked = $script:hideInGames
    $gc.Add_Click({ $script:hideInGames = [bool]$this.IsChecked; Save-Settings; Update-Position })
    $pos = $w.FindName('PosBox')
    $pos.SelectedIndex = $(if ($script:posMode -eq 'center') { 0 } else { 1 })
    $pos.Add_SelectionChanged({
        $script:posMode = [string]$this.SelectedItem.Tag
        Save-Settings
        Update-Position
    })
    $hide.Add_Click({ $script:hideBanners = [bool]$this.IsChecked; Apply-Banners })
    $script:SetFilter.Add_TextChanged({ Fill-List })
    $w.FindName('BtnAll').Add_Click({ foreach ($a in @($script:apps.Values)) { $a.Enabled = $true }; Apply-Banners; Fill-List })
    $w.FindName('BtnNone').Add_Click({ foreach ($a in @($script:apps.Values)) { $a.Enabled = $false }; Apply-Banners; Fill-List })
    $w.FindName('BtnTest').Add_Click({
        Enqueue-Notif ([pscustomobject]@{ App = 'Dynamic Island'; Title = 'Тестовое уведомление'; Body = 'Если вы это видите, остров работает'; Icon = $null; Key = ('t' + (Get-Date).Ticks) })
    })
    $w.FindName('BtnRestore').Add_Click({
        $script:hideBanners = $false
        foreach ($k in @($script:backup.Keys)) { Set-Banner $k $false }
        Save-Settings
        $h = $script:setWin.FindName('HideChk'); $h.IsChecked = $false
    })
    $w.Add_Closed({ $script:setWin = $null })
    Fill-List
    $w.Show()
}

