# Developer Handbook

Durable project knowledge, recurring pitfalls, and resolved issues. Update this
whenever a session learns something that would otherwise have to be rediscovered.

## Maintenance rules

- Read this handbook before starting a new implementation phase.
- Add a short entry whenever a tool behaves unexpectedly, a command needs a
  non-obvious flag, a local path is confirmed, or a BG3 data relationship is mapped.
- Keep generated output and third-party binaries out of this file. Record the path,
  the command, and the conclusion instead.
- If a lesson changes the plan, also update `docs/tracking/`.

## Local paths and tools

Verified on 2026-09-20 on this machine:

- BG3 game directory: `C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3`
- BG3 mods directory: `C:\Users\djgLXXII\AppData\Local\Larian Studios\Baldur's Gate 3\Mods`
- BG3 Mod Manager: `C:\src\BG3ModManager\BG3ModManager.exe`
- Script Extender loader: `...\Baldurs Gate 3\bin\DWrite.dll` (present)
- Script Extender updater manifest: `%LOCALAPPDATA%\BG3ScriptExtender\Manifest-Release.json`;
  the local install has payloads for extender majors 31 and 32.
- Lua 5.5 interpreter: `C:\Users\djgLXXII\AppData\Local\Programs\Lua\5.5.0\lua.exe`
- LSLib ExportTool v1.20.4: `tools/external/ExportTool-v1.20.4/Packed/Tools/Divine.exe`,
  copied from `C:\src\RandomizedDisguiseSelf` during setup rather than re-downloaded.
  `tools/Install-ExportTool.ps1` fetches it from GitHub on a clean machine.

## Repository hygiene

- `dirs.txt` is ignored and holds machine-specific paths. `dirs.example.txt` is tracked.
- `dist/`, `tmp/`, and `tools/external/` are ignored.
- Extracted vanilla game data belongs under `tmp/`, never under tracked source.
- BG3 writes its own log files (`errors.*.txt`, `log.*.txt`, `thothlog.*.txt`, and
  friends) into whatever directory it is launched from; those patterns are ignored.

## Script Extender

- `Config.json` currently declares `RequiredVersion: 31`, `ModTable: Bagception`,
  `FeatureFlags: ["Lua"]`. Revisit the required version if the mod ends up needing
  only older APIs; players on an older extender cannot load a higher requirement.
- Server-side code lives under `Lua/Server/`, loaded from `Lua/BootstrapServer.lua`.
  Bagception is expected to be server-only; add `BootstrapClient.lua` only if a real
  client need appears. This is a house convention and differs from the folder sketch
  in spec section 37, which is not normative.
- Enable `CreateConsole` and `LogRuntime` in `ScriptExtenderSettings.json` to see
  extender output. Setting `LogDirectory` to an ignored path inside this repository
  makes the logs easy to inspect from here.
- BG3SE entity and component userdata must not be stored in Lua locals that outlive
  the callback tick. Keep string UUIDs and reacquire with `Ext.Entity.Get` inside the
  deferred callback.
- `Ext.IO.SaveFile(path, content)` writes under
  `%LOCALAPPDATA%\Larian Studios\Baldur's Gate 3\Script Extender\`, which is the
  practical way to dump large diagnostic snapshots.

## LSLib and Divine

- Divine requires absolute paths for extraction destinations. A relative `-d tmp\...`
  fails with `Cannot proceed without absolute path`.
- Run one `extract-package` per `-x` glob. Semicolon-separated patterns have silently
  extracted nothing in sibling projects.
- Package creation, as used by `tools/Build-Pak.ps1`:

  ```powershell
  .\tools\external\ExportTool-v1.20.4\Packed\Tools\Divine.exe -a create-package -g bg3 -s "<stage dir>" -d "<pak path>"
  ```

- Inspect a built package with:

  ```powershell
  .\tools\external\ExportTool-v1.20.4\Packed\Tools\Divine.exe -a list-package -g bg3 -s "<pak path>"
  ```

## Localization

- The game reads compiled `.loca`, not the authored `.xml`. `tools/Package-Mod.ps1`
  compiles every staged localization `.xml` in place and leaves both files in the
  package.
- Conversion action, both directions:

  ```powershell
  ... \Divine.exe -g bg3 -a convert-loca -s "<source>" -d "<target>"
  ```

- `convert-resource` does not accept `-i loca -o xml`; use `convert-loca`.
- Vanilla English strings live in `Data\Localization\English.pak`, file
  `Localization/English/english.loca`. Extract and convert it when a vanilla handle
  is needed.

## Validation

- Lua is not on PATH, and this Lua 5.5 build has no `-p` flag. `tools/Test-Lua.ps1`
  compiles each file with `loadfile` instead and fails the run on the first error.
- A successful `Build-Pak.ps1` proves the layout stages and packs. It proves nothing
  about in-game behaviour; the user verifies that.

## Packaging and loading

- BG3 Mod Manager will not list the mod until a `.pak` exists in the BG3 Mods folder.
- `Deploy-Pak.ps1` fails if BG3 is running, because the installed pak is locked.
- Verified on 2026-09-20: the scaffold packages to `dist/Bagception.pak` containing
  `Mods/Bagception/meta.lsx`, `Mods/Bagception/ScriptExtender/Config.json`,
  `Mods/Bagception/ScriptExtender/Lua/BootstrapServer.lua`, and both localization
  files. It has not been deployed or loaded in game.

## Mod identity

- Module UUID `f2470481-03f2-4439-83d5-68f2e26ae076`, generated for this project on
  2026-09-20. Do not reuse another mod's UUID, and do not change this one after
  release.
- `Version64` packs as `major << 55 | minor << 47 | revision << 31 | build`.
  1.0.0.0 is `36028797018963968`. Update it in both `ModuleInfo` and `PublishVersion`.
