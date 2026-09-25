# AGENTS.md

## Project

This repository is for a Baldur's Gate 3 mod named `Bagception`: one bag in the
player's inventory holding a fixed set of specialized auto-sorting containers. Items
placed into the master bag are filed into the right internal container, and the
internal containers can never leave it.

The release path is Larian's official Toolkit and mod.io, through the in-game mod
manager.

## Hard constraints

- **Do not introduce Script Extender, third-party mod dependencies, or a Nexus-specific
  release workflow.** This mod uses Larian's native mod system and Osiris scripting
  only. If a feature appears to require the Script Extender, stop and raise it with the
  user rather than adding the dependency.
  - A **separate** Script Extender companion was once considered, to add weightless
    storage; the base mod now does that natively (1.0.0.5). See
    [`docs/script-extender-edition.md`](docs/script-extender-edition.md). That does not
    relax this rule for the base mod, and it places two constraints on work here:
    container tags are a published contract, and container template UUIDs are never
    reissued after release.
- Anything BG3's native auto-collect containers can do, they should do. Osiris covers
  only what the native system cannot.
- Keep the Toolkit project name and mod folder name `Bagception`.

## Layout

`src/` mirrors the five folders a Larian Toolkit project uses under the game's `Data/`
directory, plus localization:

| Repository path | Toolkit purpose |
| --- | --- |
| `src/Projects/Bagception/` | Project registration and settings |
| `src/Editor/Mods/Bagception/` | Editor-only source data |
| `src/Mods/Bagception/` | Packed mod data, metadata, and Osiris story |
| `src/Public/Bagception/` | Root templates, tags, stats |
| `src/Generated/Public/Bagception/` | Generated public assets, if needed |
| `src/Localization/English/` | English localization source |

Also:

- `tools/` helper scripts.
- `dist/` and `tmp/` generated output and scratch data, both ignored.
- `docs/developer-handbook.md` durable lessons, tool pitfalls, resolved issues.
- `docs/tracking/` progress, decisions, open questions, dated work log.

Empty folders carry `.gitkeep` until the Toolkit creates real content. They do not
form a valid mod by themselves.

## Design documents

- [`spec.md`](spec.md) is the design specification. **Read its preamble first:** the
  document was drafted assuming the Script Extender, and the sections that depend on
  that assumption are superseded.
- [`mod-references.md`](mod-references.md) lists reference mods. Several are Script
  Extender mods and are useful only for their design lessons, not their technique.

## Conventions

- Use `tools/Sync-ToolkitProject.ps1 -Direction FromGame` to capture Toolkit output.
  Review the diff before committing.
- Keep module folder name, package name, and internal IDs aligned as `Bagception`.
- Use the metadata `Name` value `Bagception` as the friendly in-game display name.
- The module UUID is provisional until the official Toolkit project is created;
  reconcile the generated identity with it before publishing or creating long-term
  saves. Never copy another mod's UUID.
- Keep generated build artifacts and third-party binaries out of source control.
- Extracted vanilla game data belongs under `tmp/`, never under tracked source.
- Do not copy into the player's Mods directory except as an explicit test or deploy step.
- Use ASCII unless an existing BG3 or localization file requires otherwise.
- Record verified data relationships and implementation decisions under `docs/`.
- Commit only when the user explicitly asks.

## Implementation rules from the spec

Load-bearing regardless of how the mod is built:

- Sorting triggers only when an item enters the Bagception **root**. Never manage the
  player's inventory, other containers, or items already inside a sub-bag.
- Never destroy an item to resolve an organizational error. When uncertain, leave it
  where it is; the safe fallback is the Bagception root.
- Protected, quest, and story items stay at the root, never in a sub-bag.
- Guard every mod-initiated move so sorting cannot loop.
- Classify by item properties and tags, not by UUID lists, so modded items sort too.

## Local Paths

The local path file is `dirs.txt`, ignored by git because it holds machine-specific
paths. Copy `dirs.example.txt` to create it. Current values:

- BG3 game directory: `C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3`
- BG3 mods directory: `C:\Users\djgLXXII\AppData\Local\Larian Studios\Baldur's Gate 3\Mods`
- BG3 Mod Manager: `C:\src\BG3ModManager\BG3ModManager.exe`
