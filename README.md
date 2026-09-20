# Bagception

A Baldur's Gate 3 mod: one weightless Bag of Holding that contains every other bag.

> **One bag in your inventory. Every other bag inside it. Everything where it belongs.**

Items dropped into Bagception are classified and filed into the right internal
container automatically. The internal containers are permanent and cannot leave the
master bag. Everything stored inside contributes zero carried weight.

## Status

Scaffold only. The repository builds and packages an empty, identity-complete module;
no gameplay behaviour has been implemented yet. See
[`docs/tracking/progress.md`](docs/tracking/progress.md).

## Requirements

- Baldur's Gate 3, PC.
- [Norbyte's BG3 Script Extender](https://github.com/Norbyte/bg3se). Classification,
  routing, weightless storage, and container protection all run in Script Extender Lua,
  so this mod cannot ship through the in-game mod manager's Toolkit-only path. The
  intended release channel is Nexus Mods.

## Design

- [`spec.md`](spec.md) is the authoritative design specification, including the
  category list, sorting pipeline, safety rules, and the 24 acceptance criteria.
- [`mod-references.md`](mod-references.md) records which existing mods to study for
  which problem.
- [`docs/implementation-plan.md`](docs/implementation-plan.md) maps the spec's eight
  phases onto this repository.
- [`docs/developer-handbook.md`](docs/developer-handbook.md) holds durable local
  knowledge: tool paths, Divine invocations, BG3SE pitfalls.

## Project layout

| Path | Purpose |
| --- | --- |
| `src/Mods/Bagception/` | `meta.lsx` and the Script Extender manifest and Lua |
| `src/Public/Bagception/` | Root templates, stats, tags |
| `src/Localization/English/` | Localization source, compiled to `.loca` at package time |
| `tools/` | Local build, package, deploy, and validation scripts |
| `docs/` | Handbook, implementation plan, research, and tracking |
| `dist/`, `tmp/` | Generated output and scratch data; both ignored |

## Getting started

1. Install the Script Extender if it is not already present.
2. Copy `dirs.example.txt` to `dirs.txt` and set `game_dir` and `mod_dir` for your
   machine. `dirs.txt` is ignored by git.
3. Run `.\tools\Install-ExportTool.ps1` to fetch Norbyte's LSLib ExportTool into
   ignored `tools/external/`, unless it is already there.
4. Validate the setup with `.\tools\Test-LocalPaths.ps1`.
5. Build and deploy:

   ```powershell
   .\tools\Test-Lua.ps1
   .\tools\Build-Pak.ps1
   .\tools\Deploy-Pak.ps1 -PakPath .\dist\Bagception.pak
   ```

   Close BG3 first; a running game locks the installed package. Enable the mod in
   BG3 Mod Manager, then launch.
