# --- Скриншот ---
function Take-Screenshot {
    try {
        $script:win.Hide()
        Start-Sleep -Milliseconds 300
        $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
        $bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
        $graphics = [System.Drawing.Graphics]::FromImage($bmp)
        $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
        
        $picDir = [Environment]::GetFolderPath('MyPictures')
        $diDir = Join-Path $picDir 'DynamicIsland'
        if (-not (Test-Path -LiteralPath $diDir)) { [void](New-Item -ItemType Directory -Path $diDir) }
        $fileName = "Screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
        $filePath = Join-Path $diDir $fileName
        
        $bmp.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $graphics.Dispose()
        $bmp.Dispose()
        $script:win.Show()
        Show-Msg 'copy' "Скриншот сохранен"
        
        try {
            $imgToClip = [System.Drawing.Image]::FromFile($filePath)
            [System.Windows.Forms.Clipboard]::SetImage($imgToClip)
            $imgToClip.Dispose()
        } catch {}
    } catch {
        $script:win.Show()
        Show-Msg 'copy' "Ошибка скриншота"
    }
}

$script:ScreenIsland.Add_MouseLeftButtonUp({ Invoke-ScreenAction })
$script:ScreenIsland.Add_MouseEnter({ $script:ScreenIsland.Background = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(28, 28, 30)) })
$script:ScreenIsland.Add_MouseLeave({ $script:ScreenIsland.Background = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(0, 0, 0)) })

# Кнопки скриншота внутри раскрытого острова (рядом с буфером)
foreach ($b in @($script:BtnScreenBar, $script:BtnScreenM)) { $b.Add_MouseLeftButtonUp({ Take-Screenshot }) }

# Слияние отдельного островка скриншота с главным островком при его раскрытии
$script:screenMerged = $false
function Set-ScreenMerged($merge) {
    if ($merge -eq $script:screenMerged) { return }
    $script:screenMerged = $merge
    $S = $script:ScreenIsland
    $side = ($script:dock -eq 'left')
    $sizeProp = if ($side) { [Windows.FrameworkElement]::HeightProperty } else { [Windows.FrameworkElement]::WidthProperty }
    $orig = if ($side) { New-Object Windows.Thickness(6, 6, 6, 0) } else { New-Object Windows.Thickness(6, 6, 0, 6) }
    $dur  = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(240))
    $fast = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(160))
    $ease = New-Object Windows.Media.Animation.QuadraticEase
    $ease.EasingMode = 'EaseInOut'
    $op = [Windows.UIElement]::OpacityProperty
    $mp = [Windows.FrameworkElement]::MarginProperty
    if ($merge) {
        $S.IsHitTestVisible = $false
        $a = New-Object Windows.Media.Animation.DoubleAnimation(0, $dur); $a.EasingFunction = $ease
        $a.Add_Completed({ if ($script:screenMerged) { $script:ScreenIsland.Visibility = 'Collapsed' } })
        $m = New-Object Windows.Media.Animation.ThicknessAnimation((New-Object Windows.Thickness(0)), $dur); $m.EasingFunction = $ease
        $S.BeginAnimation($sizeProp, $a)
        $S.BeginAnimation($mp, $m)
        $S.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation(0, $fast)))
    } else {
        $S.Visibility = 'Visible'
        $S.IsHitTestVisible = $true
        $a = New-Object Windows.Media.Animation.DoubleAnimation(0, 36, $dur); $a.EasingFunction = $ease
        $m = New-Object Windows.Media.Animation.ThicknessAnimation($orig, $dur); $m.From = (New-Object Windows.Thickness(0)); $m.EasingFunction = $ease
        $S.BeginAnimation($sizeProp, $a)
        $S.BeginAnimation($mp, $m)
        $S.BeginAnimation($op, (New-Object Windows.Media.Animation.DoubleAnimation(0, 1, $fast)))
    }
}

# --- Действие островка справа: 'screenshot' или 'dnd' (задаётся в настройках) ---
function Invoke-ScreenAction {
    if ($script:screenAction -eq 'dnd') { Set-Dnd (-not $script:dnd) 0 $true }
    else { Take-Screenshot }
}

function Update-ScreenIcon {
    if ($script:screenAction -eq 'dnd') { $script:ScreenIcon.Opacity = $(if ($script:dnd) { 1.0 } else { 0.45 }) }
    else { $script:ScreenIcon.Opacity = 1.0 }
}

function Apply-ScreenAction {
    $isDnd = ($script:screenAction -eq 'dnd')
    $script:ScreenIcon.Text = $(if ($isDnd) { [char]::ConvertFromUtf32(0x1F319) } else { [char]::ConvertFromUtf32(0x1F4F7) })
    $script:ScreenIsland.ToolTip = $(if ($isDnd) { 'Не беспокоить: включить / выключить' } else { 'Сделать скриншот' })
    # В раскрытом острове обе кнопки (🌙 и 📷) есть всегда, независимо от действия островка справа
    $script:BtnScreenBar.Visibility = 'Visible'
    $script:BtnScreenM.Visibility = 'Visible'
    $script:DndBar.Visibility = 'Visible'
    $script:BtnDnd.Visibility = 'Visible'
    Update-ScreenIcon
}
