# --- Меню ---
$menu = New-Object Windows.Controls.ContextMenu
$script:miDnd = New-Object Windows.Controls.MenuItem
$script:miDnd.Header = '🌙 Не беспокоить'
foreach ($opt in @(@('Включить', 0), @('На 30 минут', 30), @('На 1 час', 60), @('На 2 часа', 120))) {
    $it = New-Object Windows.Controls.MenuItem
    $it.Header = $opt[0]; $it.Tag = $opt[1]
    $it.Add_Click({ Set-Dnd $true ([int]$this.Tag) })
    [void]$script:miDnd.Items.Add($it)
}
$script:miDndOff = New-Object Windows.Controls.MenuItem
$script:miDndOff.Header = 'Выключить'
$script:miDndOff.Add_Click({ Set-Dnd $false 0 })
[void]$script:miDnd.Items.Add($script:miDndOff)
[void]$menu.Items.Add($script:miDnd)

$script:miLock = New-Object Windows.Controls.MenuItem
$script:miLock.Add_Click({
    $script:dockLocked = -not $script:dockLocked
    Save-Settings
    Update-Position
})
[void]$menu.Items.Add($script:miLock)

$script:miScreen = New-Object Windows.Controls.MenuItem
$script:miScreen.Header = '📸 Сделать скриншот'
$script:miScreen.Add_Click({ Take-Screenshot })
[void]$menu.Items.Add($script:miScreen)

$menu.Add_Opened({
    $script:miDnd.Header = $(if ($script:dnd) { '🌙 Не беспокоить (включено)' } else { '🌙 Не беспокоить' })
    $script:miDndOff.IsEnabled = $script:dnd
    $script:miLock.Header = $(if ($script:dockLocked) { '🔒 Закрепить положение (ВКЛ)' } else { '🔒 Закрепить положение (ВЫКЛ)' })
})

$miSet = New-Object Windows.Controls.MenuItem
$miSet.Header = 'Настройки...'
$miSet.Add_Click({ Open-Settings })
[void]$menu.Items.Add($miSet)

$mi = New-Object Windows.Controls.MenuItem
$mi.Header = 'Выход'
$mi.Add_Click({ $script:win.Close() })
[void]$menu.Items.Add($mi)

$script:win.Add_Closed({
    foreach ($k in @($script:backup.Keys)) { Set-Banner $k $false }
    Save-Settings
})

$script:Island.ContextMenu = $menu
$script:ScreenIsland.ContextMenu = $menu

