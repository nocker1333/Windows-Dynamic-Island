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

