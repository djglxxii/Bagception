# Work log

## 2026-09-20

- Read `spec.md` and `mod-references.md`, and surveyed the sibling BG3 mod repositories in `C:\src` for the house layout and tooling conventions.
- Created the repository scaffold: source tree, module identity, Script Extender manifest, tooling, documentation, and tracking.
- Verified the toolchain end to end. `Test-LocalPaths.ps1` resolves the game and mods directories, `Test-Lua.ps1` compiles the bootstrap probe, and `Build-Pak.ps1` produced `dist/Bagception.pak` containing the two localization files, `meta.lsx`, `Config.json`, and `BootstrapServer.lua`.
- Not done: the package has not been deployed or loaded in game, and no gameplay behaviour exists yet.
