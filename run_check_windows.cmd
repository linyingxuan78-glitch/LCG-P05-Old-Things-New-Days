@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\run_native_acceptance_windows.ps1"
echo.
echo See documentation\native_run_logs\RESULT_windows.txt for the result.
pause
