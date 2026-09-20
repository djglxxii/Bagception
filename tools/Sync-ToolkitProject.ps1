[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('FromGame', 'ToGame')]
  [string]$Direction
)

$ErrorActionPreference = 'Stop'
$moduleName = 'Bagception'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$dirsPath = Join-Path $repoRoot 'dirs.txt'

if (-not (Test-Path -LiteralPath $dirsPath)) {
  throw 'dirs.txt is missing. Copy dirs.example.txt to dirs.txt and set game_dir.'
}

$dirsText = Get-Content -LiteralPath $dirsPath -Raw
$gameDirMatch = [regex]::Match($dirsText, '(?s)<game_dir>\s*(.*?)\s*</game_dir>')
if (-not $gameDirMatch.Success) {
  throw 'dirs.txt must contain a <game_dir> entry.'
}

$gameDir = $gameDirMatch.Groups[1].Value.Trim()
$gameDataDir = Join-Path $gameDir 'Data'
if (-not (Test-Path -LiteralPath $gameDataDir -PathType Container)) {
  throw "Game Data directory does not exist: $gameDataDir"
}

$sourceRoot = if ($Direction -eq 'FromGame') { $gameDataDir } else { Join-Path $repoRoot 'src' }
$destinationRoot = if ($Direction -eq 'FromGame') { Join-Path $repoRoot 'src' } else { $gameDataDir }
$projectRelativePath = Join-Path 'Projects' $moduleName
$projectPath = Join-Path $sourceRoot $projectRelativePath
if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
  throw "Toolkit project folder does not exist: $projectPath"
}

$projectFiles = @(Get-ChildItem -LiteralPath $projectPath -Recurse -File | Where-Object { $_.Name -ne '.gitkeep' })
if ($projectFiles.Count -eq 0) {
  throw "Toolkit project folder has no real files: $projectPath"
}

$relativePaths = @(
  "Projects/$moduleName",
  "Editor/Mods/$moduleName",
  "Mods/$moduleName",
  "Public/$moduleName",
  "Generated/Public/$moduleName"
)

foreach ($relativePath in $relativePaths) {
  $source = Join-Path $sourceRoot $relativePath
  if (-not (Test-Path -LiteralPath $source -PathType Container)) {
    continue
  }

  $destination = Join-Path $destinationRoot $relativePath
  if ($PSCmdlet.ShouldProcess($destination, "Copy files from $source")) {
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Get-ChildItem -LiteralPath $source -Force | Where-Object { $_.Name -ne '.gitkeep' } | ForEach-Object {
      Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse -Force
    }
  }
}

if ($WhatIfPreference) {
  Write-Host "Toolkit project sync dry run complete: $Direction"
} else {
  Write-Host "Toolkit project sync complete: $Direction"
}
