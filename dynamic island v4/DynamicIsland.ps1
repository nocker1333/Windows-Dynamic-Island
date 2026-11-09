# Dynamic Island для Windows (PowerShell + WPF)
# Главный файл: подключает модули из папки src в том же порядке, что был в одном файле.
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, Microsoft.VisualBasic, System.Runtime.WindowsRuntime, UIAutomationClient, UIAutomationTypes, System.Drawing

$script:srcDir = Join-Path $PSScriptRoot 'src'

# Порядок важен: код выполняется сверху вниз, как в исходном скрипте.
$modules = @(
    '01-Window.ps1', '02-State.ps1', '03-WinRT.ps1', '04-Screenshot.ps1',
    '05-Animation.ps1', '06-PopupAndDnd.ps1', '07-HoverAndPlayerButtons.ps1',
    '08-ContextMenu.ps1', '09-Media.ps1', '10-Settings.ps1', '11-Notifications.ps1',
    '12-Clipboard.ps1', '13-ChildIslands.ps1', '14-ClipboardLogic.ps1',
    '15-Docking.ps1', '16-SettingsWindow.ps1', '17-Timers.ps1'
)
foreach ($m in $modules) {
    . (Join-Path $script:srcDir $m)   # точка + пробел = dot-sourcing, общая область видимости
}


switch ($script:source) {
    'listener' { Start-Pop 'text' '🔔 Уведомления: система' 3 }
    'db'       { Start-Pop 'text' '🔔 Уведомления: база Windows' 3 }
    'uia'      { Start-Pop 'text' '🔔 Уведомления: перехват' 3 }
    default    { Start-Pop 'text' '⚠ Уведомления недоступны' 3 }
}

$app = New-Object Windows.Application
$app.ShutdownMode = 'OnMainWindowClose'
[void]$app.Run($script:win)