# --- Положение острова ---
$script:fgcs = Get-Content -LiteralPath (Join-Path $script:srcDir 'Foreground.cs') -Raw -Encoding UTF8

$script:fgOk = $false
try { Add-Type -TypeDefinition $script:fgcs -Language CSharp; $script:fgOk = $true } catch {}

function Layout-Dock($mode) {
    $W = [Windows.SystemParameters]::PrimaryScreenWidth
    $H = [Windows.SystemParameters]::PrimaryScreenHeight
    if ($mode -eq 'left') {
        $script:win.Width = 500; $script:win.Height = 390
        $script:win.Left = 0; $script:win.Top = ($H - 390) / 2
        $script:Root.Orientation = 'Vertical'
        $script:Root.HorizontalAlignment = 'Left'
        $script:Root.VerticalAlignment = 'Center'
        $script:Island.Margin = New-Object Windows.Thickness(6, 0, 0, 0)
        $script:ScreenIsland.Margin = New-Object Windows.Thickness(6, 6, 6, 0)
        $script:Rot.Angle = 0
        Set-Orientation $true
    } else {
        $script:win.Width = 490; $script:win.Height = 380
        $script:win.Left = ($W - 490) / 2; $script:win.Top = 0
        $script:Root.Orientation = 'Horizontal'
        $script:Root.HorizontalAlignment = 'Center'
        $script:Root.VerticalAlignment = 'Top'
        $script:Island.Margin = New-Object Windows.Thickness(0, 6, 0, 0)
        $script:ScreenIsland.Margin = New-Object Windows.Thickness(6, 6, 0, 6)
        $script:Rot.Angle = 0
        Set-Orientation $false
    }
    $script:dock = $mode
}

$script:dockTimer = New-Object Windows.Threading.DispatcherTimer
$script:dockTimer.Interval = [TimeSpan]::FromMilliseconds(240)
$script:dockTimer.Add_Tick({
    $script:dockTimer.Stop()
    try {
        $script:clipOpen = $false; $script:clipShown = $false
        $script:dndOpen = $false; $script:dndShown = $false
        $script:ClipIsland.Visibility = 'Collapsed'
        $script:DndIsland.Visibility = 'Collapsed'
        Layout-Dock $script:pendingDock
        $script:stateKey = ''
        Apply-State
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(250))
        $script:Island.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(1, $d)))
        $script:ScreenIsland.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(1, $d)))
    } catch {}
    $script:dockBusy = $false
})

function Change-Dock($mode) {
    if ($mode -eq $script:dock -or $script:dockBusy -or $script:gameHidden) { return }
    $script:dockBusy = $true
    $script:pendingDock = $mode
    $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(200))
    $script:Island.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(0, $d)))
    $script:ScreenIsland.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(0, $d)))
    $script:Island.BeginAnimation([Windows.FrameworkElement]::WidthProperty, (New-Object Windows.Media.Animation.DoubleAnimation(36, $d)))
    $script:Island.BeginAnimation([Windows.FrameworkElement]::HeightProperty, (New-Object Windows.Media.Animation.DoubleAnimation(36, $d)))
    $script:dockTimer.Start()
}

$script:hideTimer = New-Object Windows.Threading.DispatcherTimer
$script:hideTimer.Interval = [TimeSpan]::FromMilliseconds(220)
$script:hideTimer.Add_Tick({
    $script:hideTimer.Stop()
    if ($script:gameHidden) { $script:win.Hide() }
})

function Set-GameHidden($hide) {
    if ($hide -eq $script:gameHidden) { return }
    $script:gameHidden = $hide
    $script:hideTimer.Stop()
    if ($hide) {
        $script:queue.Clear()
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(200))
        $script:Island.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(0, $d)))
        $script:ScreenIsland.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(0, $d)))
        $script:hideTimer.Start()
    } else {
        $script:win.Show()
        $script:stateKey = ''
        Apply-State
        $d = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(300))
        $script:Island.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(1, $d)))
        $script:ScreenIsland.BeginAnimation([Windows.UIElement]::OpacityProperty, (New-Object Windows.Media.Animation.DoubleAnimation(1, $d)))
    }
}

function Update-Position {
    if ($script:dockLocked -or -not $script:fgOk) { return }
    $W = [Windows.SystemParameters]::PrimaryScreenWidth
    $sw = [Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $sh = [Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    $scale = $sw / $W
    
    $other = $false; $cls = ''; $wl = 0; $wt = 0; $wr = 0; $wb = 0; $cap = 1
    try {
        $p = @(([Fg]::Get()) -split '|')
        if ($p.Count -ge 7 -and ([uint32]$p[1]) -ne [uint32]$PID) {
            $cls = $p[0]; $wl = [int]$p[2]; $wt = [int]$p[3]; $wr = [int]$p[4]; $wb = [int]$p[5]; $cap = [int]$p[6]
            $other = $true
        }
    } catch {}
    
    $isDesktop = ($cls -eq 'Progman' -or $cls -eq 'WorkerW')
    $isShell = ($cls -match '^(Shell_TrayWnd|Shell_SecondaryTrayWnd|Windows.UI.Core.CoreWindow|NotifyIconOverflowWindow|XamlExplorerHostIslandWindow|TopLevelWindowForOverflowXamlIsland)$')
    
    $full = $false
    if ($script:hideInGames) {
        try { $q = [Fg]::Qun(); if ($q -eq 2 -or $q -eq 3 -or $q -eq 4) { $full = $true } } catch {}
        if ($other -and -not $isDesktop -and -not $isShell -and $cap -eq 0 -and $wl -le 0 -and $wt -le 0 -and $wr -ge $sw -and $wb -ge $sh) { $full = $true }
    }
    
    Set-GameHidden $full
    if ($script:gameHidden) { return }
    
    $script:wantLeft = $false
    try {
        $tp = @(([Fg]::Top()) -split '\|')
        if ($tp.Count -ge 7 -and $tp[0] -ne 'Progman') {
            $il = ($sw - 300 * $scale) / 2
            $ir = $il + 300 * $scale
            $ib = 60 * $scale
            $script:wantLeft = ([int]$tp[2] -lt $ir -and [int]$tp[4] -gt $il -and [int]$tp[3] -lt $ib -and [int]$tp[5] -gt 0)
        }
    } catch {}
    
    if ($script:posMode -eq 'left' -and $script:wantLeft) { Change-Dock 'left' } else { Change-Dock 'top' }
}

$script:posTimer = New-Object Windows.Threading.DispatcherTimer
$script:posTimer.Interval = [TimeSpan]::FromMilliseconds(1000)
$script:posTimer.Add_Tick({ Update-Position })

