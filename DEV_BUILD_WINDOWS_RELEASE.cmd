@echo off
cd /d "%~dp0"
echo Godot 4.4.1 release build and copyright audit (developer tool, not a game launcher)
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build_windows_release.ps1"
echo.
echo Report: documentation\WINDOWS_EXPORT_RESULT.txt
echo If PASS, the built game will be at dist\LCG-P05_INTERNAL_TEST_ONLY.exe
pause
