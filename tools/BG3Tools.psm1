Set-StrictMode -Version Latest

function Get-RepositoryRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Get-TaggedValue {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Content,

    [Parameter(Mandatory = $true)]
    [string]$Tag
  )

  $escapedTag = [regex]::Escape($Tag)
  $pattern = "(?s)<$escapedTag>\s*(.*?)\s*<[/\\]$escapedTag>"
  $match = [regex]::Match($Content, $pattern)

  if (-not $match.Success) {
    throw "Missing <$Tag> entry in dirs.txt."
  }

  return $match.Groups[1].Value.Trim()
}

function Get-BG3Paths {
  [CmdletBinding()]
  param(
    [string]$DirsPath = (Join-Path (Get-RepositoryRoot) "dirs.txt"),
    [switch]$Validate
  )

  if (-not (Test-Path -LiteralPath $DirsPath)) {
    throw "Path file not found: $DirsPath"
  }

  $content = Get-Content -LiteralPath $DirsPath -Raw
  $gameDir = Get-TaggedValue -Content $content -Tag "game_dir"
  $modsDir = Get-TaggedValue -Content $content -Tag "mod_dir"
  $gameDataDir = Join-Path $gameDir "Data"

  if ($Validate) {
    foreach ($path in @($gameDir, $gameDataDir, $modsDir)) {
      if (-not (Test-Path -LiteralPath $path)) {
        throw "Configured path does not exist: $path"
      }
    }
  }

  [pscustomobject]@{
    RepositoryRoot = Get-RepositoryRoot
    GameDir = $gameDir
    GameDataDir = $gameDataDir
    ModsDir = $modsDir
  }
}

function Get-DivinePath {
  [CmdletBinding()]
  param(
    [string]$Version = "v1.20.4"
  )

  $local = Join-Path (Get-RepositoryRoot) "tools\external\ExportTool-$Version\Packed\Tools\Divine.exe"
  if (Test-Path -LiteralPath $local) {
    return (Resolve-Path -LiteralPath $local).Path
  }

  throw "Divine.exe not found at $local. Run tools\Install-ExportTool.ps1 first."
}

Export-ModuleMember -Function Get-BG3Paths, Get-DivinePath
