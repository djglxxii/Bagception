[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [switch]$SkipStage
)

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

$paths = Get-BG3Paths
$moduleName = "Bagception"
$divinePath = Get-DivinePath
$stagePath = Join-Path $paths.RepositoryRoot "dist\unpacked\$moduleName"
$pakPath = Join-Path $paths.RepositoryRoot "dist\$moduleName.pak"

if (-not $SkipStage) {
  & (Join-Path $PSScriptRoot "Package-Mod.ps1")
  if ($LASTEXITCODE) {
    throw "Package staging failed with exit code $LASTEXITCODE."
  }
}

if (-not (Test-Path -LiteralPath $stagePath)) {
  throw "Package stage not found: $stagePath"
}

New-Item -ItemType Directory -Path (Split-Path -Parent $pakPath) -Force | Out-Null

if (Test-Path -LiteralPath $pakPath) {
  if ($PSCmdlet.ShouldProcess($pakPath, "Remove existing package")) {
    Remove-Item -LiteralPath $pakPath -Force
  }
}

if ($PSCmdlet.ShouldProcess($pakPath, "Create BG3 package")) {
  & $divinePath -a create-package -g bg3 -s $stagePath -d $pakPath
  if ($LASTEXITCODE) {
    throw "Divine package creation failed with exit code $LASTEXITCODE."
  }
}

if (-not (Test-Path -LiteralPath $pakPath)) {
  throw "Package was not created: $pakPath"
}

Write-Host "Built package at $pakPath"
Get-FileHash -LiteralPath $pakPath -Algorithm SHA256
