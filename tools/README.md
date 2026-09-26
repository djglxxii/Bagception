# Tools

PowerShell helpers for local BG3 development. Run them from the repository root.

The official Larian Toolkit is the primary build path: it creates the test `.pak`
through **Project Settings -> Publish Local**, compiles Osiris story goals, and
publishes to mod.io. These scripts support that workflow; they do not replace it.

- `Test-LocalPaths.ps1` validates `dirs.txt` and prints the resolved directories.
- `Sync-ToolkitProject.ps1 -Direction FromGame` captures Toolkit output from the
  game's `Data/` folder into `src/`. `-Direction ToGame` restores tracked files to the
  Toolkit workspace. Use `-WhatIf` first. It copies only the five `Bagception` folders
  and never deletes destination files.
- `Package-Mod.ps1` stages `src/Mods`, `src/Public`, and `src/Localization` under
  `dist/unpacked/Bagception/` and compiles each staged localization `.xml` to `.loca`.
- `Build-Pak.ps1` stages the mod and uses Divine to create `dist/Bagception.pak`.
- `Test-Package.ps1 -PakPath <pak>` lists a package and fails if the strings, story,
  templates, stats, icon sheet or any tooltip or controller icon is missing. Run it on the Toolkit's Publish Local
  output before every upload.
- `Deploy-Pak.ps1 -PakPath .\dist\Bagception.pak` copies a `.pak` to the BG3 Mods folder.
- `Build-Icons.py` builds every icon file from `art/icons/*.png` and sets each bag's
  template `Icon`. Run `python tools/Build-Icons.py` after changing the art.
- `Install-Texconv.ps1` downloads Microsoft's texconv into ignored `tools/external/`;
  `Build-Icons.py` uses it for DDS compression.
- `Install-ExportTool.ps1` downloads Norbyte's LSLib ExportTool into ignored
  `tools/external/`.

`Package-Mod.ps1`, `Build-Pak.ps1`, and `Deploy-Pak.ps1` exist for quick offline test
packages only, the same role `Build-Prototype.ps1` serves in the MoreHirelings project.
Releases go through the Toolkit. Once Osiris goals exist, an offline package is only
valid if the compiled story has been built in the Toolkit and synced `FromGame` first;
a data-only package will silently lack the story.

Close BG3 before deploying: a running game locks the installed `.pak`.
`tools/external/` is ignored because it holds third-party binaries.
