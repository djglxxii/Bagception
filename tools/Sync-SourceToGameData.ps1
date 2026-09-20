[CmdletBinding(SupportsShouldProcess = $true)]
param()

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

$paths = Get-BG3Paths -Validate
$sourceRoot = Join-Path $paths.RepositoryRoot "src"
$destinationRoot = $paths.GameDataDir

$resolvedGameDir = (Resolve-Path -LiteralPath $paths.GameDir).Path
$resolvedDataDir = (Resolve-Path -LiteralPath $destinationRoot).Path
if (-not $resolvedDataDir.StartsWith($resolvedGameDir, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Refusing to sync because the target Data directory is outside the configured BG3 game directory."
}

foreach ($folder in @("Mods", "Public", "Localization")) {
  $source = Join-Path $sourceRoot $folder
  if (-not (Test-Path -LiteralPath $source)) {
    continue
  }

  if ($PSCmdlet.ShouldProcess($destinationRoot, "Copy $source")) {
    Copy-Item -LiteralPath $source -Destination $destinationRoot -Recurse -Force
  }
}

if ($WhatIfPreference) {
  Write-Host "Dry run completed for source sync to $destinationRoot"
} else {
  Write-Host "Synced source folders to $destinationRoot"
}
