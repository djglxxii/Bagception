[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$PakPath
)

# Checks a built package, above all one from the Toolkit's Publish Local, for the
# parts a release cannot do without. 1.0.0.7 went to mod.io missing its strings, and
# 1.0.0.10 missing its tooltip and controller icons; run this on every package before
# uploading it.

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

$pak = (Resolve-Path -LiteralPath $PakPath -ErrorAction Stop).Path
$divine = Get-DivinePath
$listing = @(& $divine -g bg3 -a list-package -s $pak 2>&1 | ForEach-Object { ($_ -split "`t")[0] })
if ($LASTEXITCODE -ne 0) {
  throw "Could not list $pak."
}

$iconRoot = Join-Path (Get-BG3Paths).RepositoryRoot "src\Mods\Bagception\GUI"
$iconCount = @(Get-ChildItem -LiteralPath $iconRoot -Recurse -File -Filter "Bagception_*.DDS").Count
$checks = [ordered]@{
  "meta.lsx"            = @($listing -match '^Mods/Bagception/meta\.lsx$').Count -eq 1
  "compiled story"      = @($listing -match '^Mods/Bagception/Story/story\.div\.osi$').Count -eq 1
  "strings"             = @($listing -match '^(Mods/Bagception/)?Localization/English/.+\.(xml|loca)$').Count -ge 1
  "root templates"      = @($listing -match '^Public/Bagception/RootTemplates/_merged\.lsf$').Count -eq 1
  "stats"               = @($listing -match '^Public/Bagception/Stats/Generated/Data/Object\.txt$').Count -eq 1
  "icon sheet"          = @($listing -match '^Public/Bagception/GUI/Bagception_Icons\.lsx$').Count -eq 1
  "tooltip and controller icons ($iconCount)" = @($listing -match '^Mods/Bagception/GUI/.+/Bagception_[^/]+\.DDS$').Count -eq $iconCount
}

# The compiled story must come from the current goals. Publish Local packs whatever
# story the Story Editor last wrote, and packs it without complaint if the editor
# never rebuilt.
$storyCheck = "story built from current goals"
$scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("bagception-check-" + [guid]::NewGuid())
try {
  & $divine -g bg3 -a extract-package -s $pak -d $scratch -x "*goals.raw" | Out-Null
  $raw = Get-ChildItem -LiteralPath $scratch -Recurse -File -Filter "goals.raw" | Select-Object -First 1
  $goals = Join-Path (Get-BG3Paths).RepositoryRoot "src\Mods\Bagception\Story\RawFiles\Goals"
  if ($raw) {
    $stale = @(Get-MissingStoryIdentifiers -GoalsDirectory $goals -CompiledStory (Get-Content -LiteralPath $raw.FullName -Raw))
    $checks[$storyCheck] = $stale.Count -eq 0
    if ($stale.Count -gt 0) { Write-Host "  Missing from the compiled story: $($stale -join ', ')" }
  } else {
    $checks[$storyCheck] = $false
  }
} finally {
  Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
}

$failed = 0
foreach ($check in $checks.GetEnumerator()) {
  if ($check.Value) { Write-Host "  ok       $($check.Key)" } else { Write-Host "  MISSING  $($check.Key)"; $failed++ }
}
if ($failed -gt 0) {
  throw "$failed check(s) failed. Do not upload $pak."
}
Write-Host "Package complete: $pak"
