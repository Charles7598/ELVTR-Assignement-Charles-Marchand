# Closes this project's editor the normal way (like clicking X), never by force.
# Save everything through the MCP first: an unsaved change makes the editor ask, and
# this script will not answer for you.
#   powershell -NoProfile -ExecutionPolicy Bypass -File .claude\scripts\close-editor.ps1
. (Join-Path $PSScriptRoot 'ue-common.ps1')
$proj = Get-UEProjectDir
$uproject = Get-UEProject $proj
if (-not $uproject) { Write-Output "No .uproject in $proj"; exit 2 }
$proj = $uproject.DirectoryName   # Saved, Source, Plugins are next to the .uproject
$p = Get-EditorProcess $uproject
if (-not $p) { Write-Output 'Editor already closed.'; exit 0 }
$proc = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
if ($proc) { $null = $proc.CloseMainWindow() }
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Seconds 1
    if (-not (Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue)) { Write-Output 'Editor closed.'; exit 0 }
}
Write-Output 'The editor is still open after 60 s: it is probably asking to save changes. Save all through the MCP and try again, or ask the designer. Never kill the editor.'
exit 1
