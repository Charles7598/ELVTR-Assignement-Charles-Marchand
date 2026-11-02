# Builds the C++ (if anything changed), opens the editor on this project and waits
# until the MCP server answers. Exit code 0 = editor up and MCP reachable.
# If the editor crashes while loading, prints the crash report.
#   powershell -NoProfile -ExecutionPolicy Bypass -File .claude\scripts\launch-editor.ps1
param([int]$TimeoutSec = 300)
. (Join-Path $PSScriptRoot 'ue-common.ps1')
$proj = Get-UEProjectDir
$uproject = Get-UEProject $proj
if (-not $uproject) { Write-Output "No .uproject in $proj"; exit 2 }
$proj = $uproject.DirectoryName   # Saved, Source, Plugins are next to the .uproject
$url = Get-McpUrl $proj
if (Get-EditorProcess $uproject) {
    if (Test-McpUp $url) { Write-Output "Editor already open, MCP up at $url."; exit 0 }
    Write-Output "Editor already open but the MCP server does not answer at $url. Check Editor Preferences > Model Context Protocol > Auto Start Server."
    exit 1
}
# Build first, so the editor never asks to rebuild modules.
if ((Get-NewestSourceTicks $proj) -gt (Get-GoodBuildTicks $proj)) {
    Write-Output 'C++ changed since the last good build: building first.'
    $r = Invoke-UEBuild $uproject $proj
    if ($r.Code -ne 0) {
        Write-Output 'BUILD FAILED, editor not launched. Errors:'
        $r.Errors | ForEach-Object { Write-Output ("  " + $_) }
        exit 1
    }
    Write-Output 'Build OK.'
}
$engine = Get-UEEngineDir $uproject
$exe = Join-Path $engine 'Engine\Binaries\Win64\UnrealEditor.exe'
if (-not (Test-Path $exe)) { Write-Output "UnrealEditor.exe not found in $engine. Set UE_ENGINE_DIR."; exit 2 }
$start = (Get-Date).ToUniversalTime().Ticks
$proc = Start-Process -FilePath $exe -ArgumentList ('"' + $uproject.FullName + '"') -PassThru
Write-Output "Editor starting (pid $($proc.Id)), waiting for the MCP server at $url ..."
$t0 = Get-Date
while (((Get-Date) - $t0).TotalSeconds -lt $TimeoutSec) {
    Start-Sleep -Seconds 3
    if ($proc.HasExited) {
        Write-Output "The editor closed while loading (exit code $($proc.ExitCode))."
        Get-NewCrashes $proj $start | ForEach-Object { Write-Output $_ }
        exit 1
    }
    if (Test-McpUp $url) {
        Write-Output ("Editor up, MCP reachable after " + [int]((Get-Date) - $t0).TotalSeconds + " s. If the MCP tools fail, the session is stale: ask the designer to reconnect it with /mcp.")
        exit 0
    }
}
Write-Output "The MCP server did not answer within $TimeoutSec s. The editor may still be compiling shaders: try again, or check Auto Start Server."
exit 1
