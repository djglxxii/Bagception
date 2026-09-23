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
#
# The exception is GUI: the game reads icon sheet indexes there as .lsx, and vanilla
# ships them that way, with no .lsf beside them.
$stagedPublic = Join-Path $moduleStage "Public"
if (Test-Path -LiteralPath $stagedPublic) {
  $resourceFiles = @(Get-ChildItem -LiteralPath $stagedPublic -Recurse -File -Filter "*.lsx" |
    Where-Object { $_.Directory.Name -ne "GUI" })
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

# A Toolkit story build reads Data\Mods\<module>\, not src\. Editing a goal under
# src\ and rebuilding compiles the previous goal instead, cleanly and with no error,
# and the resulting package ships a story missing whatever was just written. That
# failure is invisible at every later step, so it is caught here.
#
# The check is deliberately identifier-based rather than a timestamp comparison: a
# rebuild always refreshes the timestamp, including the rebuild that compiled the
# wrong file. Every DB_ and PROC_ name declared in the authored goals must appear in
# the compiled story. Names shared with vanilla are useless for this, which is why
# only the module's own prefixed identifiers are used.
$stagedStory = Join-Path $moduleStage "Mods\$moduleName\Story\goals.raw"
$authoredGoals = Join-Path $sourceRoot "Mods\$moduleName\Story\RawFiles\Goals"

if ((Test-Path -LiteralPath $authoredGoals) -and (Test-Path -LiteralPath $stagedStory)) {
  $compiled = Get-Content -LiteralPath $stagedStory -Raw
  $declared = [System.Collections.Generic.HashSet[string]]::new()

  foreach ($goal in Get-ChildItem -LiteralPath $authoredGoals -Recurse -File -Filter "*.txt") {
    # Strip // comments first. Prose in a comment routinely names an identifier that
    # was deliberately removed, and harvesting those would demand the compiled story
    # contain something no rule declares.
    $goalText = [regex]::Replace((Get-Content -LiteralPath $goal.FullName -Raw), '(?m)//.*$', '')
    foreach ($match in [regex]::Matches($goalText, '\b(?:DB|PROC|QRY)_\w+')) {
      [void]$declared.Add($match.Value)
    }
    # The module's own templates and tags too, as the full name_GUID the story uses. A
    # change that only adds facts and rules for a new container, reusing existing DB
    # and PROC names, introduces no new identifier above; the container is what it adds.
    foreach ($match in [regex]::Matches($goalText, '\bBAGCEPTION_\w+?_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b')) {
      [void]$declared.Add($match.Value)
    }
  }

  $missing = @($declared | Where-Object { $compiled -notmatch "\b$([regex]::Escape($_))\b" } | Sort-Object)

  if ($missing.Count -gt 0) {
    throw @"
The compiled story is stale. These identifiers are in the authored goals but not in
the story the Toolkit built:

  $($missing -join "`n  ")

The Toolkit builds from the game data directory, so source edits reach it only after
a sync. Run:

  .\tools\Sync-ToolkitProject.ps1 -Direction ToGame

then rebuild the story in the Toolkit, then package again.
"@
  }

  # Every authored goal must appear in the compiled story as a registered goal. The
  # Story Editor compiles only goals it knows about, and a .txt dropped into
  # RawFiles/Goals is not one: the build reports 0 errors and omits it. A goal that
  # declares no DB_/PROC_/QRY_ identifier is invisible to the check above, so the
  # goal titles are verified separately.
  $missingGoals = @(Get-ChildItem -LiteralPath $authoredGoals -Recurse -File -Filter "*.txt" |
    Where-Object { $compiled -notmatch "Goal\(\d+\)\.Title\(""$([regex]::Escape($_.BaseName))""\)" } |
    ForEach-Object { $_.BaseName })

  if ($missingGoals.Count -gt 0) {
    throw @"
These goals were authored but are not registered in the compiled story:

  $($missingGoals -join "`n  ")

The Story Editor compiles only goals it has registered. Create the goal in the
editor, or move its rules into a goal that is already registered, then rebuild.
"@
  }

  Write-Host "Story freshness verified: $($declared.Count) module identifier(s) present in the compiled story"
}

Write-Host "Prepared unpacked package stage at $moduleStage"
Write-Host "Run tools\Build-Pak.ps1 to create dist\$moduleName.pak."
