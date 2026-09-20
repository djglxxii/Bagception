# AGENTS.md

## Project

This repository is for a Baldur's Gate 3 mod named `Bagception`: a weightless Bag of
Holding containing permanent, specialized auto-sorting bags. Items placed into the
master bag are routed into the correct internal bag automatically, and the internal
bags can never leave it.

The authoritative design document is [`spec.md`](spec.md). Reference mods worth
studying before implementing are listed in [`mod-references.md`](mod-references.md).
Neither file is a work log; record progress under `docs/tracking/`.

## Layout

Use the BG3-style source layout under `src/`:

- `src/Mods/Bagception/meta.lsx` module metadata and identity.
- `src/Mods/Bagception/ScriptExtender/Config.json` Script Extender manifest.
- `src/Mods/Bagception/ScriptExtender/Lua/` Lua runtime, server-side.
- `src/Public/Bagception/RootTemplates/` container root templates.
- `src/Public/Bagception/Stats/Generated/Data/` generated stats text files.
- `src/Public/Bagception/Tags/` mod-owned tag resources.
- `src/Localization/English/Bagception.xml` English localization source.
- `tools/` helper scripts.
- `dist/` generated packages (ignored).
- `tmp/` extracted game data and scratch output (ignored).
- `docs/developer-handbook.md` durable lessons, tool pitfalls, resolved issues.
- `docs/tracking/` progress, decisions, open questions, dated work log.

## Conventions

- This mod requires Norbyte's BG3 Script Extender. That is a deliberate dependency,
  unlike the other mods in `C:\src`.
- Keep module folder name, package name, Script Extender `ModTable`, and internal IDs
  aligned as `Bagception`.
- Use the metadata `Name` value `Bagception` as the friendly in-game display name.
- Preserve the `meta.lsx` UUID once released unless intentionally creating a separate
  mod identity. Never copy another mod's UUID.
- Keep generated build artifacts and third-party binaries out of source control.
- Prefer editing source files under `src/`; only write to the BG3 Mods directory
  through the explicit `Deploy-Pak.ps1` step.
- Extracted vanilla game data belongs under `tmp/`, never under tracked source.
- Use ASCII unless an existing BG3 or localization file requires otherwise.
- Syntax-check edited Lua with `tools\Test-Lua.ps1` before reporting work complete.
- Commit only when the user explicitly asks.

## Implementation rules from the spec

These are load-bearing and should survive any refactor:

- Sorting triggers only when an item enters the Bagception **root**. Never manage the
  player's inventory, other containers, or items already inside a sub-bag.
- Never destroy an item to resolve an organizational error. When uncertain, leave the
  item where it is; the safe fallback is the Bagception root.
- Protected, quest, and story items stay at the root and are never filed into a sub-bag.
- Guard every mod-initiated move against re-entrancy so sorting cannot loop.
- Classification is data-driven and property-based, so modded items sort without
  needing their UUIDs.

## Local Paths

The local path file is `dirs.txt`. It is ignored by git because it holds
machine-specific paths. Copy `dirs.example.txt` to create it. Current values:

- BG3 game directory: `C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3`
- BG3 mods directory: `C:\Users\djgLXXII\AppData\Local\Larian Studios\Baldur's Gate 3\Mods`
- BG3 Mod Manager: `C:\src\BG3ModManager\BG3ModManager.exe`
- Script Extender loader: `...\Baldurs Gate 3\bin\DWrite.dll`
- Lua 5.5 interpreter: `C:\Users\djgLXXII\AppData\Local\Programs\Lua\5.5.0\lua.exe`
