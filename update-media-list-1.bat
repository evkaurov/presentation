@echo off
setlocal

set "ROOT_DIR=%~dp0"
set "TARGET_NAME=%~1"
if not defined TARGET_NAME set "TARGET_NAME=ctc-media-var4"
set "TARGET_DIR=%ROOT_DIR%%TARGET_NAME%"
set "IMAGE_DIR=%TARGET_DIR%\img"
set "MEDIA_DIR=%TARGET_DIR%\vid"
set "OUTPUT_FILE=%TARGET_DIR%\media-files-list.js"

if not exist "%IMAGE_DIR%" (
  echo [ERROR] Image folder not found: "%IMAGE_DIR%"
  echo.
  pause
  exit /b 1
)

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$imageDir = $env:IMAGE_DIR;" ^
  "$mediaDir = $env:MEDIA_DIR;" ^
  "$outputFile = $env:OUTPUT_FILE;" ^
  "$imageAllowed = @('.png','.jpg','.jpeg','.webp','.gif','.avif');" ^
  "$mediaAllowed = @('.mp4','.m4v','.webm','.mov','.ogv','.ogg','.mkv','.avi','.wmv','.m2ts','.mts','.ts','.flv','.html','.htm');" ^
  "$imageFiles = @(Get-ChildItem -LiteralPath $imageDir -File -Recurse | Where-Object { $imageAllowed -contains $_.Extension.ToLowerInvariant() } | Sort-Object FullName);" ^
  "$mediaFiles = if (Test-Path -LiteralPath $mediaDir -PathType Container) { @(Get-ChildItem -LiteralPath $mediaDir -File -Recurse | Where-Object { $mediaAllowed -contains $_.Extension.ToLowerInvariant() } | Sort-Object FullName) } else { @() };" ^
  "$imageRoot = (Resolve-Path -LiteralPath $imageDir).Path;" ^
  "$mediaRoot = if (Test-Path -LiteralPath $mediaDir -PathType Container) { (Resolve-Path -LiteralPath $mediaDir).Path } else { $null };" ^
  "$lines = New-Object System.Collections.Generic.List[string];" ^
  "$lines.Add('window.PRES_IMAGE_FILES = [');" ^
  "for ($i = 0; $i -lt $imageFiles.Count; $i++) {" ^
  "  $relative = $imageFiles[$i].FullName.Substring($imageRoot.Length).TrimStart('\','/').Replace('\','/');" ^
  "  $comma = if ($i -lt ($imageFiles.Count - 1)) { ',' } else { '' };" ^
  "  $lines.Add(('  {0}img/{1}{0}{2}' -f [char]34, $relative, $comma));" ^
  "}" ^
  "$lines.Add('];');" ^
  "$lines.Add('');" ^
  "$lines.Add('window.PRES_MEDIA_FILES = [');" ^
  "for ($i = 0; $i -lt $mediaFiles.Count; $i++) {" ^
  "  $relative = $mediaFiles[$i].FullName.Substring($mediaRoot.Length).TrimStart('\','/').Replace('\','/');" ^
  "  $comma = if ($i -lt ($mediaFiles.Count - 1)) { ',' } else { '' };" ^
  "  $lines.Add(('  {0}vid/{1}{0}{2}' -f [char]34, $relative, $comma));" ^
  "}" ^
  "$lines.Add('];');" ^
  "$lines.Add('');" ^
  "$lines.Add('window.PRES_VIDEO_FILES = window.PRES_MEDIA_FILES;');" ^
  "if (-not (Test-Path -LiteralPath $mediaDir -PathType Container)) { Write-Host ('[WARN] Media folder not found: {0}. PRES_MEDIA_FILES was written as empty.' -f $mediaDir) };" ^
  "$utf8NoBom = New-Object System.Text.UTF8Encoding($false);" ^
  "[System.IO.File]::WriteAllLines($outputFile, $lines, $utf8NoBom);" ^
  "Write-Host ('Found {0} image files.' -f $imageFiles.Count);" ^
  "Write-Host ('Found {0} media files (video/html).' -f $mediaFiles.Count);" ^
  "Write-Host ('Updated: {0}' -f $outputFile);"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
  echo [OK] %TARGET_NAME%\media-files-list.js updated.
) else (
  echo [ERROR] Failed with code %EXIT_CODE%.
)

pause
exit /b %EXIT_CODE%
