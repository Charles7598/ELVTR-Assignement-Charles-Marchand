# Builds the project's C++ (editor target) and prints a short report: errors, then the
# warnings in the project's own files. Exit code 0 = clean build.
# The editor must be closed (use close-editor.ps1); for small .cpp-only edits with the
# editor open, use Live Coding instead (see CLAUDE.md).
#   powershell -NoProfile -ExecutionPolicy Bypass -File .claude\scripts\build.ps1
. (Join-Path $PSScriptRoot 'ue-common.ps1')
$proj = Get-UEProjectDir
$uproject = Get-UEProject $proj
if (-not $uproject) { Write-Output "No .uproject in $proj"; exit 2 }
$proj = $uproject.DirectoryName   # Saved, Source, Plugins are next to the .uproject
if (Get-EditorProcess $uproject) {
    Write-Output 'The editor is open: it locks the binaries. Save all, run .claude\scripts\close-editor.ps1, then build again.'
    exit 3
}
Write-Output ("Building " + $uproject.BaseName + "Editor ...")
$r = Invoke-UEBuild $uproject $proj
if ($r.Code -eq 0) {
    if ($r.Warnings.Count -gt 0) {
        Write-Output ("BUILD OK with " + $r.Warnings.Count + " warning(s) in project files (fix the ones you caused):")
        $r.Warnings | ForEach-Object { Write-Output ("  " + $_) }
    } else { Write-Output 'BUILD OK, no warnings in project files.' }
    exit 0
}
Write-Output ("BUILD FAILED (exit " + $r.Code + "). Errors:")
$r.Errors | ForEach-Object { Write-Output ("  " + $_) }
if ($r.Warnings.Count -gt 0) { Write-Output 'Warnings in project files:'; $r.Warnings | ForEach-Object { Write-Output ("  " + $_) } }
Write-Output ("Full log: " + $r.LogPath)
exit 1
