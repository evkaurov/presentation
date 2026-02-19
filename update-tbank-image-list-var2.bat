@echo off
setlocal

set "ROOT_DIR=%~dp0"
set "TARGET_DIR=%ROOT_DIR%ctc-media-var2"
set "IMAGE_DIR=%TARGET_DIR%\img"
set "OUTPUT_FILE=%TARGET_DIR%\ctc-media-image-files.js"

if not exist "%IMAGE_DIR%" (
  echo [ERROR] Image folder not found: "%IMAGE_DIR%"
  echo.
  pause
  exit /b 1
)

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$imageDir = $env:IMAGE_DIR;" ^
  "$outputFile = $env:OUTPUT_FILE;" ^
  "$allowed = @('.png','.jpg','.jpeg','.webp','.gif','.avif');" ^
  "$files = @(Get-ChildItem -LiteralPath $imageDir -File -Recurse | Where-Object { $allowed -contains $_.Extension.ToLowerInvariant() } | Sort-Object FullName);" ^
  "$root = (Resolve-Path -LiteralPath $imageDir).Path;" ^
  "$lines = New-Object System.Collections.Generic.List[string];" ^
  "$lines.Add('window.TBANK_IMAGE_FILES = [');" ^
  "for ($i = 0; $i -lt $files.Count; $i++) {" ^
  "  $relative = $files[$i].FullName.Substring($root.Length).TrimStart('\','/').Replace('\','/');" ^
  "  $comma = if ($i -lt ($files.Count - 1)) { ',' } else { '' };" ^
  "  $lines.Add(('  {0}img/{1}{0}{2}' -f [char]34, $relative, $comma));" ^
  "}" ^
  "$lines.Add('];');" ^
  "$utf8NoBom = New-Object System.Text.UTF8Encoding($false);" ^
  "[System.IO.File]::WriteAllLines($outputFile, $lines, $utf8NoBom);" ^
  "Write-Host ('Found {0} image files.' -f $files.Count);" ^
  "Write-Host ('Updated: {0}' -f $outputFile);"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
  echo [OK] ctc-media-var2\ctc-media-image-files.js updated.
) else (
  echo [ERROR] Failed with code %EXIT_CODE%.
)

pause
exit /b %EXIT_CODE%
