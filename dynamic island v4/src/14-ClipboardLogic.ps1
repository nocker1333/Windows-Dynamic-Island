function Poll-Clipboard {
    try {
        if ($script:fgOk) {
            $seq = [Fg]::ClipSeq()
            if ($seq -eq $script:clipSeq) { return }
            $script:clipSeq = $seq
        }
        
        $silent = $script:clipFirst
        $script:clipFirst = $false
        $sub = $null
        
        if ([Windows.Clipboard]::ContainsText()) {
            $txt = [Windows.Clipboard]::GetText()
            if (-not $script:fgOk) {
                if ($txt -eq $script:lastClipText) { return }
                $script:lastClipText = $txt
            }
            if (-not $script:clipPaused) { Add-Clip $txt }
            $sub = Get-Preview $txt
        } else {
            $sub = Get-ClipInfo
            if (-not $sub) { return }
        }
        
        if ($script:clipPaused) { $sub = 'запись истории на паузе' }
        if (-not $silent) { Show-Msg 'copy' $sub }
    } catch { $script:clipSeq = 0 }
}

function Poll-Keys {
    if (-not $script:fgOk) { return }
    $held = (([Fg]::KeyDown(0x11) -and [Fg]::KeyDown(0x56)) -or ([Fg]::KeyDown(0x10) -and [Fg]::KeyDown(0x2D)))
    if ($held -and -not $script:pasteHeld) {
        try { $info = Get-ClipInfo; if ($info) { Show-Msg 'paste' $info } } catch {}
    }
    $script:pasteHeld = $held
}

$script:clipFlashTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipFlashTimer.Add_Tick({
    $script:clipFlashTimer.Stop()
    $script:clipConfirm = $false
    Update-ClipTitle
})

function Update-ClipTitle {
    $side = ($script:dock -eq 'left')
    $t = $(if ($side) { '📋' } else { '📋 Буфер обмена' })
    if ($script:clipPaused) { $t += $(if ($side) { ' ⏸' } else { ' (пауза)' }) }
    $script:ClipTitle.Text = $t
    $script:ClipPause.Text = $(if ($script:clipPaused) { '▶' } else { '⏸' })
}

function Flash-ClipTitle($text, $ms) {
    $script:ClipTitle.Text = $text
    $script:clipFlashTimer.Stop()
    $script:clipFlashTimer.Interval = [TimeSpan]::FromMilliseconds($ms)
    $script:clipFlashTimer.Start()
}

function Copy-Clip($c) {
    try {
        [Windows.Clipboard]::SetText($c.Text)
        if ($script:fgOk) { $script:clipSeq = [Fg]::ClipSeq() }
        [void]$script:clips.Remove($c)
        $script:clips.Insert(0, $c)
        Save-Clips
        Fill-Clips
        Flash-ClipTitle '✓ Скопировано' 1200
    } catch { Flash-ClipTitle 'Не удалось скопировать' 1500 }
}

function Remove-Clip($c) {
    [void]$script:clips.Remove($c)
    Save-Clips
    Fill-Clips
}

function Fill-Clips {
    $script:ClipList.Children.Clear()
    if ($script:clips.Count -eq 0) {
        $e = New-Object Windows.Controls.TextBlock
        $e.Text = 'Пока пусто. Скопируйте любой текст.'
        $e.Foreground = [Windows.Media.Brushes]::Gray
        $e.FontSize = 12; $e.TextWrapping = 'Wrap'; $e.Margin = Th 0 10 0 0; $e.TextAlignment = 'Center'
        [void]$script:ClipList.Children.Add($e)
        return
    }
    
    $itemBg = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(28, 28, 30))
    $txtFg = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(237, 237, 237))
    
    foreach ($c in $script:clips) {
        $b = New-Object Windows.Controls.Border
        $b.Background = $itemBg; $b.CornerRadius = New-Object Windows.CornerRadius(8)
        $b.Margin = Th 0 0 0 4; $b.Padding = Th 8 5 6 5; $b.Cursor = [Windows.Input.Cursors]::Hand; $b.Tag = $c
        
        $g = New-Object Windows.Controls.Grid
        $c1 = New-Object Windows.Controls.ColumnDefinition
        $c2 = New-Object Windows.Controls.ColumnDefinition; $c2.Width = [Windows.GridLength]::Auto
        $g.ColumnDefinitions.Add($c1); $g.ColumnDefinitions.Add($c2)
        
        $t = New-Object Windows.Controls.TextBlock
        $p = ($c.Text -replace '\s+', ' ').Trim()
        if ($p.Length -gt 160) { $p = $p.Substring(0, 160) + '…' }
        $t.Text = $p; $t.Foreground = $txtFg; $t.FontSize = 12
        $t.TextWrapping = 'Wrap'; $t.MaxHeight = 32; $t.TextTrimming = 'CharacterEllipsis'
        $t.VerticalAlignment = 'Center'
        
        $x = New-Object Windows.Controls.TextBlock
        $x.Text = '✕'; $x.Foreground = [Windows.Media.Brushes]::Gray; $x.FontSize = 11
        $x.Padding = Th 8 2 2 2; $x.Cursor = [Windows.Input.Cursors]::Hand; $x.Tag = $c
        $x.VerticalAlignment = 'Top'; $x.Background = [Windows.Media.Brushes]::Transparent
        
        [Windows.Controls.Grid]::SetColumn($x, 1)
        [void]$g.Children.Add($t); [void]$g.Children.Add($x)
        $b.Child = $g
        
        $b.Add_MouseLeftButtonUp({ Copy-Clip $this.Tag })
        $x.Add_MouseLeftButtonUp({ $args[1].Handled = $true; Remove-Clip $this.Tag })
        [void]$script:ClipList.Children.Add($b)
    }
}

$script:clipOpenTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipOpenTimer.Interval = [TimeSpan]::FromMilliseconds(180)
$script:clipOpenTimer.Add_Tick({
    $script:clipOpenTimer.Stop()
    if ($script:BtnClipBar.IsMouseOver -or $script:BtnClipM.IsMouseOver) { $script:clipOpen = $true; Update-ClipIsland }
})

$script:clipLeaveTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipLeaveTimer.Interval = [TimeSpan]::FromMilliseconds(400)
$script:clipLeaveTimer.Add_Tick({
    $script:clipLeaveTimer.Stop()
    if (-not $script:BtnClipBar.IsMouseOver -and -not $script:BtnClipM.IsMouseOver -and -not $script:ClipIsland.IsMouseOver) {
        $script:clipOpen = $false
        Update-ClipIsland
    }
})

foreach ($n in @($script:BtnClipBar, $script:BtnClipM)) {
    $n.Add_MouseEnter({ $script:clipLeaveTimer.Stop(); $script:clipOpenTimer.Stop(); $script:clipOpenTimer.Start() })
    $n.Add_MouseLeave({ $script:clipOpenTimer.Stop(); if ($script:clipOpen) { $script:clipLeaveTimer.Stop(); $script:clipLeaveTimer.Start() } })
    $n.Add_MouseLeftButtonUp({ $script:clipOpen = $true; Update-ClipIsland })
}

$script:ClipIsland.Add_MouseEnter({ $script:clipLeaveTimer.Stop() })
$script:ClipIsland.Add_MouseLeave({ if ($script:clipOpen) { $script:clipLeaveTimer.Stop(); $script:clipLeaveTimer.Start() } })
$script:ClipClose.Add_MouseLeftButtonUp({ $script:clipOpen = $false; Update-ClipIsland })
$script:ClipPause.Add_MouseLeftButtonUp({ $script:clipPaused = -not $script:clipPaused; Update-ClipTitle })
$script:ClipClear.Add_MouseLeftButtonUp({
    if ($script:clipConfirm) {
        $script:clips.Clear(); Save-Clips; Fill-Clips
        $script:clipConfirm = $false
        Flash-ClipTitle '✓ Очищено' 1200
    } else {
        $script:clipConfirm = $true
        Flash-ClipTitle 'Очистить всё? Ещё раз 🗑' 3000
    }
})

Load-Clips

$script:clipTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipTimer.Interval = [TimeSpan]::FromMilliseconds(800)
$script:clipTimer.Add_Tick({ Poll-Clipboard })

$script:keyTimer = New-Object Windows.Threading.DispatcherTimer
$script:keyTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$script:keyTimer.Add_Tick({ Poll-Keys })

