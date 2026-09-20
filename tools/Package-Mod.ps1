[CmdletBinding(SupportsShouldProcess = $true)]
param()

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

$paths = Get-BG3Paths
$moduleName = "Bagception"
$sourceRoot = Join-Path $paths.RepositoryRoot "src"
$distRoot = Join-Path $paths.RepositoryRoot "dist"
$stageRoot = Join-Path $distRoot "unpacked"
$moduleStage = Join-Path $stageRoot $moduleName

New-Item -ItemType Directory -Path $distRoot -Force | Out-Null

if (Test-Path -LiteralPath $moduleStage) {
  $resolvedDist = (Resolve-Path -LiteralPath $distRoot).Path
  $resolvedStage = (Resolve-Path -LiteralPath $moduleStage).Path

  if (-not $resolvedStage.StartsWith($resolvedDist, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to clean stage directory outside dist."
  }

  if ($PSCmdlet.ShouldProcess($resolvedStage, "Remove existing package stage")) {
    Remove-Item -LiteralPath $resolvedStage -Recurse -Force
  }
}

New-Item -ItemType Directory -Path $moduleStage -Force | Out-Null

foreach ($folder in @("Mods", "Public", "Localization")) {
  $source = Join-Path $sourceRoot $folder
  if (Test-Path -LiteralPath $source) {
    Copy-Item -LiteralPath $source -Destination $moduleStage -Recurse -Force
  }
}

Get-ChildItem -LiteralPath $moduleStage -Recurse -Force -Filter ".gitkeep" |
  Remove-Item -Force

# The game reads compiled .loca, not the authored .xml. Compile every staged
# localization file in place and keep the .xml alongside it for reference.
$stagedLocalization = Join-Path $moduleStage "Localization"
if (Test-Path -LiteralPath $stagedLocalization) {
  $localizationFiles = @(Get-ChildItem -LiteralPath $stagedLocalization -Recurse -File -Filter "*.xml")
  if ($localizationFiles.Count -gt 0) {
    $divine = Get-DivinePath
    foreach ($file in $localizationFiles) {
      $target = [System.IO.Path]::ChangeExtension($file.FullName, ".loca")
      if ($PSCmdlet.ShouldProcess($target, "Compile localization")) {
        & $divine -g bg3 -a convert-loca -s $file.FullName -d $target
        if ($LASTEXITCODE) {
          throw "Localization compilation failed for $($file.FullName) with exit code $LASTEXITCODE."
        }
      }
    }
  }
}

Write-Host "Prepared unpacked package stage at $moduleStage"
Write-Host "Run tools\Build-Pak.ps1 to create dist\$moduleName.pak."
