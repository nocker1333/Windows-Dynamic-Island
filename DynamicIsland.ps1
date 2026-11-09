# Dynamic Island для Windows (PowerShell + WPF) - Финальная версия
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, Microsoft.VisualBasic, System.Runtime.WindowsRuntime, UIAutomationClient, UIAutomationTypes, System.Drawing

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
WindowStyle="None" AllowsTransparency="True" Background="Transparent"
Topmost="True" ShowInTaskbar="False" ResizeMode="NoResize"
ShowActivated="False" Width="490" Height="380" Title="Dynamic Island">
 <Grid>
 <StackPanel x:Name="Root" Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top">
   <Border x:Name="Island" Background="#000000" CornerRadius="18" Width="150" Height="36"
           VerticalAlignment="Center" HorizontalAlignment="Center" Margin="0,6,0,0">
     <Border.Effect>
       <DropShadowEffect BlurRadius="14" ShadowDepth="0" Opacity="0.45"/>
     </Border.Effect>
     <Grid ClipToBounds="True">
       <TextBlock x:Name="Small" Foreground="White" FontSize="14" FontWeight="SemiBold" Margin="8,0"
                  TextAlignment="Center" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       <Grid x:Name="Big" Opacity="0" Margin="20,0" IsHitTestVisible="False">
         <Grid.RowDefinitions>
           <RowDefinition Height="*"/>
           <RowDefinition Height="Auto"/>
         </Grid.RowDefinitions>
         <StackPanel x:Name="BigL" Grid.Row="0" VerticalAlignment="Center" HorizontalAlignment="Left">
           <TextBlock x:Name="BigTime" FontSize="36" FontWeight="Light" Foreground="White"/>
           <TextBlock x:Name="BigDate" FontSize="12" Foreground="#FF9A9AA0"/>
           <TextBlock x:Name="BigDndStatus" FontSize="11" Foreground="#FF30D158" Margin="0,3,0,0" Visibility="Collapsed"/>
         </StackPanel>
         <StackPanel x:Name="BigR" Grid.Row="0" VerticalAlignment="Center" HorizontalAlignment="Right">
           <TextBlock x:Name="Bat" FontSize="13" Foreground="#FF30D158" HorizontalAlignment="Right"/>
           <TextBlock x:Name="Cpu" FontSize="13" Foreground="#FF0A84FF" HorizontalAlignment="Right" Margin="0,3,0,0"/>
           <TextBlock x:Name="Ram" FontSize="13" Foreground="#FFFF9F0A" HorizontalAlignment="Right" Margin="0,3,0,0"/>
         </StackPanel>
         <StackPanel Grid.Row="1" Margin="0,0,0,8">
           <Grid x:Name="DndBar" Margin="0,0,0,6">
             <StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Center">
               <TextBlock x:Name="BtnDndClock" Text="🌙" FontSize="14" Foreground="White" Cursor="Hand" Background="Transparent" Padding="4,2" Margin="-4,0,4,0" ToolTip="Таймер 'Не беспокоить'"/>
               <TextBlock x:Name="DndLabel" Text="Не беспокоить" FontSize="12" Foreground="#FFE5E5EA" VerticalAlignment="Center" FontWeight="Medium"/>
             </StackPanel>
             <Border x:Name="DndSwitch" Width="36" Height="20" CornerRadius="10" Background="#FF3A3A3C"
                     Cursor="Hand" HorizontalAlignment="Right" VerticalAlignment="Center">
               <Ellipse x:Name="DndKnob" Width="16" Height="16" Fill="White" HorizontalAlignment="Left" Margin="2,0,0,0"/>
             </Border>
           </Grid>
           <Border x:Name="BtnClipBar" Background="#1C1C1E" CornerRadius="8" Padding="8,4" Cursor="Hand">
             <Grid>
               <StackPanel Orientation="Horizontal" HorizontalAlignment="Left">
                 <TextBlock Text="📋" FontSize="13" Foreground="White" Margin="0,0,6,0"/>
                 <TextBlock x:Name="ClipBarText" Text="Буфер обмена" FontSize="12" Foreground="#FF9A9AA0" VerticalAlignment="Center"/>
               </StackPanel>
               <TextBlock x:Name="ClipBarArrow" Text="›" FontSize="14" Foreground="#FF555558" HorizontalAlignment="Right" VerticalAlignment="Center"/>
             </Grid>
           </Border>
         </StackPanel>
       </Grid>
       <Grid x:Name="Mini" Opacity="0" Margin="12,0" IsHitTestVisible="False">
         <Border x:Name="MiniArt" Width="24" Height="24" CornerRadius="6" HorizontalAlignment="Left" VerticalAlignment="Center" Background="#FF2C2C2E">
           <Border CornerRadius="6"><Border.Background><ImageBrush x:Name="ArtMini" Stretch="UniformToFill"/></Border.Background></Border>
         </Border>
         <StackPanel x:Name="MiniBars" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
           <Rectangle x:Name="Bar1" Width="3" Height="6" RadiusX="1.5" RadiusY="1.5" Fill="#FF30D158" Margin="1.5,0"/>
           <Rectangle x:Name="Bar2" Width="3" Height="10" RadiusX="1.5" RadiusY="1.5" Fill="#FF30D158" Margin="1.5,0"/>
           <Rectangle x:Name="Bar3" Width="3" Height="14" RadiusX="1.5" RadiusY="1.5" Fill="#FF30D158" Margin="1.5,0"/>
           <Rectangle x:Name="Bar4" Width="3" Height="8" RadiusX="1.5" RadiusY="1.5" Fill="#FF30D158" Margin="1.5,0"/>
         </StackPanel>
       </Grid>
       <Grid x:Name="BigMusic" Opacity="0" Margin="20,0" IsHitTestVisible="False">
         <Grid.ColumnDefinitions>
           <ColumnDefinition Width="Auto"/>
           <ColumnDefinition Width="*"/>
         </Grid.ColumnDefinitions>
         <Border x:Name="MusicArt" Grid.Column="0" Width="76" Height="76" CornerRadius="12" VerticalAlignment="Center" Background="#FF2C2C2E">
           <Border CornerRadius="12"><Border.Background><ImageBrush x:Name="ArtBig" Stretch="UniformToFill"/></Border.Background></Border>
         </Border>
         <StackPanel x:Name="MusicText" Grid.Column="1" VerticalAlignment="Center" Margin="14,0,0,0">
           <TextBlock x:Name="Title" FontSize="15" FontWeight="SemiBold" Foreground="White" TextTrimming="CharacterEllipsis"/>
           <TextBlock x:Name="Artist" FontSize="12" Foreground="#FF9A9AA0" TextTrimming="CharacterEllipsis"/>
           <ProgressBar x:Name="Prog" Height="4" Minimum="0" Maximum="1" Value="0" Margin="0,9,0,0"
                        Foreground="White" Background="#FF3A3A3C" BorderThickness="0"/>
           <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,4,0,0">
             <TextBlock x:Name="BtnPrev" Text="&#xE892;" FontFamily="Segoe MDL2 Assets" FontSize="18" Foreground="White" Background="Transparent" Padding="12,4" Cursor="Hand"/>
             <TextBlock x:Name="BtnPlay" Text="&#xE769;" FontFamily="Segoe MDL2 Assets" FontSize="22" Foreground="White" Background="Transparent" Padding="12,2" Cursor="Hand"/>
             <TextBlock x:Name="BtnNext" Text="&#xE893;" FontFamily="Segoe MDL2 Assets" FontSize="18" Foreground="White" Background="Transparent" Padding="12,4" Cursor="Hand"/>
             <TextBlock x:Name="BtnDnd" Text="🌙" FontSize="16" Foreground="White" Opacity="0.4" Background="Transparent" Padding="12,4" Cursor="Hand" VerticalAlignment="Center" ToolTip="Наведите для выбора таймера"/>
             <TextBlock x:Name="BtnClipM" Text="📋" FontSize="16" Foreground="White" Background="Transparent" Padding="12,4" Cursor="Hand" VerticalAlignment="Center" ToolTip="Буфер обмена"/>
           </StackPanel>
         </StackPanel>
       </Grid>
       <Grid x:Name="Notif" Opacity="0" Margin="16,0" IsHitTestVisible="False">
         <Grid.ColumnDefinitions>
           <ColumnDefinition Width="Auto"/>
           <ColumnDefinition Width="*"/>
         </Grid.ColumnDefinitions>
         <Border x:Name="NotifArt" Grid.Column="0" Width="48" Height="48" CornerRadius="12" VerticalAlignment="Center" Background="#FF2C2C2E">
           <Border CornerRadius="12"><Border.Background><ImageBrush x:Name="NotifIcon" Stretch="Uniform"/></Border.Background></Border>
         </Border>
         <StackPanel x:Name="NotifText" Grid.Column="1" Margin="12,0,0,0" VerticalAlignment="Center">
           <TextBlock x:Name="NotifApp" FontSize="11" Foreground="#FF9A9AA0" TextTrimming="CharacterEllipsis"/>
           <TextBlock x:Name="NotifTitle" FontSize="14" FontWeight="SemiBold" Foreground="White" TextTrimming="CharacterEllipsis"/>
           <TextBlock x:Name="NotifBody" FontSize="12" Foreground="#FFD1D1D6" TextTrimming="CharacterEllipsis"/>
         </StackPanel>
       </Grid>
       <Grid x:Name="Msg" Opacity="0" Margin="14,0" IsHitTestVisible="False">
         <Grid.ColumnDefinitions>
           <ColumnDefinition Width="Auto"/>
           <ColumnDefinition Width="*"/>
         </Grid.ColumnDefinitions>
         <Border x:Name="MsgIcon" Grid.Column="0" Width="38" Height="38" CornerRadius="19" Background="#FF30D158"
                 VerticalAlignment="Center" RenderTransformOrigin="0.5,0.5">
           <Border.RenderTransform><ScaleTransform ScaleX="1" ScaleY="1"/></Border.RenderTransform>
           <TextBlock x:Name="MsgGlyph" FontFamily="Segoe MDL2 Assets" Text="&#xE8C8;" FontSize="18" Foreground="White"
                      HorizontalAlignment="Center" VerticalAlignment="Center"/>
         </Border>
         <StackPanel x:Name="MsgText" Grid.Column="1" Margin="12,0,0,0" VerticalAlignment="Center">
           <TextBlock x:Name="MsgTitle" Text="Скопировано" FontSize="15" FontWeight="SemiBold" Foreground="White"/>
           <TextBlock x:Name="MsgSub" FontSize="11" Foreground="#FF9A9AA0" TextTrimming="CharacterEllipsis"/>
         </StackPanel>
       </Grid>
     </Grid>
   </Border>
   <Border x:Name="ScreenIsland" Background="#000000" CornerRadius="18" Width="36" Height="36"
           VerticalAlignment="Center" HorizontalAlignment="Center" Margin="6,6,0,6" Cursor="Hand" ToolTip="Сделать скриншот">
     <Border.Effect>
       <DropShadowEffect BlurRadius="14" ShadowDepth="0" Opacity="0.45"/>
     </Border.Effect>
     <TextBlock Text="📷" FontSize="15" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center"/>
   </Border>
 </StackPanel>
 <!-- Дочерний островок: буфер обмена -->
 <Border x:Name="ClipIsland" Visibility="Collapsed" Opacity="0" Background="#000000" CornerRadius="18"
         Width="340" Height="190" HorizontalAlignment="Left" VerticalAlignment="Top">
   <Border.RenderTransform><TranslateTransform x:Name="ClipTranslate" X="0" Y="0"/></Border.RenderTransform>
   <Border.Effect>
     <DropShadowEffect BlurRadius="14" ShadowDepth="0" Opacity="0.45"/>
   </Border.Effect>
   <Grid ClipToBounds="True">
     <Grid x:Name="Clip" Margin="14,10">
       <Grid.RowDefinitions>
         <RowDefinition Height="Auto"/>
         <RowDefinition Height="*"/>
       </Grid.RowDefinitions>
       <Grid Grid.Row="0" Margin="0,0,0,6">
         <Grid.ColumnDefinitions>
           <ColumnDefinition Width="*"/>
           <ColumnDefinition Width="Auto"/>
         </Grid.ColumnDefinitions>
         <TextBlock x:Name="ClipTitle" Grid.Column="0" Text="📋 Буфер обмена" Foreground="White" FontWeight="SemiBold"
                    FontSize="13" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
         <StackPanel Grid.Column="1" Orientation="Horizontal">
           <TextBlock x:Name="ClipPause" Text="⏸" Foreground="#FFBBBBBB" FontSize="13" Padding="6,2" Cursor="Hand" Background="Transparent" ToolTip="Пауза записи"/>
           <TextBlock x:Name="ClipClear" Text="🗑" Foreground="#FFBBBBBB" FontSize="13" Padding="6,2" Cursor="Hand" Background="Transparent" ToolTip="Очистить"/>
           <TextBlock x:Name="ClipClose" Text="✕" Foreground="#FFBBBBBB" FontSize="13" Padding="6,2" Cursor="Hand" Background="Transparent" ToolTip="Закрыть"/>
         </StackPanel>
       </Grid>
       <ScrollViewer x:Name="ClipScroll" Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
         <StackPanel x:Name="ClipList"/>
       </ScrollViewer>
     </Grid>
   </Grid>
 </Border>
 <!-- Дочерний островок: Выбор таймера ДНД -->
 <Border x:Name="DndIsland" Visibility="Collapsed" Opacity="0" Background="#0A0A0C" CornerRadius="18"
         Width="290" Height="150" HorizontalAlignment="Left" VerticalAlignment="Top">
   <Border.RenderTransform><TranslateTransform x:Name="DndTranslate" X="0" Y="0"/></Border.RenderTransform>
   <Border.Effect>
     <DropShadowEffect BlurRadius="16" ShadowDepth="0" Opacity="0.5"/>
   </Border.Effect>
   <Grid ClipToBounds="True" Margin="14,10">
     <Grid.RowDefinitions>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="*"/>
     </Grid.RowDefinitions>
     <Grid Grid.Row="0" Margin="0,0,0,8">
       <StackPanel Orientation="Horizontal">
         <TextBlock Text="🌙" FontSize="13" Margin="0,0,5,0" VerticalAlignment="Center"/>
         <TextBlock Text="Режим тишины" Foreground="White" FontWeight="SemiBold" FontSize="13" VerticalAlignment="Center"/>
       </StackPanel>
       <TextBlock x:Name="DndClose" Text="✕" Foreground="#FF8E8E93" FontSize="12" HorizontalAlignment="Right" Cursor="Hand" Padding="4,0"/>
     </Grid>
     <UniformGrid Grid.Row="1" Columns="3" Rows="2">
       <Border x:Name="DndMenu15" Background="#1C1C1E" CornerRadius="10" Margin="2" Cursor="Hand">
         <TextBlock Text="15 мин" Foreground="White" FontSize="12" FontWeight="Medium" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <Border x:Name="DndMenu30" Background="#1C1C1E" CornerRadius="10" Margin="2" Cursor="Hand">
         <TextBlock Text="30 мин" Foreground="White" FontSize="12" FontWeight="Medium" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <Border x:Name="DndMenu60" Background="#1C1C1E" CornerRadius="10" Margin="2" Cursor="Hand">
         <TextBlock Text="1 час" Foreground="White" FontSize="12" FontWeight="Medium" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <Border x:Name="DndMenu120" Background="#1C1C1E" CornerRadius="10" Margin="2" Cursor="Hand">
         <TextBlock Text="2 часа" Foreground="White" FontSize="12" FontWeight="Medium" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <Border x:Name="DndMenuMorning" Background="#1C1C1E" CornerRadius="10" Margin="2" Cursor="Hand">
         <TextBlock Text="До утра" Foreground="#FF30D158" FontSize="12" FontWeight="Medium" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <Border x:Name="DndMenuReset" Background="#2C2C2E" CornerRadius="10" Margin="2" Cursor="Hand">
         <TextBlock Text="Сброс" Foreground="#FFFF453A" FontSize="12" FontWeight="Medium" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
     </UniformGrid>
   </Grid>
 </Border>
</Grid>
</Window>
'@

$script:win = [Windows.Markup.XamlReader]::Parse($xaml)
foreach ($n in 'Island','Small','Big','Mini','BigMusic','BigTime','BigDate','BigDndStatus','Bat','Cpu','Ram','ArtMini','ArtBig','Title','Artist','Prog','BtnPrev','BtnPlay','BtnNext','Bar1','Bar2','Bar3','Bar4','Notif','NotifIcon','NotifApp','NotifTitle','NotifBody','BigL','BigR','MiniArt','MiniBars','MusicArt','MusicText','NotifArt','NotifText','DndBar','DndLabel','DndSwitch','DndKnob','BtnDnd','BtnDndClock','Clip','ClipTitle','ClipPause','ClipClear','ClipClose','ClipScroll','ClipList','BtnClipM','BtnClipBar','ClipBarText','ClipBarArrow','Msg','MsgIcon','MsgGlyph','MsgText','MsgTitle','MsgSub','Root','ClipIsland','DndIsland','DndClose','DndMenu15','DndMenu30','DndMenu60','DndMenu120','DndMenuMorning','DndMenuReset','ScreenIsland','ClipTranslate','DndTranslate') {
    Set-Variable -Scope Script -Name $n -Value ($script:win.FindName($n))
}

$script:bars = @($script:Bar1, $script:Bar2, $script:Bar3, $script:Bar4)
$script:win.Left = ([Windows.SystemParameters]::PrimaryScreenWidth - $script:win.Width) / 2
$script:win.Top  = 0
$script:Rot = New-Object Windows.Media.RotateTransform(0)
$script:Island.LayoutTransform = $script:Rot
$script:ru = [Globalization.CultureInfo]::GetCultureInfo('ru-RU')

# --- Состояние ---
$script:hover = $false
$script:pop = 'none'
$script:popText = ''
$script:stateKey = ''
$script:hasMusic = $false
$script:playing = $false
$script:lastPlay = [datetime]::MinValue
$script:prevHas = $false
$script:lastTrack = ''
$script:session = $null
$script:mgr = $null
$script:listener = $null
$script:firstScan = $true
$script:seen = New-Object 'System.Collections.Generic.HashSet[uint32]'
$script:uiaSeen = @{}
$script:queue = New-Object System.Collections.Queue

# --- WinRT ---
try {
    [void][Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime]
    [void][Windows.Storage.Streams.IRandomAccessStreamWithContentType, Windows.Storage.Streams, ContentType = WindowsRuntime]
    $script:asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
        $_.Name -eq 'AsTask' -and $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and
        $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
} catch { $script:asTask = $null }

function Await($op, [Type]$type) {
    $t = $script:asTask.MakeGenericMethod($type).Invoke($null, @($op))
    if ($t.Wait(5000)) { return $t.Result }
    return $null
}

try {
    $script:mgr = Await ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()) ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager])
} catch { $script:mgr = $null }

function Load-Art($info) { return Load-Stream $info.Thumbnail }
function Load-Stream($ref) {
    try {
        $rs = Await ($ref.OpenReadAsync()) ([Windows.Storage.Streams.IRandomAccessStreamWithContentType])
        $net = [System.IO.WindowsRuntimeStreamExtensions]::AsStreamForRead($rs)
        $ms = New-Object IO.MemoryStream
        $net.CopyTo($ms); $ms.Position = 0
        $bmp = New-Object Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit(); $bmp.StreamSource = $ms; $bmp.CacheOption = 'OnLoad'; $bmp.EndInit(); $bmp.Freeze()
        return $bmp
    } catch { return $null }
}

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

$script:leaveTimer = New-Object Windows.Threading.DispatcherTimer
$script:leaveTimer.Interval = [TimeSpan]::FromMilliseconds(220)
$script:leaveTimer.Add_Tick({
    $script:leaveTimer.Stop()
    if (-not $script:Island.IsMouseOver -and -not $script:ScreenIsland.IsMouseOver -and -not $script:ClipIsland.IsMouseOver -and -not $script:DndIsland.IsMouseOver) {
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
$script:ScreenIsland.Add_MouseEnter({ $script:leaveTimer.Stop(); $script:hover = $true })
$script:ScreenIsland.Add_MouseLeave({ $script:leaveTimer.Stop(); $script:leaveTimer.Start() })
$script:ClipIsland.Add_MouseEnter({ $script:leaveTimer.Stop(); $script:hover = $true })
$script:ClipIsland.Add_MouseLeave({ $script:leaveTimer.Stop(); $script:leaveTimer.Start() })
$script:DndIsland.Add_MouseEnter({ $script:leaveTimer.Stop(); $script:hover = $true })
$script:DndIsland.Add_MouseLeave({ $script:leaveTimer.Stop(); $script:leaveTimer.Start() })

# --- Кнопки плеера ---
$script:BtnPrev.Add_MouseLeftButtonUp({ try { [void]$script:session.TrySkipPreviousAsync() } catch {} })
$script:BtnNext.Add_MouseLeftButtonUp({ try { [void]$script:session.TrySkipNextAsync() } catch {} })
$script:BtnPlay.Add_MouseLeftButtonUp({ try { [void]$script:session.TryTogglePlayPauseAsync() } catch {} })

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

# --- Обновление медиа ---
function Update-Media {
    if (-not $script:showMusic -or -not $script:mgr -or -not $script:asTask) { return }
    try {
        $s = $script:mgr.GetCurrentSession()
        $script:session = $s
        if (-not $s) { $script:playing = $false; $script:hasMusic = $false; $script:prevHas = $false; return }
        
        $status = $s.GetPlaybackInfo().PlaybackStatus.ToString()
        $script:playing = ($status -eq 'Playing')
        if ($script:playing) { $script:lastPlay = Get-Date }
        
        $script:hasMusic = $script:playing -or (($status -eq 'Paused') -and (((Get-Date) - $script:lastPlay).TotalSeconds -lt 60))
        if (-not $script:hasMusic) { $script:prevHas = $false; return }
        
        $script:BtnPlay.Text = [string][char]$(if ($script:playing) { 0xE769 } else { 0xE768 })
        
        $info = Await ($s.TryGetMediaPropertiesAsync()) ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])
        $changed = $false
        if ($info) {
            $key = "$($info.Title)|$($info.Artist)"
            if ($key -ne $script:lastTrack) {
                $script:lastTrack = $key
                $changed = $true
                $script:Title.Text = $info.Title
                $script:Artist.Text = $info.Artist
                $art = Load-Art $info
                $script:ArtBig.ImageSource = $art
                $script:ArtMini.ImageSource = $art
            }
        }
        
        $tl = $s.GetTimelineProperties()
        $dur = ($tl.EndTime - $tl.StartTime).TotalSeconds
        if ($dur -gt 0) {
            $pos = $tl.Position.TotalSeconds
            if ($script:playing) { $pos += ([DateTimeOffset]::Now - $tl.LastUpdatedTime).TotalSeconds }
            $script:Prog.Value = [Math]::Max(0, [Math]::Min(1, $pos / $dur))
        } else { $script:Prog.Value = 0 }
        
        if ($script:playing -and ($changed -or -not $script:prevHas)) { Start-Pop 'track' '' 3 }
        $script:prevHas = $true
    } catch {}
}

# --- Настройки ---
$script:source = ''
$script:cfgDir = Join-Path $env:APPDATA 'DynamicIsland'
$script:cfgFile = Join-Path $script:cfgDir 'settings.json'
$script:apps = @{}
$script:hideBanners = $false
$script:posMode = 'left'
$script:dockLocked = $false
$script:wantLeft = $false
$script:dock = 'top'
$script:dockBusy = $false
$script:hideInGames = $true
$script:clipPersist = $true
$script:copyMsgs = $true
$script:showNotifText = $true
$script:showStats = $true
$script:showMusic = $true
$script:clipFirst = $true
$script:pasteHeld = $false
$script:lastClipText = $null
$script:clipOpen = $false
$script:dndOpen = $false
$script:clipPaused = $false
$script:clipConfirm = $false
$script:clipSeq = 0
$script:clips = New-Object System.Collections.ArrayList
$script:gameHidden = $false
$script:backup = @{}
$script:regBase = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings'
$script:firstRun = -not (Test-Path -LiteralPath $script:cfgFile)
$script:setWin = $null

function Save-Settings {
    try {
        if (-not (Test-Path -LiteralPath $script:cfgDir)) { [void](New-Item -ItemType Directory -Path $script:cfgDir) }
        $o = @{
            hideBanners   = $script:hideBanners
            posMode       = $script:posMode
            dockLocked    = $script:dockLocked
            hideInGames   = $script:hideInGames
            clipPersist   = $script:clipPersist
            copyMsgs      = $script:copyMsgs
            showNotifText = $script:showNotifText
            showStats     = $script:showStats
            showMusic     = $script:showMusic
            apps          = @($script:apps.Values | ForEach-Object { @{ id = $_.Id; name = $_.Name; enabled = $_.Enabled } })
            backup        = @($script:backup.Keys | ForEach-Object { @{ id = $_; value = "$($script:backup[$_])" } })
        }
        ($o | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $script:cfgFile -Encoding UTF8
    } catch {}
}

function Load-Settings {
    try {
        if (-not (Test-Path -LiteralPath $script:cfgFile)) { return }
        $o = Get-Content -LiteralPath $script:cfgFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $script:hideBanners = [bool]$o.hideBanners
        if ($null -ne $o.copyMsgs) { $script:copyMsgs = [bool]$o.copyMsgs }
        if ($null -ne $o.clipPersist) { $script:clipPersist = [bool]$o.clipPersist }
        if ($null -ne $o.hideInGames) { $script:hideInGames = [bool]$o.hideInGames }
        if ($null -ne $o.dockLocked) { $script:dockLocked = [bool]$o.dockLocked }
        if ($null -ne $o.showNotifText) { $script:showNotifText = [bool]$o.showNotifText }
        if ($null -ne $o.showStats) { $script:showStats = [bool]$o.showStats }
        if ($null -ne $o.showMusic) { $script:showMusic = [bool]$o.showMusic }
        if ($o.posMode -eq 'center' -or $o.posMode -eq 'left') { $script:posMode = [string]$o.posMode }
        foreach ($x in @($o.apps)) { if ($x.id) { $script:apps[[string]$x.id] = [pscustomobject]@{ Id = [string]$x.id; Name = [string]$x.name; Enabled = [bool]$x.enabled } } }
        foreach ($x in @($o.backup)) { if ($x.id) { $script:backup[[string]$x.id] = [string]$x.value } }
    } catch {}
}

function Get-AppName($id) {
    if (-not $id) { return 'Уведомление' }
    $n = ($id -split '!')[0]
    $n = ($n -split '\\')[0]
    $parts = @($n -split '[./]' | Where-Object { $_ })
    if ($parts.Count -gt 0) { return $parts[-1] }
    return $id
}

function Set-Banner($id, $hide) {
    if ($id -match '[/]') { return }
    $path = "$($script:regBase)\$id"
    try {
        if ($hide) {
            if (-not $script:backup.ContainsKey($id)) {
                $cur = (Get-ItemProperty -LiteralPath $path -Name ShowBanner -ErrorAction SilentlyContinue).ShowBanner
                $script:backup[$id] = $(if ($null -eq $cur) { 'none' } else { "$cur" })
            }
            if (-not (Test-Path -LiteralPath $path)) { [void](New-Item -Path $path -Force) }
            Set-ItemProperty -LiteralPath $path -Name ShowBanner -Value 0 -Type DWord
        } elseif ($script:backup.ContainsKey($id)) {
            if ($script:backup[$id] -eq 'none') { Remove-ItemProperty -LiteralPath $path -Name ShowBanner -ErrorAction SilentlyContinue }
            else { Set-ItemProperty -LiteralPath $path -Name ShowBanner -Value ([int]$script:backup[$id]) -Type DWord }
            [void]$script:backup.Remove($id)
        }
    } catch {}
}

function Apply-Banners {
    $canHide = $script:hideBanners -and ($script:source -eq 'listener' -or $script:source -eq 'db')
    foreach ($a in @($script:apps.Values)) { Set-Banner $a.Id ($canHide -and $a.Enabled) }
    if (-not $canHide) { foreach ($k in @($script:backup.Keys)) { Set-Banner $k $false } }
    Save-Settings
}

function Discover-Apps {
    try {
        foreach ($k in (Get-ChildItem -LiteralPath $script:regBase -ErrorAction Stop)) {
            $id = $k.PSChildName
            if (-not $script:apps.ContainsKey($id)) { $script:apps[$id] = [pscustomobject]@{ Id = $id; Name = (Get-AppName $id); Enabled = $true } }
        }
    } catch {}
}

function Register-App($id, $name) {
    if (-not $script:apps.ContainsKey($id)) {
        $nm = $(if ($name) { $name } else { Get-AppName $id })
        $script:apps[$id] = [pscustomobject]@{ Id = $id; Name = $nm; Enabled = $true }
        Apply-Banners
    } elseif ($name -and $script:apps[$id].Name -ne $name) { $script:apps[$id].Name = $name }
    return $script:apps[$id]
}

function Enqueue-Notif($n) {
    if ($script:dnd) { $script:missed++; return }
    $script:queue.Enqueue($n)
    if ($script:pop -eq 'none') { Show-Notif ($script:queue.Dequeue()) }
}

function Show-Notif($n) {
    $script:NotifApp.Text = $n.App
    $script:NotifTitle.Text = $n.Title
    $script:NotifBody.Text = $n.Body
    if ($n.Icon) { $script:NotifIcon.ImageSource = $n.Icon }
    Start-Pop 'notif' $n.Key 5
}

function Handle-Incoming($id, $name, $title, $body, $icon, $key) {
    $enabled = $true
    if ($id) {
        $a = Register-App $id $name
        $enabled = $a.Enabled
        if (-not $name) { $name = $a.Name }
    } elseif ($name) {
        $m = $script:apps.Values | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($m) { $enabled = $m.Enabled }
    }
    if (-not $name) { $name = 'Уведомление' }
    if (-not $enabled) { return }
    Enqueue-Notif ([pscustomobject]@{ App = $name; Title = $title; Body = $body; Icon = $icon; Key = $key })
}

# --- Источники уведомлений ---
Load-Settings
Discover-Apps

try {
    [void][Windows.UI.Notifications.Management.UserNotificationListener, Windows.UI.Notifications.Management, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.Management.UserNotificationListenerAccessStatus, Windows.UI.Notifications.Management, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.UserNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.NotificationKinds, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.UI.Notifications.KnownNotificationBindings, Windows.UI.Notifications, ContentType = WindowsRuntime]
    [void][Windows.Foundation.Size, Windows.Foundation, ContentType = WindowsRuntime]
    
    $l = [Windows.UI.Notifications.Management.UserNotificationListener]::Current
    $st = Await ($l.RequestAccessAsync()) ([Windows.UI.Notifications.Management.UserNotificationListenerAccessStatus])
    if ("$st" -eq 'Allowed') { $script:listener = $l; $script:source = 'listener' }
} catch {}

$script:cs = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public class WpnRow { public long Order; public string AppId; public string Type; public string Payload; }
public static class WpnDb {
    const string L = "winsqlite3.dll";
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_open_v2(byte[] f, out IntPtr db, int flags, IntPtr vfs);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_close(IntPtr db);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_prepare_v2(IntPtr db, byte[] sql, int n, out IntPtr st, IntPtr tail);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_step(IntPtr st);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_finalize(IntPtr st);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_bind_int64(IntPtr st, int i, long v);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern long sqlite3_column_int64(IntPtr st, int i);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern IntPtr sqlite3_column_blob(IntPtr st, int i);
    [DllImport(L, CallingConvention = CallingConvention.Cdecl)] static extern int sqlite3_column_bytes(IntPtr st, int i);
    static byte[] Z(string s) { return Encoding.UTF8.GetBytes(s + "\0"); }
    static string Txt(IntPtr st, int i) {
        IntPtr p = sqlite3_column_blob(st, i);
        int n = sqlite3_column_bytes(st, i);
        if (p == IntPtr.Zero || n <= 0) return null;
        byte[] b = new byte[n];
        Marshal.Copy(p, b, 0, n);
        string s = (n > 1 && b[0] == 0xFF && b[1] == 0xFE) ? Encoding.Unicode.GetString(b) : Encoding.UTF8.GetString(b);
        return s.TrimStart('\uFEFF', '\0');
    }
    static IntPtr Open(string path, int flags, out string err) {
        IntPtr db; err = null;
        int rc = sqlite3_open_v2(Z(path), out db, flags, IntPtr.Zero);
        if (rc != 0) { err = "open rc=" + rc; if (db != IntPtr.Zero) sqlite3_close(db); return IntPtr.Zero; }
        return db;
    }
    public static long MaxOrder(string path, int flags, out string err) {
        IntPtr db = Open(path, flags, out err);
        if (db == IntPtr.Zero) return -1;
        try {
            IntPtr st;
            int rc = sqlite3_prepare_v2(db, Z("SELECT IFNULL(MAX(\"Order\"),0) FROM Notification"), -1, out st, IntPtr.Zero);
            if (rc != 0) { err = "prepare rc=" + rc; return -1; }
            long r = -1;
            if (sqlite3_step(st) == 100) r = sqlite3_column_int64(st, 0);
            sqlite3_finalize(st);
            return r;
        } finally { sqlite3_close(db); }
    }
    public static List<WpnRow> ReadAfter(string path, long after, int flags, out string err) {
        List<WpnRow> list = new List<WpnRow>();
        IntPtr db = Open(path, flags, out err);
        if (db == IntPtr.Zero) return list;
        try {
            IntPtr st;
            string q = "SELECT n.\"Order\", h.PrimaryId, n.Type, n.Payload FROM Notification n LEFT JOIN NotificationHandler h ON n.HandlerId = h.RecordId WHERE n.\"Order\" > ?1 ORDER BY n.\"Order\" LIMIT 50";
            int rc = sqlite3_prepare_v2(db, Z(q), -1, out st, IntPtr.Zero);
            if (rc != 0) { err = "prepare rc=" + rc; return list; }
            sqlite3_bind_int64(st, 1, after);
            while (sqlite3_step(st) == 100) {
                WpnRow r = new WpnRow();
                r.Order = sqlite3_column_int64(st, 0);
                r.AppId = Txt(st, 1);
                r.Type = Txt(st, 2);
                r.Payload = Txt(st, 3);
                list.Add(r);
            }
            sqlite3_finalize(st);
        } finally { sqlite3_close(db); }
        return list;
    }
}
'@

$script:dbOrig = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Notifications\wpndatabase.db'
$script:dbTmp = Join-Path $env:TEMP 'di_wpn.db'
$script:dbPath = $script:dbOrig; $script:dbFlags = 1; $script:dbCopy = $false; $script:dbLast = 0

function Copy-Db {
    try {
        Copy-Item -LiteralPath $script:dbOrig -Destination $script:dbTmp -Force
        if (Test-Path -LiteralPath "$($script:dbOrig)-wal") { Copy-Item -LiteralPath "$($script:dbOrig)-wal" -Destination "$($script:dbTmp)-wal" -Force }
        Remove-Item -LiteralPath "$($script:dbTmp)-shm" -Force -ErrorAction SilentlyContinue
    } catch {}
}

if (-not $script:source) {
    try {
        Add-Type -TypeDefinition $script:cs -Language CSharp
        $err = ''
        $m = [WpnDb]::MaxOrder($script:dbPath, 1, [ref]$err)
        if ($m -lt 0) {
            Copy-Db
            $script:dbPath = $script:dbTmp; $script:dbFlags = 2; $script:dbCopy = $true
            $m = [WpnDb]::MaxOrder($script:dbPath, 2, [ref]$err)
        }
        if ($m -ge 0) { $script:dbLast = $m; $script:source = 'db' }
    } catch {}
}

if (-not $script:source) {
    try {
        $script:uiaRoot = [Windows.Automation.AutomationElement]::RootElement
        $script:uiaCond = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ClassNameProperty, 'Windows.UI.Core.CoreWindow')
        $script:uiaText = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ControlTypeProperty, [Windows.Automation.ControlType]::Text)
        $script:source = 'uia'
    } catch { $script:source = 'none' }
}

if ($script:firstRun -and ($script:source -eq 'listener' -or $script:source -eq 'db')) { $script:hideBanners = $true }
Apply-Banners

function Poll-Notifications {
    if (-not $script:showNotifText) { return }
    if ($script:source -eq 'listener') {
        try {
            $list = Await ($script:listener.GetNotificationsAsync([Windows.UI.Notifications.NotificationKinds]::Toast)) ([System.Collections.Generic.IReadOnlyList[Windows.UI.Notifications.UserNotification]])
            if (-not $list) { return }
            foreach ($un in $list) {
                $id = [uint32]$un.Id
                if ($script:seen.Contains($id)) { continue }
                [void]$script:seen.Add($id)
                if ($script:firstScan) { continue }
                $b = $un.Notification.Visual.GetBinding([Windows.UI.Notifications.KnownNotificationBindings]::ToastGeneric)
                $texts = @($b.GetTextElements() | ForEach-Object { $_.Text })
                $icon = $null
                try { $icon = Load-Stream ($un.AppInfo.DisplayInfo.GetLogo([Windows.Foundation.Size]::new(48, 48))) } catch {}
                Handle-Incoming $un.AppInfo.AppUserModelId $un.AppInfo.DisplayInfo.DisplayName $texts[0] (($texts | Select-Object -Skip 1) -join ' ') $icon "n$id"
            }
            $script:firstScan = $false
        } catch {}
    }
    elseif ($script:source -eq 'db') {
        try {
            if ($script:dbCopy) { Copy-Db }
            $err = ''
            $rows = [WpnDb]::ReadAfter($script:dbPath, $script:dbLast, $script:dbFlags, [ref]$err)
            foreach ($r in $rows) {
                if ($r.Order -gt $script:dbLast) { $script:dbLast = $r.Order }
                if ($r.Type -ne 'toast' -or -not $r.Payload) { continue }
                try {
                    $xml = New-Object Xml.XmlDocument
                    $xml.LoadXml($r.Payload.Trim())
                    $texts = @($xml.SelectNodes('//binding/text') | Where-Object { $_.GetAttribute('placement') -ne 'attribution' } | ForEach-Object { $_.InnerText } | Where-Object { $_ })
                    if ($texts.Count -eq 0) { continue }
                    $icon = $null
                    try {
                        $img = $xml.SelectSingleNode("//binding/image[@placement='appLogoOverride']")
                        if ($img) {
                            $src = $img.GetAttribute('src')
                            if ($src -match '^file:') { $src = ([Uri]$src).LocalPath }
                            if ($src -and (Test-Path -LiteralPath $src)) {
                                $bmp = New-Object Windows.Media.Imaging.BitmapImage
                                $bmp.BeginInit(); $bmp.UriSource = [Uri]$src; $bmp.CacheOption = 'OnLoad'; $bmp.EndInit(); $bmp.Freeze()
                                $icon = $bmp
                            }
                        }
                    } catch {}
                    Handle-Incoming $r.AppId $null $texts[0] (($texts | Select-Object -Skip 1) -join ' ') $icon "d$($r.Order)"
                } catch {}
            }
        } catch {}
    }
    elseif ($script:source -eq 'uia') {
        try {
            $now = Get-Date
            foreach ($k in @($script:uiaSeen.Keys)) { if (($now - $script:uiaSeen[$k]).TotalSeconds -gt 15) { $script:uiaSeen.Remove($k) } }
            $wins = $script:uiaRoot.FindAll([Windows.Automation.TreeScope]::Children, $script:uiaCond)
            foreach ($w in $wins) {
                if ($w.Current.Name -notmatch 'уведомл|notification') { continue }
                $texts = @($w.FindAll([Windows.Automation.TreeScope]::Descendants, $script:uiaText) | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
                if ($texts.Count -eq 0) { continue }
                $key = $texts -join '|'
                if ($script:uiaSeen.ContainsKey($key)) { continue }
                $script:uiaSeen[$key] = $now
                Handle-Incoming $null $texts[0] $(if ($texts.Count -gt 1) { $texts[1] } else { '' }) (($texts | Select-Object -Skip 2) -join ' ') $null "u$key"
            }
        } catch {}
    }
}

# --- Буфер обмена ---
$script:clipFile = Join-Path $script:cfgDir 'clipboard.json'

function Save-Clips {
    try {
        if (-not $script:clipPersist) { Remove-Item -LiteralPath $script:clipFile -Force -ErrorAction SilentlyContinue; return }
        if (-not (Test-Path -LiteralPath $script:cfgDir)) { [void](New-Item -ItemType Directory -Path $script:cfgDir) }
        $arr = @($script:clips | ForEach-Object { @{ t = $_.Text; d = $_.Time } })
        (ConvertTo-Json -InputObject $arr -Depth 3) | Set-Content -LiteralPath $script:clipFile -Encoding UTF8
    } catch {}
}

function Load-Clips {
    try {
        if (-not $script:clipPersist -or -not (Test-Path -LiteralPath $script:clipFile)) { return }
        $o = Get-Content -LiteralPath $script:clipFile -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($x in @($o)) { if ($x.t) { [void]$script:clips.Add([pscustomobject]@{ Text = [string]$x.t; Time = [string]$x.d }) } }
    } catch {}
}

function Add-Clip($text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return }
    if ($text.Length -gt 5000) { $text = $text.Substring(0, 5000) }
    for ($i = $script:clips.Count - 1; $i -ge 0; $i--) { if ($script:clips[$i].Text -eq $text) { $script:clips.RemoveAt($i) } }
    $script:clips.Insert(0, [pscustomobject]@{ Text = $text; Time = (Get-Date).ToString('s') })
    while ($script:clips.Count -gt 100) { $script:clips.RemoveAt($script:clips.Count - 1) }
    Save-Clips
    if ($script:clipOpen) { Fill-Clips }
}

function Get-Preview($t, $n = 38) {
    $p = ($t -replace '\s+', ' ').Trim()
    if ($p.Length -gt $n) { return $p.Substring(0, $n) + '…' }
    return $p
}

function Get-ClipInfo {
    if ([Windows.Clipboard]::ContainsText()) { return (Get-Preview ([Windows.Clipboard]::GetText())) }
    if ([Windows.Clipboard]::ContainsImage()) { return 'Изображение' }
    if ([Windows.Clipboard]::ContainsFileDropList()) { return ('Файлы: ' + [Windows.Clipboard]::GetFileDropList().Count) }
    return $null
}

function Show-Msg($kind, $sub) {
    if (-not $script:copyMsgs -or $script:gameHidden -or $script:dnd) { return }
    if ($script:pop -eq 'notif' -or $script:pop -eq 'text') { return }
    
    if ($kind -eq 'copy') {
        $script:MsgTitle.Text = 'Скопировано'
        $script:MsgGlyph.Text = [string][char]0xE8C8
        $col = [Windows.Media.Color]::FromRgb(48, 209, 88)
    } else {
        $script:MsgTitle.Text = 'Вставлено'
        $script:MsgGlyph.Text = [string][char]0xE77F
        $col = [Windows.Media.Color]::FromRgb(10, 132, 255)
    }
    
    $script:MsgSub.Text = $sub
    $script:MsgSub.Visibility = $(if ($sub) { 'Visible' } else { 'Collapsed' })
    $script:MsgIcon.Background = New-Object Windows.Media.SolidColorBrush ($col)
    
    Start-Pop 'msg' ($kind + [Environment]::TickCount) 1.8
    
    $st = $script:MsgIcon.RenderTransform
    $ease = New-Object Windows.Media.Animation.BackEase
    $ease.EasingMode = 'EaseOut'; $ease.Amplitude = 0.7
    $dur = New-Object Windows.Duration ([TimeSpan]::FromMilliseconds(420))
    $a1 = New-Object Windows.Media.Animation.DoubleAnimation(0.3, 1.0, $dur); $a1.EasingFunction = $ease
    $a2 = New-Object Windows.Media.Animation.DoubleAnimation(0.3, 1.0, $dur); $a2.EasingFunction = $ease
    $st.BeginAnimation([Windows.Media.ScaleTransform]::ScaleXProperty, $a1)
    $st.BeginAnimation([Windows.Media.ScaleTransform]::ScaleYProperty, $a2)
}

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

function Poll-Clipboard {
    try {
        if ($script:fgOk) {
            $seq = [Fg]::ClipSeq()
            if ($seq -eq $script:clipSeq) { return }
            $script:clipSeq = $seq
        }
        
        $silent = $script:clipFirst
        $script:clipFirst = $false
        $sub = $null
        
        if ([Windows.Clipboard]::ContainsText()) {
            $txt = [Windows.Clipboard]::GetText()
            if (-not $script:fgOk) {
                if ($txt -eq $script:lastClipText) { return }
                $script:lastClipText = $txt
            }
            if (-not $script:clipPaused) { Add-Clip $txt }
            $sub = Get-Preview $txt
        } else {
            $sub = Get-ClipInfo
            if (-not $sub) { return }
        }
        
        if ($script:clipPaused) { $sub = 'запись истории на паузе' }
        if (-not $silent) { Show-Msg 'copy' $sub }
    } catch { $script:clipSeq = 0 }
}

function Poll-Keys {
    if (-not $script:fgOk) { return }
    $held = (([Fg]::KeyDown(0x11) -and [Fg]::KeyDown(0x56)) -or ([Fg]::KeyDown(0x10) -and [Fg]::KeyDown(0x2D)))
    if ($held -and -not $script:pasteHeld) {
        try { $info = Get-ClipInfo; if ($info) { Show-Msg 'paste' $info } } catch {}
    }
    $script:pasteHeld = $held
}

$script:clipFlashTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipFlashTimer.Add_Tick({
    $script:clipFlashTimer.Stop()
    $script:clipConfirm = $false
    Update-ClipTitle
})

function Update-ClipTitle {
    $side = ($script:dock -eq 'left')
    $t = $(if ($side) { '📋' } else { '📋 Буфер обмена' })
    if ($script:clipPaused) { $t += $(if ($side) { ' ⏸' } else { ' (пауза)' }) }
    $script:ClipTitle.Text = $t
    $script:ClipPause.Text = $(if ($script:clipPaused) { '▶' } else { '⏸' })
}

function Flash-ClipTitle($text, $ms) {
    $script:ClipTitle.Text = $text
    $script:clipFlashTimer.Stop()
    $script:clipFlashTimer.Interval = [TimeSpan]::FromMilliseconds($ms)
    $script:clipFlashTimer.Start()
}

function Copy-Clip($c) {
    try {
        [Windows.Clipboard]::SetText($c.Text)
        if ($script:fgOk) { $script:clipSeq = [Fg]::ClipSeq() }
        [void]$script:clips.Remove($c)
        $script:clips.Insert(0, $c)
        Save-Clips
        Fill-Clips
        Flash-ClipTitle '✓ Скопировано' 1200
    } catch { Flash-ClipTitle 'Не удалось скопировать' 1500 }
}

function Remove-Clip($c) {
    [void]$script:clips.Remove($c)
    Save-Clips
    Fill-Clips
}

function Fill-Clips {
    $script:ClipList.Children.Clear()
    if ($script:clips.Count -eq 0) {
        $e = New-Object Windows.Controls.TextBlock
        $e.Text = 'Пока пусто. Скопируйте любой текст.'
        $e.Foreground = [Windows.Media.Brushes]::Gray
        $e.FontSize = 12; $e.TextWrapping = 'Wrap'; $e.Margin = Th 0 10 0 0; $e.TextAlignment = 'Center'
        [void]$script:ClipList.Children.Add($e)
        return
    }
    
    $itemBg = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(28, 28, 30))
    $txtFg = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(237, 237, 237))
    
    foreach ($c in $script:clips) {
        $b = New-Object Windows.Controls.Border
        $b.Background = $itemBg; $b.CornerRadius = New-Object Windows.CornerRadius(8)
        $b.Margin = Th 0 0 0 4; $b.Padding = Th 8 5 6 5; $b.Cursor = [Windows.Input.Cursors]::Hand; $b.Tag = $c
        
        $g = New-Object Windows.Controls.Grid
        $c1 = New-Object Windows.Controls.ColumnDefinition
        $c2 = New-Object Windows.Controls.ColumnDefinition; $c2.Width = [Windows.GridLength]::Auto
        $g.ColumnDefinitions.Add($c1); $g.ColumnDefinitions.Add($c2)
        
        $t = New-Object Windows.Controls.TextBlock
        $p = ($c.Text -replace '\s+', ' ').Trim()
        if ($p.Length -gt 160) { $p = $p.Substring(0, 160) + '…' }
        $t.Text = $p; $t.Foreground = $txtFg; $t.FontSize = 12
        $t.TextWrapping = 'Wrap'; $t.MaxHeight = 32; $t.TextTrimming = 'CharacterEllipsis'
        $t.VerticalAlignment = 'Center'
        
        $x = New-Object Windows.Controls.TextBlock
        $x.Text = '✕'; $x.Foreground = [Windows.Media.Brushes]::Gray; $x.FontSize = 11
        $x.Padding = Th 8 2 2 2; $x.Cursor = [Windows.Input.Cursors]::Hand; $x.Tag = $c
        $x.VerticalAlignment = 'Top'; $x.Background = [Windows.Media.Brushes]::Transparent
        
        [Windows.Controls.Grid]::SetColumn($x, 1)
        [void]$g.Children.Add($t); [void]$g.Children.Add($x)
        $b.Child = $g
        
        $b.Add_MouseLeftButtonUp({ Copy-Clip $this.Tag })
        $x.Add_MouseLeftButtonUp({ $args[1].Handled = $true; Remove-Clip $this.Tag })
        [void]$script:ClipList.Children.Add($b)
    }
}

$script:clipOpenTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipOpenTimer.Interval = [TimeSpan]::FromMilliseconds(180)
$script:clipOpenTimer.Add_Tick({
    $script:clipOpenTimer.Stop()
    if ($script:BtnClipBar.IsMouseOver -or $script:BtnClipM.IsMouseOver) { $script:clipOpen = $true; Update-ClipIsland }
})

$script:clipLeaveTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipLeaveTimer.Interval = [TimeSpan]::FromMilliseconds(400)
$script:clipLeaveTimer.Add_Tick({
    $script:clipLeaveTimer.Stop()
    if (-not $script:BtnClipBar.IsMouseOver -and -not $script:BtnClipM.IsMouseOver -and -not $script:ClipIsland.IsMouseOver) {
        $script:clipOpen = $false
        Update-ClipIsland
    }
})

foreach ($n in @($script:BtnClipBar, $script:BtnClipM)) {
    $n.Add_MouseEnter({ $script:clipLeaveTimer.Stop(); $script:clipOpenTimer.Stop(); $script:clipOpenTimer.Start() })
    $n.Add_MouseLeave({ $script:clipOpenTimer.Stop(); if ($script:clipOpen) { $script:clipLeaveTimer.Stop(); $script:clipLeaveTimer.Start() } })
    $n.Add_MouseLeftButtonUp({ $script:clipOpen = $true; Update-ClipIsland })
}

$script:ClipIsland.Add_MouseEnter({ $script:clipLeaveTimer.Stop() })
$script:ClipIsland.Add_MouseLeave({ if ($script:clipOpen) { $script:clipLeaveTimer.Stop(); $script:clipLeaveTimer.Start() } })
$script:ClipClose.Add_MouseLeftButtonUp({ $script:clipOpen = $false; Update-ClipIsland })
$script:ClipPause.Add_MouseLeftButtonUp({ $script:clipPaused = -not $script:clipPaused; Update-ClipTitle })
$script:ClipClear.Add_MouseLeftButtonUp({
    if ($script:clipConfirm) {
        $script:clips.Clear(); Save-Clips; Fill-Clips
        $script:clipConfirm = $false
        Flash-ClipTitle '✓ Очищено' 1200
    } else {
        $script:clipConfirm = $true
        Flash-ClipTitle 'Очистить всё? Ещё раз 🗑' 3000
    }
})

Load-Clips

$script:clipTimer = New-Object Windows.Threading.DispatcherTimer
$script:clipTimer.Interval = [TimeSpan]::FromMilliseconds(800)
$script:clipTimer.Add_Tick({ Poll-Clipboard })

$script:keyTimer = New-Object Windows.Threading.DispatcherTimer
$script:keyTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$script:keyTimer.Add_Tick({ Poll-Keys })

# --- Положение острова ---
$script:fgcs = @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class Fg {
    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] static extern int GetWindowLong(IntPtr h, int i);
    [DllImport("shell32.dll")] static extern int SHQueryUserNotificationState(out int s);
    [DllImport("user32.dll")] static extern uint GetClipboardSequenceNumber();
    public static uint ClipSeq() { return GetClipboardSequenceNumber(); }
    [DllImport("user32.dll")] static extern short GetAsyncKeyState(int vk);
    public static bool KeyDown(int vk) { return (GetAsyncKeyState(vk) & 0x8000) != 0; }
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
    [DllImport("dwmapi.dll")] static extern int DwmGetWindowAttribute(IntPtr h, int attr, out int v, int size);
    delegate bool EnumProc(IntPtr h, IntPtr l);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
    static string Pack(IntPtr h, string cls, uint pid, RECT r) {
        int caption = GetWindowLong(h, -16) & 0x00C00000;
        return cls + "|" + pid + "|" + r.L + "|" + r.T + "|" + r.R + "|" + r.B + "|" + caption;
    }
    public static string Top() {
        string result = null;
        uint me = (uint)System.Diagnostics.Process.GetCurrentProcess().Id;
        EnumWindows(delegate(IntPtr h, IntPtr l) {
            if (!IsWindowVisible(h) || IsIconic(h)) return true;
            int cloaked; if (DwmGetWindowAttribute(h, 14, out cloaked, 4) == 0 && cloaked != 0) return true;
            uint pid; GetWindowThreadProcessId(h, out pid);
            if (pid == me) return true;
            StringBuilder sb = new StringBuilder(256); GetClassName(h, sb, 256);
            string cls = sb.ToString();
            RECT r; if (!GetWindowRect(h, out r)) return true;
            if (cls == "Progman" || cls == "WorkerW") { result = Pack(h, "Progman", pid, r); return false; }
            if (cls == "Shell_TrayWnd" || cls == "Shell_SecondaryTrayWnd" || cls == "Windows.UI.Core.CoreWindow" ||
                cls == "NotifyIconOverflowWindow" || cls == "XamlExplorerHostIslandWindow" ||
                cls == "TopLevelWindowForOverflowXamlIsland" || cls == "Shell_InputSwitchTopLevelWindow") return true;
            int ex = GetWindowLong(h, -20);
            if ((ex & 0x80) != 0 && (ex & 0x40000) == 0) return true;
            if (r.R - r.L < 50 || r.B - r.T < 30) return true;
            result = Pack(h, cls, pid, r); return false;
        }, IntPtr.Zero);
        return result;
    }
    public static int Qun() { int s; if (SHQueryUserNotificationState(out s) != 0) return 0; return s; }
    public static string Get() {
        IntPtr h = GetForegroundWindow();
        if (h == IntPtr.Zero) return null;
        RECT r; if (!GetWindowRect(h, out r)) return null;
        StringBuilder sb = new StringBuilder(256);
        GetClassName(h, sb, 256);
        uint pid; GetWindowThreadProcessId(h, out pid);
        int caption = GetWindowLong(h, -16) & 0x00C00000;
        return sb.ToString() + "|" + pid + "|" + r.L + "|" + r.T + "|" + r.R + "|" + r.B + "|" + caption;
    }
}
'@

$script:fgOk = $false
try { Add-Type -TypeDefinition $script:fgcs -Language CSharp; $script:fgOk = $true } catch {}

function Layout-Dock($mode) {
    $W = [Windows.SystemParameters]::PrimaryScreenWidth
    $H = [Windows.SystemParameters]::PrimaryScreenHeight
    if ($mode -eq 'left') {
        $script:win.Width = 390; $script:win.Height = 390
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

# --- Окно настроек ---
$script:setXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="Настройки Dynamic Island" Width="480" Height="780" WindowStartupLocation="CenterScreen"
Background="#FF1C1C1E" Foreground="White" ResizeMode="CanResizeWithGrip">
 <Grid Margin="16">
 <Grid.RowDefinitions>
 <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/>
 <RowDefinition Height="*"/> <RowDefinition Height="Auto"/>
 </Grid.RowDefinitions>
 <TextBlock x:Name="SrcText" Grid.Row="0" Foreground="#FF9A9AA0" TextWrapping="Wrap" FontSize="12"/>
 <StackPanel Grid.Row="1" Margin="0,10,0,0">
 <CheckBox x:Name="HideChk" Foreground="White" Margin="0,2,0,2"
Content="Скрывать обычные баннеры Windows для выбранных приложений"/>
 <CheckBox x:Name="ShowNotifTextChk" Foreground="White" Margin="0,4,0,2"
Content="Показывать текст и заголовки входящих уведомлений"/>
 <CheckBox x:Name="ShowStatsChk" Foreground="White" Margin="0,2,0,2"
Content="Показывать батарею, CPU и RAM в развёрнутом виде"/>
 <CheckBox x:Name="ShowMusicChk" Foreground="White" Margin="0,2,0,2"
Content="Включить музыкальный плеер на острове"/>
 <CheckBox x:Name="CopyMsgChk" Foreground="White" Margin="0,2,0,2"
Content="Показывать «Скопировано» и «Вставлено» на острове"/>
 <CheckBox x:Name="ClipChk" Foreground="White" Margin="0,2,0,2"
Content="Сохранять историю буфера обмена на диск"/>
 <CheckBox x:Name="GameChk" Foreground="White" Margin="0,2,0,6"
Content="Прятать остров в играх и полноэкранных окнах"/>
 <CheckBox x:Name="DndChk" Foreground="White" Margin="0,2,0,6"
Content="Не беспокоить (остров не показывает уведомления)"/>
 <CheckBox x:Name="LockChk" Foreground="White" Margin="0,2,0,6"
Content="🔒 Закрепить текущее положение острова"/>
  <TextBlock Text="Положение острова:" Margin="0,6,0,4" FontWeight="SemiBold"/>
   <ComboBox x:Name="PosBox">
     <ComboBoxItem Tag="center" Content="Всегда сверху по центру"/>
     <ComboBoxItem Tag="left" Content="Уходить на левый бок (повёрнутым), когда открыто другое окно"/>
   </ComboBox>
 </StackPanel>
 <StackPanel Grid.Row="2" Margin="0,12,0,6">
   <TextBlock Text="Показывать на острове уведомления от:" FontWeight="SemiBold" Margin="0,0,0,6"/>
   <TextBox x:Name="Filter" Padding="4" Background="#FF2C2C2E" Foreground="White" BorderBrush="#FF3A3A3C" CaretBrush="White"/>
 </StackPanel>
 <ScrollViewer Grid.Row="3" VerticalScrollBarVisibility="Auto">
   <StackPanel x:Name="AppList"/>
 </ScrollViewer>
 <WrapPanel Grid.Row="4" Margin="0,12,0,0">
   <Button x:Name="BtnAll" Content="Выбрать все" Padding="10,4" Margin="0,0,8,0"/>
   <Button x:Name="BtnNone" Content="Снять все" Padding="10,4" Margin="0,0,8,0"/>
   <Button x:Name="BtnTest" Content="Тест" Padding="10,4" Margin="0,0,8,0"/>
   <Button x:Name="BtnRestore" Content="Вернуть баннеры Windows" Padding="10,4" Margin="0,0,8,0"/>
   <Button x:Name="BtnClipClear" Content="Очистить буфер" Padding="10,4"/>
 </WrapPanel>
</Grid>
</Window>
'@

function Fill-List {
    if (-not $script:setWin) { return }
    $f = $script:SetFilter.Text.Trim().ToLower()
    $script:SetList.Children.Clear()
    foreach ($a in ($script:apps.Values | Sort-Object Name)) {
        if ($f -and -not ($a.Name.ToLower().Contains($f) -or $a.Id.ToLower().Contains($f))) { continue }
        $cb = New-Object Windows.Controls.CheckBox
        $cb.Content = "$($a.Name)   ($($a.Id))"
        $cb.Tag = $a.Id
        $cb.IsChecked = $a.Enabled
        $cb.Margin = '0,3,0,3'
        $cb.Foreground = [Windows.Media.Brushes]::White
        $cb.Add_Click({ $script:apps[[string]$this.Tag].Enabled = [bool]$this.IsChecked; Apply-Banners })
        [void]$script:SetList.Children.Add($cb)
    }
}

function Open-Settings {
    if ($script:setWin) { $script:setWin.Activate(); return }
    Discover-Apps
    $w = [Windows.Markup.XamlReader]::Parse($script:setXaml)
    $script:setWin = $w
    $script:SetList = $w.FindName('AppList')
    $script:SetFilter = $w.FindName('Filter')
    $hide = $w.FindName('HideChk')
    $srcNames = @{ listener = 'системный доступ к уведомлениям'; db = 'база уведомлений Windows'; uia = 'перехват всплывающих окон (запасной режим)'; none = 'недоступны' }
    $w.FindName('SrcText').Text = 'Источник уведомлений: ' + $srcNames[$script:source]
    $hide.IsChecked = $script:hideBanners
    if ($script:source -ne 'listener' -and $script:source -ne 'db') {
        $hide.IsEnabled = $false
        $hide.Content = $hide.Content + ' (недоступно в этом режиме)'
    }
    $dc = $w.FindName('DndChk')
    $dc.IsChecked = $script:dnd
    $dc.Add_Click({ Set-Dnd ([bool]$this.IsChecked) 0 })
    $lc = $w.FindName('LockChk')
    $lc.IsChecked = $script:dockLocked
    $lc.Add_Click({ $script:dockLocked = [bool]$this.IsChecked; Save-Settings; Update-Position })
    $cm = $w.FindName('CopyMsgChk')
    $cm.IsChecked = $script:copyMsgs
    $cm.Add_Click({ $script:copyMsgs = [bool]$this.IsChecked; Save-Settings })
    $snt = $w.FindName('ShowNotifTextChk')
    $snt.IsChecked = $script:showNotifText
    $snt.Add_Click({ $script:showNotifText = [bool]$this.IsChecked; Save-Settings })
    $sst = $w.FindName('ShowStatsChk')
    $sst.IsChecked = $script:showStats
    $sst.Add_Click({ $script:showStats = [bool]$this.IsChecked; Save-Settings; $script:BigR.Visibility = $(if ($script:showStats) { 'Visible' } else { 'Collapsed' }) })
    $smc = $w.FindName('ShowMusicChk')
    $smc.IsChecked = $script:showMusic
    $smc.Add_Click({ $script:showMusic = [bool]$this.IsChecked; Save-Settings })
    $cc = $w.FindName('ClipChk')
    $cc.IsChecked = $script:clipPersist
    $cc.Add_Click({ $script:clipPersist = [bool]$this.IsChecked; Save-Settings; Save-Clips })
    $w.FindName('BtnClipClear').Add_Click({ $script:clips.Clear(); Save-Clips; if ($script:clipOpen) { Fill-Clips } })
    $gc = $w.FindName('GameChk')
    $gc.IsChecked = $script:hideInGames
    $gc.Add_Click({ $script:hideInGames = [bool]$this.IsChecked; Save-Settings; Update-Position })
    $pos = $w.FindName('PosBox')
    $pos.SelectedIndex = $(if ($script:posMode -eq 'center') { 0 } else { 1 })
    $pos.Add_SelectionChanged({
        $script:posMode = [string]$this.SelectedItem.Tag
        Save-Settings
        Update-Position
    })
    $hide.Add_Click({ $script:hideBanners = [bool]$this.IsChecked; Apply-Banners })
    $script:SetFilter.Add_TextChanged({ Fill-List })
    $w.FindName('BtnAll').Add_Click({ foreach ($a in @($script:apps.Values)) { $a.Enabled = $true }; Apply-Banners; Fill-List })
    $w.FindName('BtnNone').Add_Click({ foreach ($a in @($script:apps.Values)) { $a.Enabled = $false }; Apply-Banners; Fill-List })
    $w.FindName('BtnTest').Add_Click({
        Enqueue-Notif ([pscustomobject]@{ App = 'Dynamic Island'; Title = 'Тестовое уведомление'; Body = 'Если вы это видите, остров работает'; Icon = $null; Key = ('t' + (Get-Date).Ticks) })
    })
    $w.FindName('BtnRestore').Add_Click({
        $script:hideBanners = $false
        foreach ($k in @($script:backup.Keys)) { Set-Banner $k $false }
        Save-Settings
        $h = $script:setWin.FindName('HideChk'); $h.IsChecked = $false
    })
    $w.Add_Closed({ $script:setWin = $null })
    Fill-List
    $w.Show()
}

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

switch ($script:source) {
    'listener' { Start-Pop 'text' '🔔 Уведомления: система' 3 }
    'db'       { Start-Pop 'text' '🔔 Уведомления: база Windows' 3 }
    'uia'      { Start-Pop 'text' '🔔 Уведомления: перехват' 3 }
    default    { Start-Pop 'text' '⚠ Уведомления недоступны' 3 }
}

$app = New-Object Windows.Application
$app.ShutdownMode = 'OnMainWindowClose'
[void]$app.Run($script:win)