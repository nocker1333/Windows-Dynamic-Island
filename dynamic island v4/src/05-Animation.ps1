# --- Анимации ---
$script:sizes = @{
    top  = @{ msg = @(300, 62); clip = @(400, 210); dnd = @(290, 150); text = @(260, 44); notif = @(400, 84); bigmusic = @(400, 120); mini = @(220, 36); bigclock = @(400, 148); small = @(150, 36) }
    left = @{ msg = @(150, 122); clip = @(170, 300); dnd = @(170, 220); text = @(130, 90); notif = @(170, 190); bigmusic = @(170, 290); mini = @(44, 120); bigclock = @(130, 260); small = @(44, 84) }
}
$script:layers = @{
    text = @(0,1,0,0,0,0,0); notif = @(0,0,0,0,1,0,0); bigmusic = @(0,0,0,1,0,0,0)
    mini = @(0,0,1,0,0,0,0); bigclock = @(1,0,0,0,0,0,0); small = @(0,1,0,0,0,0,0); clip = @(0,0,0,0,0,1,0)
    msg = @(0,0,0,0,0,0,1)
}

function Clock-Text {
    $n = Get-Date
    if ($script:dock -eq 'left') {
        $t = $n.ToString('HH') + "`n" + $n.ToString('mm')
        if ($script:dnd) { $t = "🌙`n" + $t }
        return $t
    }
    if ($script:dnd) { return '🌙 ' + $n.ToString('HH:mm') }
    return $n.ToString('HH:mm')
}

function Th($l, $t, $r, $b) { return (New-Object Windows.Thickness($l, $t, $r, $b)) }

function Set-Orientation($side) {
    $g = [Windows.Controls.Grid]
    if ($side) {
        $script:Big.Margin = Th 8 0 8 0
        $script:DndLabel.Text = 'ДНД'
        $script:ClipBarText.Text = 'Буфер'
        $script:ClipBarArrow.Visibility = 'Collapsed'
        $script:Clip.Margin = Th 10 10 10 10
        $script:Msg.Margin = Th 10 0 10 0
        $script:Msg.RowDefinitions.Clear()
        $m1 = New-Object Windows.Controls.RowDefinition; $m1.Height = [Windows.GridLength]::Auto
        $m2 = New-Object Windows.Controls.RowDefinition
        $script:Msg.RowDefinitions.Add($m1); $script:Msg.RowDefinitions.Add($m2)
        $script:MsgIcon.HorizontalAlignment = 'Center'; $script:MsgIcon.VerticalAlignment = 'Top'; $script:MsgIcon.Margin = Th 0 16 0 0
        $g::SetRow($script:MsgIcon, 0); $g::SetColumn($script:MsgIcon, 0); $g::SetColumnSpan($script:MsgIcon, 2)
        $g::SetRow($script:MsgText, 1); $g::SetColumn($script:MsgText, 0); $g::SetColumnSpan($script:MsgText, 2)
        $script:MsgText.Margin = Th 0 8 0 0; $script:MsgText.VerticalAlignment = 'Top'
        $script:MsgTitle.TextAlignment = 'Center'; $script:MsgSub.TextAlignment = 'Center'
        $script:BtnPrev.Padding = Th 5 4 5 4; $script:BtnPlay.Padding = Th 5 2 5 2; $script:BtnNext.Padding = Th 5 4 5 4; $script:BtnDnd.Padding = Th 5 4 5 4; $script:BtnClipM.Padding = Th 5 4 5 4
        $script:BigL.HorizontalAlignment = 'Center'; $script:BigL.VerticalAlignment = 'Top'; $script:BigL.Margin = Th 0 16 0 0
        $script:BigR.HorizontalAlignment = 'Center'; $script:BigR.VerticalAlignment = 'Bottom'; $script:BigR.Margin = Th 0 0 0 16
        $script:BigTime.FontSize = 28; $script:BigTime.TextAlignment = 'Center'
        $script:BigDate.TextAlignment = 'Center'; $script:BigDate.TextWrapping = 'Wrap'
        $script:BigDndStatus.TextAlignment = 'Center'; $script:BigDndStatus.TextWrapping = 'Wrap'
        foreach ($t in @($script:Bat, $script:Cpu, $script:Ram)) { $t.HorizontalAlignment = 'Center' }
        $script:Mini.Margin = Th 0 0 0 0
        $script:MiniArt.HorizontalAlignment = 'Center'; $script:MiniArt.VerticalAlignment = 'Top'; $script:MiniArt.Margin = Th 0 12 0 0
        $script:MiniBars.HorizontalAlignment = 'Center'; $script:MiniBars.VerticalAlignment = 'Bottom'; $script:MiniBars.Margin = Th 0 0 0 14
        $script:BigMusic.Margin = Th 10 0 10 0
        $script:BigMusic.RowDefinitions.Clear()
        $r1 = New-Object Windows.Controls.RowDefinition; $r1.Height = [Windows.GridLength]::Auto
        $r2 = New-Object Windows.Controls.RowDefinition
        $script:BigMusic.RowDefinitions.Add($r1); $script:BigMusic.RowDefinitions.Add($r2)
        $script:MusicArt.Width = 96; $script:MusicArt.Height = 96
        $script:MusicArt.HorizontalAlignment = 'Center'; $script:MusicArt.VerticalAlignment = 'Top'; $script:MusicArt.Margin = Th 0 16 0 0
        $g::SetRow($script:MusicArt, 0); $g::SetColumn($script:MusicArt, 0); $g::SetColumnSpan($script:MusicArt, 2)
        $g::SetRow($script:MusicText, 1); $g::SetColumn($script:MusicText, 0); $g::SetColumnSpan($script:MusicText, 2)
        $script:MusicText.Margin = Th 0 10 0 0; $script:MusicText.VerticalAlignment = 'Top'
        $script:Title.TextAlignment = 'Center'; $script:Artist.TextAlignment = 'Center'
        $script:Notif.Margin = Th 10 0 10 0
        $script:Notif.RowDefinitions.Clear()
        $n1 = New-Object Windows.Controls.RowDefinition; $n1.Height = [Windows.GridLength]::Auto
        $n2 = New-Object Windows.Controls.RowDefinition
        $script:Notif.RowDefinitions.Add($n1); $script:Notif.RowDefinitions.Add($n2)
        $script:NotifArt.HorizontalAlignment = 'Center'; $script:NotifArt.VerticalAlignment = 'Top'; $script:NotifArt.Margin = Th 0 16 0 0
        $g::SetRow($script:NotifArt, 0); $g::SetColumn($script:NotifArt, 0); $g::SetColumnSpan($script:NotifArt, 2)
        $g::SetRow($script:NotifText, 1); $g::SetColumn($script:NotifText, 0); $g::SetColumnSpan($script:NotifText, 2)
        $script:NotifText.Margin = Th 0 8 0 0; $script:NotifText.VerticalAlignment = 'Top'
        foreach ($t in @($script:NotifApp, $script:NotifTitle, $script:NotifBody)) { $t.TextAlignment = 'Center' }
        $script:NotifTitle.TextWrapping = 'Wrap'; $script:NotifTitle.MaxHeight = 40
        $script:NotifBody.TextWrapping = 'Wrap'; $script:NotifBody.MaxHeight = 66
    } else {
        $script:Big.Margin = Th 20 0 20 0
        $script:DndLabel.Text = 'Не беспокоить'
        $script:ClipBarText.Text = 'Буфер обмена'
        $script:ClipBarArrow.Visibility = 'Visible'
        $script:Clip.Margin = Th 14 10 14 10
        $script:Msg.Margin = Th 14 0 14 0
        $script:Msg.RowDefinitions.Clear()
        $script:MsgIcon.HorizontalAlignment = 'Stretch'; $script:MsgIcon.VerticalAlignment = 'Center'; $script:MsgIcon.Margin = Th 0 0 0 0
        $g::SetRow($script:MsgIcon, 0); $g::SetColumn($script:MsgIcon, 0); $g::SetColumnSpan($script:MsgIcon, 1)
        $g::SetRow($script:MsgText, 0); $g::SetColumn($script:MsgText, 1); $g::SetColumnSpan($script:MsgText, 1)
        $script:MsgText.Margin = Th 12 0 0 0; $script:MsgText.VerticalAlignment = 'Center'
        $script:MsgTitle.TextAlignment = 'Left'; $script:MsgSub.TextAlignment = 'Left'
        $script:BtnPrev.Padding = Th 12 4 12 4; $script:BtnPlay.Padding = Th 12 2 12 2; $script:BtnNext.Padding = Th 12 4 12 4; $script:BtnDnd.Padding = Th 12 4 12 4; $script:BtnClipM.Padding = Th 12 4 12 4
        $script:BigL.HorizontalAlignment = 'Left'; $script:BigL.VerticalAlignment = 'Center'; $script:BigL.Margin = Th 0 0 0 0
        $script:BigR.HorizontalAlignment = 'Right'; $script:BigR.VerticalAlignment = 'Center'; $script:BigR.Margin = Th 0 0 0 0
        $script:BigTime.FontSize = 36; $script:BigTime.TextAlignment = 'Left'
        $script:BigDate.TextAlignment = 'Left'; $script:BigDate.TextWrapping = 'NoWrap'
        $script:BigDndStatus.TextAlignment = 'Left'; $script:BigDndStatus.TextWrapping = 'NoWrap'
        foreach ($t in @($script:Bat, $script:Cpu, $script:Ram)) { $t.HorizontalAlignment = 'Right' }
        $script:Mini.Margin = Th 12 0 12 0
        $script:MiniArt.HorizontalAlignment = 'Left'; $script:MiniArt.VerticalAlignment = 'Center'; $script:MiniArt.Margin = Th 0 0 0 0
        $script:MiniBars.HorizontalAlignment = 'Right'; $script:MiniBars.VerticalAlignment = 'Center'; $script:MiniBars.Margin = Th 0 0 0 0
        $script:BigMusic.Margin = Th 20 0 20 0
        $script:BigMusic.RowDefinitions.Clear()
        $script:MusicArt.Width = 76; $script:MusicArt.Height = 76
        $script:MusicArt.HorizontalAlignment = 'Left'; $script:MusicArt.VerticalAlignment = 'Center'; $script:MusicArt.Margin = Th 0 0 0 0
        $g::SetRow($script:MusicArt, 0); $g::SetColumn($script:MusicArt, 0); $g::SetColumnSpan($script:MusicArt, 1)
        $g::SetRow($script:MusicText, 0); $g::SetColumn($script:MusicText, 1); $g::SetColumnSpan($script:MusicText, 1)
        $script:MusicText.Margin = Th 14 0 0 0; $script:MusicText.VerticalAlignment = 'Center'
        $script:Title.TextAlignment = 'Left'; $script:Artist.TextAlignment = 'Left'
        $script:Notif.Margin = Th 16 0 16 0
        $script:Notif.RowDefinitions.Clear()
        $script:NotifArt.HorizontalAlignment = 'Stretch'; $script:NotifArt.VerticalAlignment = 'Center'; $script:NotifArt.Margin = Th 0 0 0 0
        $g::SetRow($script:NotifArt, 0); $g::SetColumn($script:NotifArt, 0); $g::SetColumnSpan($script:NotifArt, 1)
        $g::SetRow($script:NotifText, 0); $g::SetColumn($script:NotifText, 1); $g::SetColumnSpan($script:NotifText, 1)
        $script:NotifText.Margin = Th 12 0 0 0; $script:NotifText.VerticalAlignment = 'Center'
        foreach ($t in @($script:NotifApp, $script:NotifTitle, $script:NotifBody)) { $t.TextAlignment = 'Left' }
        $script:NotifTitle.TextWrapping = 'NoWrap'; $script:NotifTitle.MaxHeight = [double]::PositiveInfinity
        $script:NotifBody.TextWrapping = 'NoWrap'; $script:NotifBody.MaxHeight = [double]::PositiveInfinity
    }
}

function Animate($w, $h, $big, $small, $mini, $bigMusic, $notif, $clip, $msg) {
    $ease = New-Object Windows.Media.Animation.BackEase
    $ease.EasingMode = 'EaseOut'; $ease.Amplitude = 0.35
    $dur = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(450))
    $fast = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(250))
    $aw = New-Object Windows.Media.Animation.DoubleAnimation($w, $dur); $aw.EasingFunction = $ease
    $ah = New-Object Windows.Media.Animation.DoubleAnimation($h, $dur); $ah.EasingFunction = $ease
    $script:Island.BeginAnimation([Windows.FrameworkElement]::WidthProperty, $aw)
    $script:Island.BeginAnimation([Windows.FrameworkElement]::HeightProperty, $ah)
    $op = [Windows.UIElement]::OpacityProperty
    $script:Big.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation($big, $fast)))
    $script:Small.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation($small, $fast)))
    $script:Mini.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation($mini, $fast)))
    $script:BigMusic.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation($bigMusic, $fast)))
    $script:Notif.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation($notif, $fast)))
    $script:Msg.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation($msg, $fast)))
}

function Apply-State {
    $exp = $script:hover -or ($script:pop -eq 'track')
    if ($script:pop -eq 'text') { $mode = 'text' }
    elseif ($script:pop -eq 'notif' -and $script:showNotifText) { $mode = 'notif' }
    elseif ($script:pop -eq 'notif' -and -not $script:showNotifText) { $mode = 'small'; $script:pop = 'none' }
    elseif ($script:pop -eq 'msg') { $mode = 'msg' }
    elseif ($script:hasMusic -and $exp -and $script:showMusic) { $mode = 'bigmusic' }
    elseif ($script:hasMusic -and $script:showMusic) { $mode = 'mini' }
    elseif ($exp) { $mode = 'bigclock' }
    else { $mode = 'small' }
    
    $key = $mode + '|' + $script:popText
    if ($key -eq $script:stateKey) { return }
    $script:stateKey = $key
    $script:Big.IsHitTestVisible = ($mode -eq 'bigclock')
    $script:BigMusic.IsHitTestVisible = ($mode -eq 'bigmusic')
    $script:BigR.Visibility = $(if ($script:showStats) { 'Visible' } else { 'Collapsed' })
    $sz = $script:sizes[$script:dock][$mode]
    $ly = $script:layers[$mode]
    if ($mode -eq 'text') {
        $script:Small.Text = $script:popText
        $script:Small.TextWrapping = $(if ($script:dock -eq 'left') { 'Wrap' } else { 'NoWrap' })
    } elseif ($mode -eq 'small') {
        $script:Small.TextWrapping = 'NoWrap'
        $script:Small.Text = Clock-Text
    }
    Animate $sz[0] $sz[1] $ly[0] $ly[1] $ly[2] $ly[3] $ly[4] $ly[5] $ly[6]
}

