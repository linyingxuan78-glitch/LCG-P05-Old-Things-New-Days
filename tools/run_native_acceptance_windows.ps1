# Godot 4 native engine acceptance for Windows. Run from run_check_windows.cmd.
# The official Godot standard editor ZIP is downloaded only if none is found locally.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$logdir = Join-Path $root 'documentation\native_run_logs'
New-Item -Path $logdir -ItemType Directory -Force | Out-Null
$resultPath = Join-Path $logdir 'RESULT_windows.txt'
$Status = @()
function Add-Status([string]$s) {
    $script:Status += $s
    Write-Host $s
    $script:Status | Set-Content -LiteralPath $resultPath -Encoding UTF8
}
function Find-Editor {
    if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) {return (Resolve-Path $env:GODOT_BIN).Path}
    foreach ($name in @('godot.exe','godot4.exe','Godot.exe')) {
        $c = Get-Command $name -ErrorAction SilentlyContinue
        if ($c) {return $c.Source}
    }
    $locations = @((Join-Path $root 'engine'), (Join-Path $env:USERPROFILE 'Downloads'))
    foreach ($folder in $locations) {
        if (Test-Path -LiteralPath $folder -PathType Container) {
            $found = Get-ChildItem -LiteralPath $folder -Filter 'Godot*.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $found) { $found = Get-ChildItem -LiteralPath $folder -Filter 'Godot*.exe' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 }
            if ($found) {return $found.FullName}
        }
    }
    return $null
}
function Run-Stage([string]$Name, [string[]]$GodotArgs, [string]$ExpectedMarker = "") {
    $log = Join-Path $logdir ($Name + '.log')
    $all = @()
    try {
        & $script:engine @GodotArgs 2>&1 | ForEach-Object {$all += [string]$_}
        $exitCode = $LASTEXITCODE
    } catch {
        $all += [string]$_
        $exitCode = 1
    }
    $all | Set-Content -LiteralPath $log -Encoding UTF8
    $body = ($all -join "`n")
    if ($exitCode -ne 0 -or $body -match '(?im)(^|\s)(SCRIPT ERROR:|Parse Error:|Parser Error:|ERROR:|FAILED:)') {
        Add-Status "FAIL: $Name, exit=$exitCode (details: $log)"
        return $false
    }
    if ($ExpectedMarker -and $body -notmatch $ExpectedMarker) {
        Add-Status "FAIL: $Name lacks its own expected PASS marker (details: $log)"
        return $false
    }
    Add-Status "PASS: $Name"
    return $true
}
try {
    Add-Status 'START: Godot native acceptance (Windows)'
    $script:engine = Find-Editor
    if (-not $script:engine) {
        Add-Status 'INFO: No local Godot editor found. Downloading official Godot 4.4.1 standard Windows edition.'
        $engineDir = Join-Path $root 'engine'
        New-Item -Path $engineDir -ItemType Directory -Force | Out-Null
        $zip = Join-Path $engineDir 'Godot_4.4.1_official_win64.zip'
        $uri = 'https://downloads.godotengine.org/?flavor=stable&platform=windows.64&slug=win64.exe.zip&version=4.4.1'
        try {
            Invoke-WebRequest -Uri $uri -UseBasicParsing -OutFile $zip -TimeoutSec 150
            if ((Get-Item $zip).Length -lt 1000000) {throw 'Download suspiciously small; possible HTML error page'}
            Expand-Archive -LiteralPath $zip -DestinationPath $engineDir -Force
            $script:engine = Find-Editor
        } catch {
            Add-Status ('BLOCKED_DOWNLOAD: Official Godot download failed: ' + $_.Exception.Message)
            Add-Status 'This is an engine acquisition issue, not proof that game code fails.'
            exit 2
        }
    }
    if (-not $script:engine) {Add-Status 'BLOCKED_ENGINE_NOT_FOUND_AFTER_DOWNLOAD';exit 2}
    Add-Status ('Engine path: ' + $script:engine)
    $version = (& $script:engine --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {throw 'godot --version failed'}
    Add-Status ('Engine version: ' + $version)
    if (-not (Run-Stage 'editor_import' @('--headless','--path', $root, '--editor','--import','--quit'))) {exit 1}
    if (-not (Run-Stage 'main_scene_startup' @('--headless','--path', $root, '--quit-after', '15'))) {exit 1}
    $tests = @('qa_smoke','qa_economy','qa_customer_flow','qa_v012_continuity','qa_v013_demand_and_recovery','qa_v014_onboarding_and_accessibility','qa_v0141_ui_input','qa_v0147_assets_and_audio','qa_v0152_finale_and_animations','qa_v0153_catalog_and_save_migration','qa_v0154_supplier_animation_routes','qa_v0155_resident_trade_ins','qa_v0156_events_and_usability','qa_v0157_customer_help','qa_v0158_visual_comfort_and_tutorial','qa_v0159_world_shelf_wayfinding','qa_v0160_healthy_play','qa_v0161_privacy_and_pictograms','qa_v0162_picture_catalog_and_safe_close','qa_v0163_save_recovery','qa_v0165_engine_licenses','qa_v0167_brand_intro_and_exit','qa_v0168_safe_desktop_exit_and_intro')
    $expectedMarkers = @{
        'qa_smoke' = '(?m)^QA SMOKE PASSED:'
        'qa_economy' = '(?m)^QA ECONOMY PASSED:'
        'qa_customer_flow' = '(?m)^QA CUSTOMER PASSED:'
        'qa_v012_continuity' = '(?m)^v0\.12 CONTINUITY PASS:'
        'qa_v013_demand_and_recovery' = '(?m)^v0\.13 QA PASS:'
        'qa_v014_onboarding_and_accessibility' = '(?m)^v0\.14 QA PASS:'
        'qa_v0141_ui_input' = '(?m)^QA UI INPUT PASSED:'
        'qa_v0147_assets_and_audio' = '(?m)^QA ASSETS 0147 PASSED:'
        'qa_v0152_finale_and_animations' = '(?m)^QA 0152 PASSED:'
        'qa_v0153_catalog_and_save_migration' = '(?m)^QA 0153 PASSED:'
        'qa_v0154_supplier_animation_routes' = '(?m)^QA 0154 PASSED:'
        'qa_v0156_events_and_usability' = '(?m)^QA 0156 PASSED:'
        'qa_v0157_customer_help' = '(?m)^QA CUSTOMER HELP 0157 PASSED:'
        'qa_v0158_visual_comfort_and_tutorial' = '(?m)^QA 0158 PASSED:'
        'qa_v0159_world_shelf_wayfinding' = '(?m)^QA 0159 PASSED:'
        'qa_v0160_healthy_play' = '(?m)^QA 0160 PASSED:'
        'qa_v0161_privacy_and_pictograms' = '(?m)^QA 0161 PASSED:'
        'qa_v0162_picture_catalog_and_safe_close' = '(?m)^QA 0162 PASSED:'
        'qa_v0163_save_recovery' = '(?m)^QA 0163 PASSED:'
        'qa_v0165_engine_licenses' = '(?m)^QA ENGINE RIGHTS 0165 PASSED:'
        'qa_v0167_brand_intro_and_exit' = '(?m)^QA BRAND 0167 PASSED:'
        'qa_v0168_safe_desktop_exit_and_intro' = '(?m)^QA 0168 PASSED:'
        'qa_v0155_resident_trade_ins' = '(?m)^QA 0155 PASSED:'
    }
    $failed = 0
    foreach ($test in $tests) {
        if (-not (Run-Stage $test @('--headless','--path', $root, '--script', ('res://tests/'+$test+'.gd')) $expectedMarkers[$test])) {$failed++}
    }
    if ($failed -gt 0) {Add-Status "FAILED: $failed QA suites did not pass";exit 1}
    Add-Status 'PASSED: Godot import, scene startup and all 23 headless QA suites'
    Add-Status 'NOT TESTED: interactive graphics/audio on a real computer, Windows EXE export or release readiness'
    exit 0
} catch {
    Add-Status ('FAILED: ' + $_.Exception.Message)
    exit 1
}
