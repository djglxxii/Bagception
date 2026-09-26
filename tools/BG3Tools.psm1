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

function Get-MissingStoryIdentifiers {
  # Returns what the authored goals declare but the compiled story lacks. Empty means
  # the story was built from the current goals.
  #
  # Identifier-based rather than a timestamp comparison: a rebuild always refreshes the
  # timestamp, including one that compiled the wrong file. Only the module's own names
  # count; names shared with vanilla prove nothing.
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$GoalsDirectory,
    [Parameter(Mandatory = $true)][string]$CompiledStory
  )

  $declared = [System.Collections.Generic.HashSet[string]]::new()
  foreach ($goal in Get-ChildItem -LiteralPath $GoalsDirectory -Recurse -File -Filter "*.txt") {
    # Strip // comments first. Prose in a comment routinely names an identifier that
    # was deliberately removed.
    $goalText = [regex]::Replace((Get-Content -LiteralPath $goal.FullName -Raw), '(?m)//.*$', '')
    foreach ($match in [regex]::Matches($goalText, '\b(?:DB|PROC|QRY)_\w+')) {
      [void]$declared.Add($match.Value)
    }
    # The module's own templates and tags, as the full name_GUID the story uses. A
    # change that only adds facts and rules for a new container introduces no new
    # DB or PROC name; the container is what it adds.
    foreach ($match in [regex]::Matches($goalText, '\bBAGCEPTION_\w+?_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b')) {
      [void]$declared.Add($match.Value)
    }
    # The module's own timer and event names. A change that only adds rules, reusing
    # every existing DB, PROC and template, still adds these: 1.0.0.11's gold rules
    # added nothing else, and a stale story passed without them.
    foreach ($match in [regex]::Matches($goalText, '"(Bagception_\w+)"')) {
      [void]$declared.Add($match.Groups[1].Value)
    }
  }

  return @($declared | Where-Object { $CompiledStory -notmatch "\b$([regex]::Escape($_))\b" } | Sort-Object)
}

Export-ModuleMember -Function Get-BG3Paths, Get-DivinePath, Get-MissingStoryIdentifiers
