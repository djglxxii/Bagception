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

# The Story Editor drops its build log next to the compiled story. A Toolkit-built
# package does not contain it, so neither should this one.
Get-ChildItem -LiteralPath $moduleStage -Recurse -Force -Filter "log.txt" |
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

# The game reads .lsf, not the authored .lsx, for resources under Public. A package
# carrying only .lsx loads nothing: no root templates, no tags, and no error either,
# which is exactly how the first probe build failed silently. The Toolkit generates
# the .lsf beside the .lsx; when a resource is hand-authored, as these are, nothing
# has generated one, so compile them here. Both are kept, as a Toolkit-built package
# keeps both.
$stagedPublic = Join-Path $moduleStage "Public"
if (Test-Path -LiteralPath $stagedPublic) {
  $resourceFiles = @(Get-ChildItem -LiteralPath $stagedPublic -Recurse -File -Filter "*.lsx")
  if ($resourceFiles.Count -gt 0) {
    $divine = Get-DivinePath
    foreach ($file in $resourceFiles) {
      $target = [System.IO.Path]::ChangeExtension($file.FullName, ".lsf")
      if ($PSCmdlet.ShouldProcess($target, "Compile resource to LSF")) {
        & $divine -g bg3 -a convert-resource -s $file.FullName -d $target -o lsf
        if ($LASTEXITCODE) {
          throw "Resource compilation failed for $($file.FullName) with exit code $LASTEXITCODE."
        }
      }
    }
    Write-Host "Compiled $($resourceFiles.Count) resource file(s) under Public to .lsf"
  }
}

Write-Host "Prepared unpacked package stage at $moduleStage"
Write-Host "Run tools\Build-Pak.ps1 to create dist\$moduleName.pak."
