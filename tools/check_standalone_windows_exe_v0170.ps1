# Run the actual exported EXE outside the Godot source folder.
# This is a cloud Windows smoke test, NOT physical Windows user testing.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourceExe = Join-Path $root 'dist\LCG-P05_INTERNAL_TEST_ONLY.exe'
$logdir = Join-Path $root 'documentation\windows_standalone_smoke'
New-Item -ItemType Directory -Force -Path $logdir | Out-Null
$result = Join-Path $logdir 'RESULT.txt'
try {
    if (-not (Test-Path -LiteralPath $sourceExe -PathType Leaf)) { throw 'Expected internal EXE missing' }
    $buildFile = Get-Item -LiteralPath $sourceExe
    if ($buildFile.Length -lt 1000000) { throw 'EXE too small' }
    $sha = (Get-FileHash -LiteralPath $sourceExe -Algorithm SHA256).Hash.ToLowerInvariant()
    $tempRun = Join-Path $env:RUNNER_TEMP 'LCG-P05-Standalone-Source-Free'
    New-Item -ItemType Directory -Force -Path $tempRun | Out-Null
    $target = Join-Path $tempRun 'LCG-P05_INTERNAL_TEST_ONLY.exe'
    Copy-Item -LiteralPath $sourceExe -Destination $target -Force
    $otherFiles = @(Get-ChildItem -LiteralPath $tempRun -File | Where-Object { $_.Name -ne 'LCG-P05_INTERNAL_TEST_ONLY.exe' })
    if ($otherFiles.Count -ne 0) { throw 'Standalone test folder contains unexpected loose dependencies' }
    $out = Join-Path $logdir 'stdout.txt'
    $err = Join-Path $logdir 'stderr.txt'
    $arguments = @('--headless','--audio-driver','Dummy','--quit-after','60')
    Write-Host ('Launching built EXE in separate folder: '+$target)
    $p = Start-Process -FilePath $target -ArgumentList $arguments -WorkingDirectory $tempRun -PassThru -RedirectStandardOutput $out -RedirectStandardError $err -WindowStyle Hidden
    if (-not $p.WaitForExit(90000)) {
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        throw 'Standalone executable timed out without clean termination'
    }
    $p.Refresh()
    $code = $p.ExitCode
    $stdout = Get-Content -LiteralPath $out -Raw -ErrorAction SilentlyContinue
    $stderr = Get-Content -LiteralPath $err -Raw -ErrorAction SilentlyContinue
    if ($code -ne 0) { throw "Standalone process exit code $code" }
    $all = ([string]$stdout) + [Environment]::NewLine + ([string]$stderr)
    if ($all -match '(?im)(^|\s)(SCRIPT ERROR:|Parse Error:|Parser Error:|ERROR:)') {
        throw 'Standalone executable printed Godot runtime ERROR lines'
    }
    $lines = @(
       'STATUS: PASS — exported EXE starts outside source tree with no original assets or PCK alongside it',
       'TEST: Windows GitHub Actions runner, Godot runtime, command line headless quit-after 60',
       "SHA256: $sha",
       "EXE_BYTES: $($buildFile.Length)",
       "EXIT_CODE: $code",
       'LIMIT: Real screen, audio hardware, keyboard, mouse, character animation, physical Windows tests NOT performed'
    )
    $lines | Set-Content -LiteralPath $result -Encoding UTF8
    $lines | ForEach-Object { Write-Host $_ }
} catch {
    $msg = [string]$_.Exception.Message
    @("STATUS: FAIL OR BLOCKED","DETAIL: $msg") | Set-Content -LiteralPath $result -Encoding UTF8
    Write-Host ("BLOCKED: "+$msg)
    exit 1
}
