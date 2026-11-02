# Verify gate (Claude Code Stop / SubagentStop hook). Generic: works for any UE5 project.
# Runs when an agent tries to finish and sends it back while any of these is true:
#   1. C++ changed since the last good build and the build fails (editor closed), or the
#      change was never compiled (editor open, no successful Live Coding since)
#   2. the editor crashed since the last check (crash report in Saved\Crashes)
#   3. new error lines in the editor log (compile, runtime, Python, Live Coding, asserts)
# After 3 blocked attempts it lets the agent stop, but tells it to report to the designer.
# Windows PowerShell 5.1 compatible, ASCII only.

$ErrorActionPreference = 'Continue'
$MaxAttempts = 3
$MaxLines = 25

function Allow { exit 0 }
function Block([string]$reason) {
    [Console]::Out.Write((@{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress))
    exit 0
}

try { $null = [Console]::In.ReadToEnd() } catch {}   # hook input: not needed

. (Join-Path $PSScriptRoot '..\scripts\ue-common.ps1')
$root = Get-UEProjectDir
$uproject = Get-UEProject $root
if (-not $uproject) { Allow }               # no Unreal project yet: nothing to check
$proj = $uproject.DirectoryName
$name = $uproject.BaseName

# --- state -------------------------------------------------------------------
$stateFile = Join-Path (Get-StateDir $proj) 'state.json'
$firstRun = -not (Test-Path $stateFile)     # first run: the current log and crashes are the baseline
$nowTicks = (Get-Date).ToUniversalTime().Ticks
# Times are stored as ticks (numbers), so PowerShell 5.1 and 7 read them back the same way.
$state = [ordered]@{ logHead = ''; logOffset = 0; crashTicks = $nowTicks; attempts = 0; escalated = $false }
if (-not $firstRun) {
    try {
        $s = Get-Content $stateFile -Raw | ConvertFrom-Json
        foreach ($k in @('logHead','logOffset','crashTicks','attempts','escalated')) {
            if ($null -ne $s.$k) { $state[$k] = $s.$k }
        }
    } catch {}
}
function SaveState { $state | ConvertTo-Json | Set-Content -Path $stateFile -Encoding UTF8 }

# The agent was told to stop and report after too many tries: let it finish once.
if ($state.escalated) { $state.escalated = $false; $state.attempts = 0; SaveState; Allow }

$ignore = @()
$ignoreFile = Join-Path $PSScriptRoot 'verify-ignore.txt'
if (Test-Path $ignoreFile) { $ignore = Get-Content $ignoreFile | Where-Object { $_ -and -not $_.StartsWith('#') } }
function IsIgnored([string]$line) { foreach ($re in $ignore) { if ($line -match $re) { return $true } }; return $false }

$problems = New-Object System.Collections.Generic.List[string]

# --- read the new part of the editor log ------------------------------------
$logPath = Join-Path $proj ("Saved\Logs\" + $name + '.log')
$text = ''; $logEnd = [int64]0
if (Test-Path $logPath) {
    $offset = [int64]$state.logOffset; $head = ''
    try {
        $fs = [System.IO.File]::Open($logPath, 'Open', 'Read', 'ReadWrite')
        $sr = New-Object System.IO.StreamReader($fs)
        $head = [string]$sr.ReadLine()   # "Log file open, <date>": changes on each editor start
        if ($head -ne [string]$state.logHead -or $offset -gt $fs.Length) { $offset = 0 }
        if ($firstRun) { $offset = $fs.Length }
        $null = $fs.Seek($offset, 'Begin'); $sr.DiscardBufferedData()
        $text = $sr.ReadToEnd()
        $logEnd = $fs.Length
        $sr.Close(); $fs.Close()
    } catch { $logEnd = $offset }
    $state.logHead = $head
}

# --- 1. C++ ------------------------------------------------------------------
$sourceTicks = Get-NewestSourceTicks $proj
if ($text -match 'Live coding succeeded') { Set-GoodBuildTicks $proj $sourceTicks }
if ($sourceTicks -gt (Get-GoodBuildTicks $proj)) {
    if (Get-EditorProcess $uproject) {
        $problems.Add('[C++] Source changed but was never compiled. Save all, run .claude\scripts\close-editor.ps1, then .claude\scripts\build.ps1, fix every error, then .claude\scripts\launch-editor.ps1 and smoke-test. (For a small .cpp-only edit, a successful Live Coding compile also counts.)')
    } else {
        $r = Invoke-UEBuild $uproject $proj $MaxLines
        if ($r.Code -ne 0) { foreach ($e in $r.Errors) { $problems.Add('[C++] ' + $e) } }
    }
}

# --- 2. crashes --------------------------------------------------------------
if (-not $firstRun) {
    foreach ($c in (Get-NewCrashes $proj ([int64]$state.crashTicks))) { $problems.Add($c) }
}
$state.crashTicks = $nowTicks

# --- 3. new log errors -------------------------------------------------------
$seen = [ordered]@{}
foreach ($line in ($text -split "`r?`n")) {
    if (-not $line) { continue }
    $hit = ($line -match ':\s*Error:') -or ($line -match 'Blueprint Runtime Error') -or
           ($line -match 'Accessed None') -or ($line -match 'Live coding failed') -or
           ($line -match 'Assertion failed') -or ($line -match 'Critical error') -or
           ($line -match 'Ensure condition failed')
    if (-not $hit -or (IsIgnored $line)) { continue }
    $clean = ($line -replace '^\[[^\]]*\]\[[^\]]*\]', '').Trim()   # drop [time][frame]
    if ($seen.Contains($clean)) { $seen[$clean]++ } else { $seen[$clean] = 1 }
}
foreach ($k in $seen.Keys) {
    if ($problems.Count -ge $MaxLines) { break }
    if ($seen[$k] -gt 1) { $problems.Add("$k  (x$($seen[$k]))") } else { $problems.Add($k) }
}

$state.logOffset = [int64]$logEnd

# --- decision ----------------------------------------------------------------
if ($problems.Count -eq 0) { $state.attempts = 0; SaveState; Allow }

$state.attempts = [int]$state.attempts + 1
$list = ($problems | ForEach-Object { '- ' + $_ }) -join "`n"
if ($state.attempts -ge $MaxAttempts) {
    $state.escalated = $true; SaveState
    Block ("Verify gate: errors remain after $MaxAttempts attempts. Stop fixing now. In your final message to the designer, list each remaining error (exact text, file and line or asset), what you tried, and your best guess of the cause. Then finish.`n" + $list)
}
SaveState
Block ("Verify gate (attempt $($state.attempts) of $MaxAttempts): problems found since your last check. Fix the cause, rebuild (C++) or recompile (Blueprint), run the check that failed again, then finish. Never hide an error to pass this check.`n" + $list)
