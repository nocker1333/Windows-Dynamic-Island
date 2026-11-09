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

$script:ScreenIsland.Add_MouseLeftButtonUp({ Take-Screenshot })
$script:ScreenIsland.Add_MouseEnter({ $script:ScreenIsland.Background = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(28, 28, 30)) })
$script:ScreenIsland.Add_MouseLeave({ $script:ScreenIsland.Background = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(0, 0, 0)) })

