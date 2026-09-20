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

## Project direction

Bagception is built with Larian's official Toolkit and Osiris, published to mod.io.
**No Script Extender, no third-party mod dependencies, no Nexus workflow.** The
`spec.md` draft assumed the Script Extender throughout; its preamble records which
sections that invalidates. `C:\src\MoreHirelings` is the precedent project for
repository shape, tooling, and workflow.

## Local paths and tools

Verified on 2026-09-20 on this machine:

- BG3 game directory: `C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3`
- BG3 mods directory: `C:\Users\djgLXXII\AppData\Local\Larian Studios\Baldur's Gate 3\Mods`
- BG3 Mod Manager: `C:\src\BG3ModManager\BG3ModManager.exe`
- LSLib ExportTool v1.20.4: `tools/external/ExportTool-v1.20.4/Packed/Tools/Divine.exe`,
  copied from `C:\src\RandomizedDisguiseSelf` during setup rather than re-downloaded.
  `tools/Install-ExportTool.ps1` fetches it from GitHub on a clean machine.

The Script Extender loader is present in the game's `bin/` on this machine because
other projects use it. Bagception must not depend on it, and must be tested with it
absent or disabled before release.

## Repository hygiene

- `dirs.txt` is ignored and holds machine-specific paths. `dirs.example.txt` is tracked.
- `dist/`, `tmp/`, and `tools/external/` are ignored.
- Extracted vanilla game data belongs under `tmp/`, never under tracked source.
- BG3 writes its own log files (`errors.*.txt`, `log.*.txt`, `thothlog.*.txt`, and
  friends) into whatever directory it is launched from; those patterns are ignored.

## Toolkit workflow

- The Toolkit owns five folders under the game's `Data/` directory: `Projects/`,
  `Editor/Mods/`, `Mods/`, `Public/`, and `Generated/Public/`. `src/` mirrors all five.
- `tools/Sync-ToolkitProject.ps1 -Direction FromGame` captures Toolkit output into
  `src/`; `-Direction ToGame` restores it. It copies only the five `Bagception`
  folders and never deletes destination files. Use `-WhatIf` first.
- The Toolkit builds the test `.pak` through **Project Settings -> Publish Local**,
  and handles mod.io publishing.
- The Toolkit packs the project workspace verbatim. A stale compiled `.lsf` in `src/`
  ships even when a hand-built package looks correct, so regenerate and sync before
  building there.

## Osiris

- Osiris story goals live under `src/Mods/Bagception/Story/`. They must be compiled in
  the Toolkit Story Editor; an offline package built without `story.div.osi` silently
  contains no story at all. The MoreHirelings builder throws rather than allow this,
  and any offline packager here should do the same once goals exist.
- Osiris asserts `INITSECTION` facts once, when a goal is first initialized in a save.
  A goal added after distribution does initialize on load in an existing save, but an
  existing goal's `INITSECTION` does not re-run. Plan roster or registration changes
  around that: new facts need a new goal, not an edit to an old one.
- `TemplateAddedTo((ROOT)_ObjectTemplate, (GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder, (STRING)_AddType)`
  is confirmed present, as is the simpler `AddedTo`. What `_InventoryHolder` refers to
  is not yet known; the Phase 1 probe answers it.
- **The `AddType` strings are not enumerated anywhere in `story_header.div`.** Do not
  match them against guessed literals. The probe prints whatever the engine passes;
  record the observed values here.
- Useful calls confirmed for the sorter: `ToInventory` and `MoveItemTo` to move,
  `GetItemByTagInInventory` to locate a container by tag, `IsContainer`, `IsTagged`,
  `IsCharacter`, `IsItem`, `GetHostCharacter`, `ShowNotification` and `DebugText` for
  diagnostics, and the `Concatenate*` family for building message strings.
- `MagicPockets*` is a whole Larian bag subsystem visible in the API
  (`MagicPocketsMoveToByTag`, `IsInMagicPockets`, and more). Unexplored, and possibly
  relevant to Bagception. Worth a look before building the sorter.

### Authored container templates

- Both probe containers inherit `CONT_Bag_A`,
  `3e6aac21-333b-4812-a554-376c2d157ba9`, from **Gustav.pak**: `InventoryType 11`,
  `Stats OBJ_GenericLootItem`, with icon, visual, physics and bounds. Inheriting it
  means not setting those, which is why the templates are short.
- Do not invent icon names. `Item_CONT_GEN_Bag_A` was assumed during authoring and
  does not exist; the real icon on `CONT_Bag_A` is `Item_LOOT_Bag_Blackpowder`.
  Inherit rather than name one.
- Localization handles are `h` + a GUID with `g` in place of each `-`. They must match
  between the template and `Bagception.xml`, version attribute included.

## LSLib and Divine

Divine is a convenience for offline test packages only. Releases go through the Toolkit.

- Divine requires absolute paths for extraction destinations. A relative `-d tmp\...`
  fails with `Cannot proceed without absolute path`.
- Run one `extract-package` per `-x` glob. Semicolon-separated patterns have silently
  extracted nothing in sibling projects.
- Create a package:

  ```powershell
  .\tools\external\ExportTool-v1.20.4\Packed\Tools\Divine.exe -a create-package -g bg3 -s "<stage dir>" -d "<pak path>"
  ```

- Inspect one:

  ```powershell
  .\tools\external\ExportTool-v1.20.4\Packed\Tools\Divine.exe -a list-package -g bg3 -s "<pak path>"
  ```

## Localization

- The game reads compiled `.loca`, not the authored `.xml`. `tools/Package-Mod.ps1`
  compiles every staged localization `.xml` in place and leaves both in the package.
- Conversion works in both directions with `convert-loca`; `convert-resource` does not
  accept `-i loca -o xml`:

  ```powershell
  ... \Divine.exe -g bg3 -a convert-loca -s "<source>" -d "<target>"
  ```

- Vanilla English strings live in `Data\Localization\English.pak`, file
  `Localization/English/english.loca`.
- The Toolkit reads localization from the project workspace. MoreHirelings keeps two
  copies in sync, one for the Toolkit and one for its offline builder; watch for the
  same requirement here once strings exist.

## Validation

- A successful `Build-Pak.ps1` proves the layout stages and packs. It proves nothing
  about in-game behaviour; the user verifies that.
- BG3 Mod Manager will not list the mod until a `.pak` exists in the BG3 Mods folder.
- `Deploy-Pak.ps1` fails if BG3 is running, because the installed pak is locked.

## Mod identity

- Module UUID `f2470481-03f2-4439-83d5-68f2e26ae076`, generated for this project on
  2026-09-20. It is **provisional**: the official Toolkit generates its own identity
  when the project is created, and the two must be reconciled before publishing or
  before any long-term save is created. Never reuse another mod's UUID.
- Toolkit project UUID `a1b4cb49-e5c2-44a0-92bd-5d90378e7723`, same caveat.
- `Version64` packs as `major << 55 | minor << 47 | revision << 31 | build`.
  1.0.0.0 is `36028797018963968`. Update it in both `ModuleInfo` and `PublishVersion`.
