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

