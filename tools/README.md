# Tools

PowerShell helpers for local BG3 development. Run them from the repository root.

- `Test-LocalPaths.ps1` validates `dirs.txt` and prints the resolved game and mods directories.
- `Install-ExportTool.ps1` downloads Norbyte's LSLib ExportTool into ignored `tools/external/`.
- `Test-Lua.ps1` syntax-checks every file under `src/Mods/Bagception/ScriptExtender/Lua/`.
- `Package-Mod.ps1` stages `src/Mods`, `src/Public`, and `src/Localization` under `dist/unpacked/Bagception/` and compiles each staged localization `.xml` to `.loca`.
- `Build-Pak.ps1` stages the mod and uses Divine to create `dist/Bagception.pak`.
- `Deploy-Pak.ps1 -PakPath .\dist\Bagception.pak` copies an explicit `.pak` to the local BG3 Mods directory.
- `Sync-SourceToGameData.ps1` copies `src/` folders into the BG3 `Data/` loose-file layout for editor-style testing. Use `-WhatIf` first.

Deploy is intentionally separate from staging and packaging. Close BG3 before deploying: a running game locks the existing `.pak`.

`tools/external/` is ignored because it holds third-party binaries.
