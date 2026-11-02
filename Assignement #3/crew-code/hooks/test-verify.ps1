# Self-test for verify.ps1. Run once on your PC from the project folder:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .claude\hooks\test-verify.ps1
# It builds a fake project in %TEMP%, writes fake log lines and checks that the gate
# allows, blocks and escalates when it should. It does not touch your real project.

$verify = Join-Path $PSScriptRoot 'verify.ps1'
$root = Join-Path $env:TEMP ('verify-test-' + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Force -Path (Join-Path $root 'Saved\Logs') | Out-Null
'{ "EngineAssociation": "5.8" }' | Set-Content (Join-Path $root 'Fake.uproject')
$log = Join-Path $root 'Saved\Logs\Fake.log'
'Log file open, 10/26/26 16:00:00' | Set-Content $log
'[2026.10.26-16.00.01:000][  0]LogInit: Error: old startup error, before the baseline' | Add-Content $log

$env:CLAUDE_PROJECT_DIR = $root
$pass = 0; $fail = 0
function Run { return ('{}' | powershell -NoProfile -ExecutionPolicy Bypass -File $verify | Out-String).Trim() }
function Check([string]$label, [bool]$ok, [string]$out) {
    if ($ok) { $script:pass++; Write-Host "PASS  $label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "FAIL  $label`n      output: $out" -ForegroundColor Red }
}

$o = Run; Check 'first run takes the existing log as baseline (allows)' ($o -eq '') $o

'[2026.10.26-16.01:000][ 10]LogBlueprint: Error: [Compiler] BP_Deathbolt: Accessed None trying to read Target' | Add-Content $log
$o = Run; Check 'new Blueprint error blocks' ($o -match '"decision":"block"' -and $o -match 'BP_Deathbolt' -and $o -match 'attempt 1') $o

'[2026.10.26-16.02:000][ 20]LogBlueprint: Display: compiled BP_Deathbolt' | Add-Content $log
$o = Run; Check 'clean log after the fix allows' ($o -eq '') $o

'[2026.10.26-16.03:000][ 30]LogScript: Warning: Script Msg: Blueprint Runtime Error: BP_Raise' | Add-Content $log
$o = Run; Check 'runtime error, try 1, blocks' ($o -match 'attempt 1') $o
'[2026.10.26-16.04:000][ 40]LogScript: Warning: Script Msg: Blueprint Runtime Error: BP_Raise' | Add-Content $log
$o = Run; Check 'same error, try 2, blocks' ($o -match 'attempt 2') $o
'[2026.10.26-16.05:000][ 50]LogScript: Warning: Script Msg: Blueprint Runtime Error: BP_Raise' | Add-Content $log
$o = Run; Check 'try 3 escalates: report to the designer' ($o -match 'Stop fixing now') $o
$o = Run; Check 'after escalating, the agent may finish' ($o -eq '') $o

$crash = Join-Path $root 'Saved\Crashes\UECC-Windows-TEST'
New-Item -ItemType Directory -Force -Path $crash | Out-Null
'<FGenericCrashContext><RuntimeProperties><ErrorMessage>Unhandled Exception: EXCEPTION_ACCESS_VIOLATION reading address 0x0</ErrorMessage><CallStack>UArmyComponent::RaiseSoldier() ArmyComponent.cpp:42</CallStack></RuntimeProperties></FGenericCrashContext>' | Set-Content (Join-Path $crash 'CrashContext.runtime-xml')
$o = Run; Check 'new crash report blocks, with the callstack' ($o -match 'CRASH' -and $o -match 'ArmyComponent.cpp:42') $o
$o = Run; Check 'same crash is not reported twice' ($o -eq '') $o

New-Item -ItemType Directory -Force -Path (Join-Path $root 'Source\Fake') | Out-Null
'int x = ;' | Set-Content (Join-Path $root 'Source\Fake\Broken.cpp')
$o = Run; Check 'changed C++ that does not build blocks' ($o -match '\[C\+\+\]') $o
Remove-Item -Recurse -Force (Join-Path $root 'Source')
Remove-Item -Force (Join-Path $root 'Saved\ClaudeVerify\state.json')
$o = Run   # new baseline

'Log file open, 10/26/26 17:00:00' | Set-Content $log
'[2026.10.26-17.00.05:000][  1]LogBlueprint: Error: [Compiler] BP_Hunger broken on load' | Add-Content $log
$o = Run; Check 'editor restart: new log read from the start' ($o -match 'BP_Hunger') $o

Remove-Item -Recurse -Force $root
Write-Host "`n$pass passed, $fail failed"
if ($fail -gt 0) { exit 1 }
