param(
  [ValidateSet("pres-var1", "pres-var2")]
  [string]$Variant = "pres-var1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$variantDir = Join-Path $projectRoot $Variant
$imageDir = Join-Path $variantDir "img"
$outputFile = Join-Path $variantDir "tbank-image-files.js"

if (-not (Test-Path -LiteralPath $imageDir -PathType Container)) {
  throw "Image folder not found: $imageDir"
}

$imageFiles = @(
  Get-ChildItem -LiteralPath $imageDir -File -Recurse |
    Where-Object {
      $ext = $_.Extension.ToLowerInvariant()
      $ext -eq ".png" -or $ext -eq ".jpg" -or $ext -eq ".jpeg" -or $ext -eq ".webp" -or $ext -eq ".gif" -or $ext -eq ".avif"
    } |
    Sort-Object FullName
)

$imageRoot = (Resolve-Path -LiteralPath $imageDir).Path

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("window.TBANK_IMAGE_FILES = [")

for ($i = 0; $i -lt $imageFiles.Count; $i++) {
  $file = $imageFiles[$i]
  $relativePath = $file.FullName.Substring($imageRoot.Length).TrimStart('\', '/').Replace('\', '/')
  $webPath = "img/$relativePath"
  $comma = if ($i -lt ($imageFiles.Count - 1)) { "," } else { "" }
  $lines.Add("  ""$webPath""$comma")
}

$lines.Add("];")

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($outputFile, $lines, $utf8NoBom)

Write-Host "Found $($imageFiles.Count) image files."
Write-Host "Variant: $Variant"
Write-Host "Updated: $outputFile"
