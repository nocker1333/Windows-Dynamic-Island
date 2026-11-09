# --- Таймеры ---
$script:cpuCounter = $null
try { $script:cpuCounter = New-Object Diagnostics.PerformanceCounter('Processor', '% Processor Time', '_Total'); [void]$script:cpuCounter.NextValue() } catch {}
$script:comp = New-Object Microsoft.VisualBasic.Devices.ComputerInfo
$script:lastPower = [Windows.Forms.SystemInformation]::PowerStatus.PowerLineStatus
$script:counterTick = 0

$script:timer = New-Object Windows.Threading.DispatcherTimer
$script:timer.Interval = [TimeSpan]::FromSeconds(1)
$script:timer.Add_Tick({
    $now = Get-Date
    $script:counterTick++
    
    if ($script:stateKey.StartsWith('small')) { $script:Small.Text = Clock-Text }
    $script:BigTime.Text = $now.ToString('HH:mm')
    $script:BigDate.Text = $now.ToString('dddd, d MMMM', $script:ru)
    Update-DndStatusDisplay
    
    $ps = [Windows.Forms.SystemInformation]::PowerStatus
    if ($ps.BatteryChargeStatus -band [Windows.Forms.BatteryChargeStatus]::NoSystemBattery) {
        $script:Bat.Text = '🔌 от сети'
    } else {
        $pct = [int]($ps.BatteryLifePercent * 100)
        $icon = if ($ps.PowerLineStatus -eq 'Online') { '⚡' } else { '🔋' }
        $script:Bat.Text = "$icon $pct%"
    }
    
    if ($script:showStats -and ($script:counterTick % 3 -eq 0)) {
        if ($script:cpuCounter) { try { $script:Cpu.Text = 'CPU ' + [int]$script:cpuCounter.NextValue() + '%' } catch {} }
        $used = 1 - ($script:comp.AvailablePhysicalMemory / $script:comp.TotalPhysicalMemory)
        $script:Ram.Text = 'RAM ' + [int]($used * 100) + '%'
    }
    
    if ($script:dnd -and $script:dndUntil -and (Get-Date) -ge $script:dndUntil) { Set-Dnd $false 0 }
    
    Update-Media
    Poll-Notifications
    Apply-State
    
    if ($ps.PowerLineStatus -ne $script:lastPower) {
        $script:lastPower = $ps.PowerLineStatus
        if ($ps.PowerLineStatus -eq 'Online') { Start-Pop 'text' '⚡ Зарядка подключена' 3 }
        elseif ($ps.PowerLineStatus -eq 'Offline') { Start-Pop 'text' '🔋 Зарядка отключена' 3 }
    }
})

$script:eqTimer = New-Object Windows.Threading.DispatcherTimer
$script:eqTimer.Interval = [TimeSpan]::FromMilliseconds(200)
$script:eqTimer.Add_Tick({
    if (-not $script:showMusic) { return }
    foreach ($b in $script:bars) {
        if ($script:playing) { $b.Height = Get-Random -Minimum 4 -Maximum 17 } else { $b.Height = 3 }
    }
})

$script:Small.Text = Clock-Text
$script:posTimer.Start()
$script:clipTimer.Start()
$script:keyTimer.Start()
$script:timer.Start()
$script:eqTimer.Start()
