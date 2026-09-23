[CmdletBinding()]
param(
  [string]$Version = "may2026"
)

# texconv is Microsoft's DirectXTex texture converter. tools/Build-Icons.py uses it to
# block-compress the icon DDS files; Pillow can write DXT5 too, but its encoder emits
# whole blocks of pure magenta at some soft edges.

$ErrorActionPreference = "Stop"

$toolRoot = Join-Path $PSScriptRoot "external"
$installRoot = Join-Path $toolRoot "texconv-$Version"
$exePath = Join-Path $installRoot "texconv.exe"
$url = "https://github.com/microsoft/DirectXTex/releases/download/$Version/texconv.exe"

New-Item -ItemType Directory -Path $installRoot -Force | Out-Null

if (-not (Test-Path -LiteralPath $exePath)) {
  Invoke-WebRequest -Uri $url -OutFile $exePath
}

[pscustomobject]@{
  Version = $Version
  Texconv = $exePath
}
