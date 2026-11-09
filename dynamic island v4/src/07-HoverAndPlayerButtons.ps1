
$script:leaveTimer = New-Object Windows.Threading.DispatcherTimer
$script:leaveTimer.Interval = [TimeSpan]::FromMilliseconds(220)
$script:leaveTimer.Add_Tick({
    $script:leaveTimer.Stop()
    if (-not $script:Island.IsMouseOver -and -not $script:ClipIsland.IsMouseOver -and -not $script:DndIsland.IsMouseOver) {
        $script:hover = $false
        $script:clipOpen = $false
        $script:dndOpen = $false
        Update-ClipIsland
        Update-DndIsland
        Apply-State
    }
})

$script:Island.Add_MouseEnter({
    if ($script:ScreenIsland.IsMouseOver) { return }
    $script:leaveTimer.Stop(); $script:hover = $true; Apply-State
})
$script:Island.Add_MouseLeave({ $script:leaveTimer.Stop(); $script:leaveTimer.Start() })
# Островок скриншота намеренно не влияет на раскрытие основного островка
$script:ClipIsland.Add_MouseEnter({ $script:leaveTimer.Stop(); $script:hover = $true })
$script:ClipIsland.Add_MouseLeave({ $script:leaveTimer.Stop(); $script:leaveTimer.Start() })
$script:DndIsland.Add_MouseEnter({ $script:leaveTimer.Stop(); $script:hover = $true })
$script:DndIsland.Add_MouseLeave({ $script:leaveTimer.Stop(); $script:leaveTimer.Start() })

# --- Кнопки плеера ---
$script:BtnPrev.Add_MouseLeftButtonUp({ try { [void]$script:session.TrySkipPreviousAsync() } catch {} })
$script:BtnNext.Add_MouseLeftButtonUp({ try { [void]$script:session.TrySkipNextAsync() } catch {} })
$script:BtnPlay.Add_MouseLeftButtonUp({ try { [void]$script:session.TryTogglePlayPauseAsync() } catch {} })

