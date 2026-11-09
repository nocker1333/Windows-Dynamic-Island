$script:popTimer = New-Object Windows.Threading.DispatcherTimer
$script:popTimer.Add_Tick({
    $script:popTimer.Stop()
    $script:pop = 'none'; $script:popText = ''
    if ($script:queue.Count -gt 0) { Show-Notif ($script:queue.Dequeue()) } else { Apply-State }
})

function Start-Pop($kind, $text, $seconds, $force = $false) {
    if ($script:dnd -and -not $force) { return }
    if ($kind -eq 'notif' -and -not $script:showNotifText) { return }
    $script:popTimer.Stop()
    $script:pop = $kind; $script:popText = $text
    Apply-State
    $script:popTimer.Interval = [TimeSpan]::FromSeconds($seconds)
    $script:popTimer.Start()
}

$script:dnd = $false
$script:dndUntil = $null
$script:missed = 0

function Set-Dnd($on, $minutes, $quiet = $false) {
    if ($on) {
        $script:dnd = $true
        $script:dndUntil = $(if ($minutes -gt 0) { (Get-Date).AddMinutes($minutes) } else { $null })
        $script:missed = 0
        $script:queue.Clear()
        $msg = $(if ($minutes -gt 0) { "🌙 Не беспокоить: $minutes мин" } else { '🌙 Не беспокоить: вкл' })
        if (-not $quiet) { Start-Pop 'text' $msg 3 $true }
    } else {
        $was = $script:dnd
        $script:dnd = $false
        $script:dndUntil = $null
        if ($was -and (-not $quiet -or $script:missed -gt 0)) {
            $msg = '🔔 Выкл'
            if ($script:missed -gt 0) { $msg += " · пропущено: $($script:missed)" }
            Start-Pop 'text' $msg 4 $true
        }
        $script:missed = 0
    }
    Update-DndUi
    Update-DndStatusDisplay
}

function Update-DndUi {
    $on = [bool]$script:dnd
    $dur = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(180))
    $col = $(if ($on) { [Windows.Media.Color]::FromRgb(48, 209, 88) } else { [Windows.Media.Color]::FromRgb(58, 58, 60) })
    $script:DndSwitch.Background = New-Object Windows.Media.SolidColorBrush ($col)
    $to = $(if ($on) { New-Object Windows.Thickness(18, 0, 0, 0) } else { New-Object Windows.Thickness(2, 0, 0, 0) })
    $script:DndKnob.BeginAnimation([Windows.FrameworkElement]::MarginProperty, (New-Object Windows.Media.Animation.ThicknessAnimation($to, $dur)))
    $script:BtnDnd.Opacity = $(if ($on) { 1.0 } else { 0.4 })
    if ($script:BtnDndClock) { $script:BtnDndClock.Opacity = $(if ($on) { 1.0 } else { 0.4 }) }
}

function Update-DndStatusDisplay {
    if (-not $script:dnd) {
        $script:BigDndStatus.Visibility = 'Collapsed'
        return
    }
    $script:BigDndStatus.Visibility = 'Visible'
    if ($script:dndUntil) {
        $rem = $script:dndUntil - (Get-Date)
        if ($rem.TotalSeconds -le 0) {
            Set-Dnd $false 0
        } else {
            if ($rem.TotalHours -ge 1) {
                $hours = [Math]::Floor($rem.TotalHours)
                $mins = $rem.Minutes
                $script:BigDndStatus.Text = "🌙 ДНД: осталось $hours ч $mins мин"
            } else {
                $mins = [Math]::Max(1, [Math]::Ceiling($rem.TotalMinutes))
                $script:BigDndStatus.Text = "🌙 ДНД: осталось $mins мин"
            }
        }
    } else {
        $script:BigDndStatus.Text = "🌙 ДНД: включено"
    }
}

$script:DndSwitch.Add_MouseLeftButtonUp({ Set-Dnd (-not $script:dnd) 0 $true })
$script:DndBar.Add_MouseLeftButtonUp({ Set-Dnd (-not $script:dnd) 0 $true })
