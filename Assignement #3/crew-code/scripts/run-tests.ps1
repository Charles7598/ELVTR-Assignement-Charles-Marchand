# Runs the project's automation tests headless (no window), even with the editor open.
# Default filter: tests whose path starts with GameSystems or DarkTouch.
# Exit code 0 = all passed.
#   powershell -NoProfile -ExecutionPolicy Bypass -File .claude\scripts\run-tests.ps1 [-Filter "GameSystems.Casting"]
param([string]$Filter = 'GameSystems+DarkTouch', [int]$TimeoutSec = 900)
. (Join-Path $PSScriptRoot 'ue-common.ps1')
$proj = Get-UEProjectDir
$uproject = Get-UEProject $proj
if (-not $uproject) { Write-Output "No .uproject in $proj"; exit 2 }
$proj = $uproject.DirectoryName   # Saved, Source, Plugins are next to the .uproject
$engine = Get-UEEngineDir $uproject
$cmd = Join-Path $engine 'Engine\Binaries\Win64\UnrealEditor-Cmd.exe'
if (-not (Test-Path $cmd)) { Write-Output "UnrealEditor-Cmd.exe not found in $engine. Set UE_ENGINE_DIR."; exit 2 }
$report = Join-Path (Get-StateDir $proj) 'tests'
if (Test-Path $report) { Remove-Item -Recurse -Force $report }
$log = Join-Path (Get-StateDir $proj) 'tests.log'
$argList = @('"' + $uproject.FullName + '"', "-ExecCmds=`"Automation RunTests $Filter; Quit`"", '-unattended', '-nullrhi', '-nosplash', '-nosound', '-stdout', '-NoLogTimes', ('-ReportExportPath="' + $report + '"'), ('-abslog="' + $log + '"'))
$p = Start-Process -FilePath $cmd -ArgumentList $argList -PassThru -WindowStyle Hidden
if (-not $p.WaitForExit($TimeoutSec * 1000)) { Write-Output "Tests still running after $TimeoutSec s; stopped."; $p.Kill(); exit 1 }
$index = Join-Path $report 'index.json'
if (Test-Path $index) {
    $j = Get-Content $index -Raw | ConvertFrom-Json
    $failed = @($j.tests | Where-Object { $_.state -ne 'Success' -and $_.state -ne 'Skipped' })
    Write-Output ("Tests: " + $j.succeeded + " passed, " + $j.failed + " failed, " + $j.notRun + " not run.")
    foreach ($t in $failed) {
        Write-Output ("FAIL " + $t.fullTestPath)
        foreach ($e in $t.entries) { if ($e.event.type -eq 'Error') { Write-Output ("     " + $e.event.message) } }
    }
    if ($failed.Count -gt 0) { exit 1 }
    if ([int]$j.succeeded -eq 0) { Write-Output "No test matched '$Filter'."; exit 1 }
    exit 0
}
# No report: fall back to the log.
$lines = @(); if (Test-Path $log) { $lines = Get-Content $log }
$fails = $lines | Where-Object { $_ -match 'Test Completed\. Result=\{(Fail|Failed)\}' -or $_ -match 'LogAutomationController: Error' }
$ok = $lines | Where-Object { $_ -match 'Test Completed\. Result=\{(Success|Passed)\}' }
Write-Output ("Tests (from log): " + @($ok).Count + " passed, " + @($fails).Count + " failed. Log: $log")
$fails | Select-Object -First 30 | ForEach-Object { Write-Output ("  " + $_.Trim()) }
if (@($fails).Count -gt 0 -or @($ok).Count -eq 0) { exit 1 }
exit 0
