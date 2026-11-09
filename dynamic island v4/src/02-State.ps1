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

