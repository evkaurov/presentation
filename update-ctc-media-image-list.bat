@echo off
setlocal

set "ROOT_DIR=%~dp0"
set "SCRIPT_PATH=%ROOT_DIR%scripts\generate-tbank-image-list.ps1"

if not exist "%SCRIPT_PATH%" (
  echo [ERROR] Script not found: "%SCRIPT_PATH%"
  echo.
  pause
  exit /b 1
)

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Variant "ctc-media"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
  echo [OK] ctc-media\ctc-media-image-files.js updated.
) else (
  echo [ERROR] Failed with code %EXIT_CODE%.
)

pause
exit /b %EXIT_CODE%
