[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true)]
  [string]$PakPath
)

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

$paths = Get-BG3Paths -Validate

if (-not (Test-Path -LiteralPath $PakPath)) {
  throw "Pak file not found: $PakPath"
}

$resolvedPak = (Resolve-Path -LiteralPath $PakPath).Path
if ([System.IO.Path]::GetExtension($resolvedPak) -ne ".pak") {
  throw "Deploy requires an explicit .pak file path."
}

$resolvedModsDir = (Resolve-Path -LiteralPath $paths.ModsDir).Path

if ($PSCmdlet.ShouldProcess($resolvedModsDir, "Copy $resolvedPak")) {
  Copy-Item -LiteralPath $resolvedPak -Destination $resolvedModsDir -Force
}

Write-Host "Deployed $resolvedPak to $resolvedModsDir"
