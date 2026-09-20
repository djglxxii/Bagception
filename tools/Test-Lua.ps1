[CmdletBinding()]
param(
  # Lua 5.5 as installed on this machine. This interpreter has no -p flag, so
  # the check loads each file with loadfile and reports the compiler error.
  [string]$LuaPath = "C:\Users\djgLXXII\AppData\Local\Programs\Lua\5.5.0\lua.exe"
)

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

$repositoryRoot = (Get-BG3Paths).RepositoryRoot
$luaRoot = Join-Path $repositoryRoot "src\Mods\Bagception\ScriptExtender\Lua"

if (-not (Test-Path -LiteralPath $LuaPath)) {
  throw "Lua interpreter not found: $LuaPath"
}

if (-not (Test-Path -LiteralPath $luaRoot)) {
  throw "Lua source folder not found: $luaRoot"
}

$files = @(Get-ChildItem -LiteralPath $luaRoot -Recurse -File -Filter "*.lua")
if ($files.Count -eq 0) {
  Write-Host "No Lua files to check under $luaRoot"
  return
}

$failed = 0
foreach ($file in $files) {
  $script = "local f, err = loadfile([[$($file.FullName)]]); if not f then io.stderr:write(err); os.exit(1) end"
  & $LuaPath -e $script
  if ($LASTEXITCODE) {
    $failed++
    Write-Host "FAIL $($file.FullName)"
  } else {
    Write-Host "ok   $($file.FullName)"
  }
}

if ($failed) {
  throw "$failed Lua file(s) failed to compile."
}

Write-Host "All $($files.Count) Lua file(s) compiled."
