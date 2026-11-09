# --- УМНОЕ ПОЗИЦИОНИРОВАНИЕ ДОЧЕРНИХ ОСТРОВКОВ ---
function Get-ChildIslandPosition($sz) {
    try {
        $islandPoint = $script:Island.TransformToVisual($script:win).Transform([Windows.Point]::new(0, 0))
        $islandW = $script:Island.ActualWidth
        $islandH = $script:Island.ActualHeight
    } catch {
        return [Windows.Point]::new(100, 100)
    }
    
    $gap = 10
    if ($script:dock -eq 'top') {
        # Горизонтальный режим: снизу по центру от острова
        $x = $islandPoint.X + ($islandW / 2) - ($sz[0] / 2)
        $y = $islandPoint.Y + $islandH + $gap
    } else {
        # Вертикальный режим: справа по центру от острова
        $x = $islandPoint.X + $islandW + $gap
        $y = $islandPoint.Y + ($islandH / 2) - ($sz[1] / 2)
    }
    return [Windows.Point]::new($x, $y)
}

# --- Логика островка буфера обмена (БЕЗ РЕКУРСИИ) ---
$script:clipShown = $false
$script:clipSize = @{ top = @(340, 190); left = @(280, 300) }
$script:clipHideTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipHideTimer.Interval = [TimeSpan]::FromMilliseconds(210)
$script:clipHideTimer.Add_Tick({
    $script:clipHideTimer.Stop()
    if (-not $script:clipShown) { $script:ClipIsland.Visibility = 'Collapsed' }
})

function Update-ClipIsland {
    $want = [bool]$script:clipOpen
    if ($want -eq $script:clipShown) { return }
    $script:clipShown = $want
    $script:clipHideTimer.Stop()
    
    # БЕЗ РЕКУРСИИ: просто закрываем DND напрямую
    if ($want -and $script:dndOpen) {
        $script:dndOpen = $false
        $script:dndShown = $false
        $script:DndIsland.Visibility = 'Collapsed'
        $script:DndIsland.Opacity = 0
    }
    
    $sz = $script:clipSize[$script:dock]
    $op = [Windows.UIElement]::OpacityProperty
    $pos = Get-ChildIslandPosition $sz
    
    if ($want) {
        Update-ClipTitle
        Fill-Clips
        
        # Устанавливаем начальную позицию
        $script:ClipIsland.Margin = New-Object Windows.Thickness($pos.X, $pos.Y, 0, 0)
        if ($script:dock -eq 'top') {
            $script:ClipTranslate.Y = -30
            $script:ClipTranslate.X = 0
        } else {
            $script:ClipTranslate.X = -30
            $script:ClipTranslate.Y = 0
        }
        
        $script:ClipIsland.Width = 60
        $script:ClipIsland.Height = 24
        $script:ClipIsland.Visibility = 'Visible'
        
        $ease = New-Object Windows.Media.Animation.BackEase
        $ease.EasingMode = 'EaseOut'; $ease.Amplitude = 0.25
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(420))
        
        $aw = New-Object Windows.Media.Animation.DoubleAnimation($sz[0], $d); $aw.EasingFunction = $ease
        $ah = New-Object Windows.Media.Animation.DoubleAnimation($sz[1], $d); $ah.EasingFunction = $ease
        $script:ClipIsland.BeginAnimation([Windows.FrameworkElement]::WidthProperty, $aw)
        $script:ClipIsland.BeginAnimation([Windows.FrameworkElement]::HeightProperty, $ah)
        $script:ClipIsland.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation(0, 1, (New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(250))))))
        
        # Анимация "вылета"
        $dTrans = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(400))
        $animX = New-Object Windows.Media.Animation.DoubleAnimation(0, $dTrans); $animX.EasingFunction = $ease
        $animY = New-Object Windows.Media.Animation.DoubleAnimation(0, $dTrans); $animY.EasingFunction = $ease
        $script:ClipTranslate.BeginAnimation([Windows.Media.TranslateTransform]::XProperty, $animX)
        $script:ClipTranslate.BeginAnimation([Windows.Media.TranslateTransform]::YProperty, $animY)
    } else {
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(200))
        $script:ClipIsland.BeginAnimation([Windows.FrameworkElement]::WidthProperty, (New-Object Windows.Media.Animation.DoubleAnimation(60, $d)))
        $script:ClipIsland.BeginAnimation([Windows.FrameworkElement]::HeightProperty, (New-Object Windows.Media.Animation.DoubleAnimation(24, $d)))
        $script:ClipIsland.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation(0, $d)))
        
        # Анимация "улёта"
        $dTrans = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(200))
        $easeIn = New-Object Windows.Media.Animation.CubicEase
        $easeIn.EasingMode = 'EaseIn'
        if ($script:dock -eq 'top') {
            $animY = New-Object Windows.Media.Animation.DoubleAnimation(-20, $dTrans); $animY.EasingFunction = $easeIn
            $script:ClipTranslate.BeginAnimation([Windows.Media.TranslateTransform]::YProperty, $animY)
        } else {
            $animX = New-Object Windows.Media.Animation.DoubleAnimation(-20, $dTrans); $animX.EasingFunction = $easeIn
            $script:ClipTranslate.BeginAnimation([Windows.Media.TranslateTransform]::XProperty, $animX)
        }
        
        $script:clipHideTimer.Start()
    }
}

# --- Логика островка ДНД (БЕЗ РЕКУРСИИ) ---
$script:dndShown = $false
$script:dndSize = @{ top = @(290, 150); left = @(220, 240) }
$script:dndHideTimer = New-Object Windows.Threading.DispatcherTimer
$script:dndHideTimer.Interval = [TimeSpan]::FromMilliseconds(210)
$script:dndHideTimer.Add_Tick({
    $script:dndHideTimer.Stop()
    if (-not $script:dndShown) { $script:DndIsland.Visibility = 'Collapsed' }
})

function Update-DndIsland {
    $want = [bool]$script:dndOpen
    if ($want -eq $script:dndShown) { return }
    $script:dndShown = $want
    $script:dndHideTimer.Stop()
    
    # БЕЗ РЕКУРСИИ: просто закрываем Clip напрямую
    if ($want -and $script:clipOpen) {
        $script:clipOpen = $false
        $script:clipShown = $false
        $script:ClipIsland.Visibility = 'Collapsed'
        $script:ClipIsland.Opacity = 0
    }
    
    $sz = $script:dndSize[$script:dock]
    $op = [Windows.UIElement]::OpacityProperty
    Update-DndUi
    $pos = Get-ChildIslandPosition $sz
    
    if ($want) {
        $script:DndIsland.Margin = New-Object Windows.Thickness($pos.X, $pos.Y, 0, 0)
        if ($script:dock -eq 'top') {
            $script:DndTranslate.Y = -30
            $script:DndTranslate.X = 0
        } else {
            $script:DndTranslate.X = -30
            $script:DndTranslate.Y = 0
        }
        
        $script:DndIsland.Width = 60
        $script:DndIsland.Height = 24
        $script:DndIsland.Visibility = 'Visible'
        
        $ease = New-Object Windows.Media.Animation.BackEase
        $ease.EasingMode = 'EaseOut'; $ease.Amplitude = 0.25
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(420))
        
        $aw = New-Object Windows.Media.Animation.DoubleAnimation($sz[0], $d); $aw.EasingFunction = $ease
        $ah = New-Object Windows.Media.Animation.DoubleAnimation($sz[1], $d); $ah.EasingFunction = $ease
        $script:DndIsland.BeginAnimation([Windows.FrameworkElement]::WidthProperty, $aw)
        $script:DndIsland.BeginAnimation([Windows.FrameworkElement]::HeightProperty, $ah)
        $script:DndIsland.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation(0, 1, (New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(250))))))
        
        $dTrans = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(400))
        $animX = New-Object Windows.Media.Animation.DoubleAnimation(0, $dTrans); $animX.EasingFunction = $ease
        $animY = New-Object Windows.Media.Animation.DoubleAnimation(0, $dTrans); $animY.EasingFunction = $ease
        $script:DndTranslate.BeginAnimation([Windows.Media.TranslateTransform]::XProperty, $animX)
        $script:DndTranslate.BeginAnimation([Windows.Media.TranslateTransform]::YProperty, $animY)
    } else {
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(200))
        $script:DndIsland.BeginAnimation([Windows.FrameworkElement]::WidthProperty, (New-Object Windows.Media.Animation.DoubleAnimation(60, $d)))
        $script:DndIsland.BeginAnimation([Windows.FrameworkElement]::HeightProperty, (New-Object Windows.Media.Animation.DoubleAnimation(24, $d)))
        $script:DndIsland.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation(0, $d)))
        
        $dTrans = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(200))
        $easeIn = New-Object Windows.Media.Animation.CubicEase
        $easeIn.EasingMode = 'EaseIn'
        if ($script:dock -eq 'top') {
            $animY = New-Object Windows.Media.Animation.DoubleAnimation(-20, $dTrans); $animY.EasingFunction = $easeIn
            $script:DndTranslate.BeginAnimation([Windows.Media.TranslateTransform]::YProperty, $animY)
        } else {
            $animX = New-Object Windows.Media.Animation.DoubleAnimation(-20, $dTrans); $animX.EasingFunction = $easeIn
            $script:DndTranslate.BeginAnimation([Windows.Media.TranslateTransform]::XProperty, $animX)
        }
        
        $script:dndHideTimer.Start()
    }
}

# --- Таймеры наведения ---
$script:dndOpenTimer = New-Object Windows.Threading.DispatcherTimer
$script:dndOpenTimer.Interval = [TimeSpan]::FromMilliseconds(180)
$script:dndOpenTimer.Add_Tick({
    $script:dndOpenTimer.Stop()
    if ($script:BtnDnd.IsMouseOver -or $script:BtnDndClock.IsMouseOver) { $script:dndOpen = $true; Update-DndIsland }
})

$script:dndLeaveTimer = New-Object Windows.Threading.DispatcherTimer
$script:dndLeaveTimer.Interval = [TimeSpan]::FromMilliseconds(400)
$script:dndLeaveTimer.Add_Tick({
    $script:dndLeaveTimer.Stop()
    if (-not $script:BtnDnd.IsMouseOver -and -not $script:BtnDndClock.IsMouseOver -and -not $script:DndIsland.IsMouseOver) {
        $script:dndOpen = $false
        Update-DndIsland
    }
})

foreach ($n in @($script:BtnDnd, $script:BtnDndClock)) {
    $n.Add_MouseEnter({ $script:dndLeaveTimer.Stop(); $script:dndOpenTimer.Stop(); $script:dndOpenTimer.Start() })
    $n.Add_MouseLeave({ $script:dndOpenTimer.Stop(); if ($script:dndOpen) { $script:dndLeaveTimer.Stop(); $script:dndLeaveTimer.Start() } })
    $n.Add_MouseLeftButtonUp({ $script:dndOpen = $true; Update-DndIsland })
}

$script:DndIsland.Add_MouseEnter({ $script:dndLeaveTimer.Stop() })
$script:DndIsland.Add_MouseLeave({ if ($script:dndOpen) { $script:dndLeaveTimer.Stop(); $script:dndLeaveTimer.Start() } })
$script:DndClose.Add_MouseLeftButtonUp({ $script:dndOpen = $false; Update-DndIsland })

$script:DndMenu15.Add_MouseLeftButtonUp({ Set-Dnd $true 15; $script:dndOpen = $false; Update-DndIsland })
$script:DndMenu30.Add_MouseLeftButtonUp({ Set-Dnd $true 30; $script:dndOpen = $false; Update-DndIsland })
$script:DndMenu60.Add_MouseLeftButtonUp({ Set-Dnd $true 60; $script:dndOpen = $false; Update-DndIsland })
$script:DndMenu120.Add_MouseLeftButtonUp({ Set-Dnd $true 120; $script:dndOpen = $false; Update-DndIsland })
$script:DndMenuMorning.Add_MouseLeftButtonUp({
    $now = Get-Date
    $morning = (Get-Date -Hour 8 -Minute 0 -Second 0)
    if ($now -ge $morning) { $morning = $morning.AddDays(1) }
    $mins = [Math]::Round(($morning - $now).TotalMinutes)
    Set-Dnd $true $mins
    $script:dndOpen = $false; Update-DndIsland
})
$script:DndMenuReset.Add_MouseLeftButtonUp({ Set-Dnd $false 0; $script:dndOpen = $false; Update-DndIsland })

