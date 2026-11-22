# Developer-only release builder. It does NOT provide a playable game until all steps pass.
# Run by double-clicking DEV_BUILD_WINDOWS_RELEASE.cmd on a Windows PC with Python 3.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$dist = Join-Path $root 'dist'
$log = Join-Path $root 'documentation\WINDOWS_EXPORT_RESULT.txt'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
function Record([string]$msg) { $msg | Out-File -LiteralPath $log -Encoding UTF8 -Append; Write-Host $msg }
'' | Out-File -LiteralPath $log -Encoding UTF8
function Find-Engine {
    if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) { return $env:GODOT_BIN }
    foreach ($name in @('godot.exe','godot4.exe','Godot.exe')) {
        $item = Get-Command $name -ErrorAction SilentlyContinue
        if ($item) { return $item.Source }
    }
    foreach ($path in @((Join-Path $root 'engine'), (Join-Path $env:USERPROFILE 'Downloads'))) {
        if (Test-Path $path) {
            $found = Get-ChildItem -LiteralPath $path -Filter 'Godot*win64*.exe' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }
    return $null
}
try {
    Record 'STATUS: DEVELOPMENT BUILD; commercial release gate is separate'
    $python = Get-Command python -ErrorAction SilentlyContinue
    $launcher = Get-Command py -ErrorAction SilentlyContinue
    if (-not $python -and -not $launcher) { throw 'Python 3 is required for the strict media rights check; install it before exporting.' }
    if ($python) { & $python.Source (Join-Path $root 'tools\sync_release_notices.py') }
    else { & $launcher.Source -3 (Join-Path $root 'tools\sync_release_notices.py') }
    if ($LASTEXITCODE -ne 0) { throw 'Copyright / media audit FAILED: update source register and rerun --sync before exporting.' }
    # Also protect owner-verified brand history, original BGM links and candidate-name records.
    if ($python) { & $python.Source (Join-Path $root 'tools\check_creator_provenance_v0166.py') }
    else { & $launcher.Source -3 (Join-Path $root 'tools\check_creator_provenance_v0166.py') }
    if ($LASTEXITCODE -ne 0) { throw 'Creator and BGM provenance gate FAILED; audit studio ownership and 4 music source links.' }
    $editor = Find-Engine
    if (-not $editor) { throw 'Godot 4.4.1 editor not found. Download official standard edition from godotengine.org and place executable under engine/, or set GODOT_BIN.' }
    $version = (& $editor --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $version.StartsWith('4.4.1')) { throw ('Required Godot 4.4.1 stable; discovered ' + $version) }
    Record ('Engine: ' + $version)
    # Fail closed if any actual Godot native tests have not run and passed.
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'tools\run_native_acceptance_windows.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Godot native import / QA FAILED; see documentation/native_run_logs/RESULT_windows.txt' }
    # Rebuild third-party legal notices from this exact engine version, not a stale licence copy.
    $rightsOutput = & $editor --headless --path $root --script 'res://tools/generate_engine_notices.gd' 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0 -or $rightsOutput -notmatch 'ENGINE COPYRIGHT SNAPSHOT PASS:') { throw ('Engine licence snapshot FAILED: ' + $rightsOutput) }
    $depNotices = Join-Path $root 'licenses\GODOT_BINARY_DEPENDENCIES.txt'
    if (-not (Test-Path -LiteralPath $depNotices -PathType Leaf) -or (Get-Item -LiteralPath $depNotices).Length -lt 800) { throw 'Engine binary licence snapshot absent/too short: do not export.' }
    Record 'Engine component copyright/licence snapshot generated from current binary.'
    # Godot requires the matching Windows export templates to have been installed.
    $target = Join-Path $dist 'LCG-P05_INTERNAL_TEST_ONLY.exe'
    if (Test-Path $target) { Remove-Item -LiteralPath $target -Force }
    $output = & $editor --headless --path $root --export-release 'Windows Desktop' $target 2>&1 | Out-String
    $output | Out-File -LiteralPath (Join-Path $root 'documentation\WINDOWS_EXPORT_LOG.txt') -Encoding UTF8
    if ($LASTEXITCODE -ne 0) { throw 'Godot Windows export failed. Install matching official export templates and review export log.' }
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'No .exe exported.' }
    if ((Get-Item -LiteralPath $target).Length -lt 1000000) { throw 'EXE suspiciously small; cannot verify standalone packaging.' }
    $fs = [System.IO.File]::OpenRead($target)
    try { $b0=$fs.ReadByte();$b1=$fs.ReadByte() } finally { $fs.Dispose() }
    if ($b0 -ne 77 -or $b1 -ne 90) { throw 'Exported file lacks Windows PE MZ header.' }
    if (Test-Path (Join-Path $dist 'LCG-P05_INTERNAL_TEST_ONLY.pck')) { throw 'Found loose .pck: not a verified one-file release.' }
    Record ('INTERNAL TEST BUILD COMPLETE: ' + $target)
    Record 'PUBLIC DISTRIBUTION PROHIBITED until independent brand/logo clearance and final platform checks.'
    exit 0
} catch {
    Record ('BLOCKED: ' + $_.Exception.Message)
    exit 1
}
