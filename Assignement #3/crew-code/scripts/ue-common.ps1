# Shared helpers for the agent scripts and the verify gate. Generic: works for any UE5
# project folder holding one .uproject. Windows PowerShell 5.1 compatible, ASCII only.

function Get-UEProjectDir {
    $p = $env:CLAUDE_PROJECT_DIR
    if ($p) {
        # Git Bash style /c/Users/... -> C:\Users\...
        if ($p -match '^/([a-zA-Z])/(.*)$') { $p = $Matches[1].ToUpper() + ':\' + $Matches[2].Replace('/','\') }
        return $p
    }
    # Scripts live in <project>\.claude\scripts
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

# The .uproject at the repo root (where Claude Code runs) or up to two folders down,
# e.g. "UE5 Project\DarkTouch.uproject". Build and cache folders are skipped.
function Get-UEProject([string]$proj) {
    $u = Get-ChildItem -Path $proj -Filter *.uproject -File -Recurse -Depth 2 -ErrorAction SilentlyContinue |
         Where-Object { $_.FullName -notmatch '\\(\.git|Saved|Intermediate|Binaries|Plugins|DerivedDataCache)\\' } |
         Sort-Object { $_.FullName.Length } | Select-Object -First 1
    return $u
}

function Get-UEEngineDir($uproject) {
    if ($env:UE_ENGINE_DIR) { return $env:UE_ENGINE_DIR }
    try {
        $assoc = (Get-Content $uproject.FullName -Raw | ConvertFrom-Json).EngineAssociation
        $dir = (Get-ItemProperty -Path ("HKLM:\SOFTWARE\EpicGames\Unreal Engine\" + $assoc) -ErrorAction Stop).InstalledDirectory
        if ($dir) { return $dir }
    } catch {}
    # Not in the registry: the Epic Launcher's install list (e.g. an engine installed on another drive).
    try {
        $dat = Join-Path $env:ProgramData 'Epic\UnrealEngineLauncher\LauncherInstalled.dat'
        $hit = (Get-Content $dat -Raw | ConvertFrom-Json).InstallationList | Where-Object { $_.AppName -eq ('UE_' + $assoc) } | Select-Object -First 1
        if ($hit -and (Test-Path $hit.InstallLocation)) { return $hit.InstallLocation }
    } catch {}
    return 'C:\Program Files\Epic Games\UE_5.8'
}

function Get-StateDir([string]$proj) {
    $d = Join-Path $proj 'Saved\ClaudeVerify'
    New-Item -ItemType Directory -Force -Path $d | Out-Null
    return $d
}

# The editor process running THIS project (another project's editor is ignored).
function Get-EditorProcess($uproject) {
    $procs = Get-CimInstance Win32_Process -Filter "Name='UnrealEditor.exe'" -ErrorAction SilentlyContinue
    foreach ($p in $procs) {
        if ($p.CommandLine -and $p.CommandLine -like ('*' + $uproject.Name + '*')) { return $p }
    }
    return $null
}

# Newest write time (ticks) of any C++/C# source in Source\ and Plugins\*\Source\, 0 if none.
function Get-NewestSourceTicks([string]$proj) {
    $dirs = @((Join-Path $proj 'Source'))
    $dirs += @(Get-ChildItem -Path (Join-Path $proj 'Plugins') -Directory -ErrorAction SilentlyContinue | ForEach-Object { Join-Path $_.FullName 'Source' })
    $newest = [int64]0
    foreach ($d in $dirs) {
        if (-not (Test-Path $d)) { continue }
        $f = Get-ChildItem -Path $d -Recurse -File -Include *.cpp,*.h,*.cs,*.inl -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
        if ($f -and $f.LastWriteTimeUtc.Ticks -gt $newest) { $newest = $f.LastWriteTimeUtc.Ticks }
    }
    return $newest
}

function Get-GoodBuildTicks([string]$proj) {
    $f = Join-Path (Get-StateDir $proj) 'last-good-build.txt'
    if (Test-Path $f) { try { return [int64](Get-Content $f -Raw).Trim() } catch {} }
    return [int64]0
}
function Set-GoodBuildTicks([string]$proj, [int64]$ticks) {
    Set-Content -Path (Join-Path (Get-StateDir $proj) 'last-good-build.txt') -Value $ticks
}

# Builds the editor target. Returns Code, Errors, Warnings (project files only), LogPath.
function Invoke-UEBuild($uproject, [string]$proj, [int]$max = 40) {
    $engine = Get-UEEngineDir $uproject
    $bat = Join-Path $engine 'Engine\Build\BatchFiles\Build.bat'
    $logPath = Join-Path (Get-StateDir $proj) 'build.log'
    if (-not (Test-Path $bat)) {
        return [pscustomobject]@{ Code = 99; Errors = @("Build.bat not found in $engine. Set UE_ENGINE_DIR to the engine folder."); Warnings = @(); LogPath = '' }
    }
    $sourceTicks = Get-NewestSourceTicks $proj
    $target = $uproject.BaseName + 'Editor'
    # Called directly (not through cmd /c), so paths with spaces stay intact.
    $out = & $bat $target 'Win64' 'Development' ('-Project=' + $uproject.FullName) '-WaitMutex' 2>&1
    $code = $LASTEXITCODE
    $out | Set-Content -Path $logPath
    $errs = New-Object System.Collections.Generic.List[string]
    $warns = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    $projN = $proj.Replace('/','\').TrimEnd('\').ToLower()   # warnings: only the project's own files
    foreach ($l in $out) {
        $line = ([string]$l).Trim()
        if (-not $line -or $seen.ContainsKey($line)) { continue }
        $seen[$line] = $true
        if ($line -match '(?i)(\berror\b\s*[A-Z]*\d*\s*:|fatal error|LNK\d{4}|: Error:)') {
            if ($errs.Count -lt $max) { $errs.Add($line) }
        } elseif ($line -match '(?i)\bwarning\b\s*[A-Z]*\d*\s*:' -and $line.Replace('/','\').ToLower().Contains($projN)) {
            if ($warns.Count -lt $max) { $warns.Add($line) }
        }
    }
    if ($code -ne 0 -and $errs.Count -eq 0) { foreach ($l in ($out | Select-Object -Last 15)) { $errs.Add(([string]$l).Trim()) } }
    if ($code -eq 0) { Set-GoodBuildTicks $proj $sourceTicks }
    return [pscustomobject]@{ Code = $code; Errors = $errs.ToArray(); Warnings = $warns.ToArray(); LogPath = $logPath }
}

# Crash reports written after $sinceTicks. Returns a short text per crash.
function Get-NewCrashes([string]$proj, [int64]$sinceTicks) {
    $root = Join-Path $proj 'Saved\Crashes'
    $result = @()
    if (-not (Test-Path $root)) { return $result }
    $dirs = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTimeUtc.Ticks -gt $sinceTicks }
    foreach ($d in $dirs) {
        $msg = ''; $stack = @()
        $ctx = Join-Path $d.FullName 'CrashContext.runtime-xml'
        if (Test-Path $ctx) {
            try {
                [xml]$x = Get-Content $ctx -Raw
                $msg = [string]$x.FGenericCrashContext.RuntimeProperties.ErrorMessage
                $cs = [string]$x.FGenericCrashContext.RuntimeProperties.CallStack
                $stack = ($cs -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 12)
            } catch {}
        }
        if (-not $msg) {
            $log = Get-ChildItem -Path $d.FullName -Filter *.log -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($log) {
                $lines = Get-Content $log.FullName
                $i = 0; for ($k = 0; $k -lt $lines.Count; $k++) { if ($lines[$k] -match 'Critical error|Fatal error|Assertion failed|Unhandled Exception') { $i = $k; break } }
                $stack = $lines | Select-Object -Skip $i -First 15
                $msg = 'see ' + $log.FullName
            }
        }
        $result += ("CRASH (" + $d.Name + "): " + $msg.Trim() + "`n    " + (($stack | ForEach-Object { $_.Trim() }) -join "`n    "))
    }
    return $result
}

function Get-McpUrl([string]$proj) {
    $f = Join-Path $proj '.mcp.json'
    if (-not (Test-Path $f)) { $f = Join-Path (Get-UEProjectDir) '.mcp.json' }
    if (Test-Path $f) {
        try {
            $j = Get-Content $f -Raw | ConvertFrom-Json
            foreach ($p in $j.mcpServers.PSObject.Properties) { if ($p.Value.url) { return [string]$p.Value.url } }
        } catch {}
    }
    return 'http://127.0.0.1:8000/mcp'
}

# True when the MCP server answers (any HTTP status, 405 included, means it is up).
function Test-McpUp([string]$url) {
    try { $null = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing -TimeoutSec 3; return $true }
    catch { if ($_.Exception.Response) { return $true } else { return $false } }
}
