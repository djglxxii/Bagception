[CmdletBinding()]
param(
  [string]$Version = "v1.20.4"
)

$ErrorActionPreference = "Stop"

$toolRoot = Join-Path $PSScriptRoot "external"
$installRoot = Join-Path $toolRoot "ExportTool-$Version"
$zipPath = Join-Path $toolRoot "ExportTool-$Version.zip"
$url = "https://github.com/Norbyte/lslib/releases/download/$Version/ExportTool-$Version.zip"

New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $zipPath)) {
  Invoke-WebRequest -Uri $url -OutFile $zipPath
}

if (-not (Test-Path -LiteralPath $installRoot)) {
  Expand-Archive -LiteralPath $zipPath -DestinationPath $installRoot -Force
}

$divine = Get-ChildItem -LiteralPath $installRoot -Recurse -Filter "divine.exe" | Select-Object -First 1
$converter = Get-ChildItem -LiteralPath $installRoot -Recurse -Filter "ConverterApp.exe" | Select-Object -First 1

[pscustomobject]@{
  Version = $Version
  InstallRoot = $installRoot
  Divine = if ($divine) { $divine.FullName } else { $null }
  ConverterApp = if ($converter) { $converter.FullName } else { $null }
}
