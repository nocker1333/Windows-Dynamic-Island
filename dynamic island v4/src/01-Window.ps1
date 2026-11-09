# Создание главного окна и привязка элементов
$xaml = Get-Content -LiteralPath (Join-Path $script:srcDir 'MainWindow.xaml') -Raw -Encoding UTF8

$script:win = [Windows.Markup.XamlReader]::Parse($xaml)
foreach ($n in 'Island','Small','Big','Mini','BigMusic','BigTime','BigDate','BigDndStatus','Bat','Cpu','Ram','ArtMini','ArtBig','Title','Artist','Prog','BtnPrev','BtnPlay','BtnNext','Bar1','Bar2','Bar3','Bar4','Notif','NotifIcon','NotifApp','NotifTitle','NotifBody','BigL','BigR','MiniArt','MiniBars','MusicArt','MusicText','NotifArt','NotifText','DndBar','DndLabel','DndSwitch','DndKnob','BtnDnd','BtnDndClock','Clip','ClipTitle','ClipPause','ClipClear','ClipClose','ClipScroll','ClipList','BtnClipM','BtnClipBar','BtnScreenBar','BtnScreenM','Msg','MsgIcon','MsgGlyph','MsgText','MsgTitle','MsgSub','Root','ClipIsland','DndIsland','DndClose','DndMenu15','DndMenu30','DndMenu60','DndMenu120','DndMenuMorning','DndMenuReset','ScreenIsland','ScreenIcon','ClipTranslate','DndTranslate') {
    Set-Variable -Scope Script -Name $n -Value ($script:win.FindName($n))
}

$script:bars = @($script:Bar1, $script:Bar2, $script:Bar3, $script:Bar4)
$script:win.Left = ([Windows.SystemParameters]::PrimaryScreenWidth - $script:win.Width) / 2
$script:win.Top  = 0
$script:Rot = New-Object Windows.Media.RotateTransform(0)
$script:Island.LayoutTransform = $script:Rot
$script:ru = [Globalization.CultureInfo]::GetCultureInfo('ru-RU')

