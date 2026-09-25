# Bagception

A Baldur's Gate 3 mod: one bag in your inventory that holds every other bag.

> **One bag in your inventory. Every other bag inside it. Everything where it belongs.**

Items dropped into Bagception are filed into the right internal container
automatically. The internal containers are permanent and cannot leave the master bag.
The bags themselves weigh nothing; what you store in them weighs what it always did.

Built with Larian's official Toolkit and Osiris scripting, for release through mod.io
and the in-game mod manager. **No Script Extender and no third-party mod dependencies.**

## Status

Scaffold only. The repository holds an identity-complete module with no content and no
behaviour yet. See [`docs/tracking/progress.md`](docs/tracking/progress.md).

Everything inside Bagception weighs nothing, without the Script Extender: a hidden
status zeroes each item's weight while it is inside and is removed when it comes
out. See the decision log, 2026-09-20 to 2026-09-23.

## Design

- [`spec.md`](spec.md) is the design specification. **Read its preamble first:** it was
  drafted against a Script Extender implementation, and the sections resting on that
  assumption are superseded.
- [`mod-references.md`](mod-references.md) records which existing mods to study.
- [`docs/implementation-plan.md`](docs/implementation-plan.md) maps the phases onto
  this repository.
- [`docs/developer-handbook.md`](docs/developer-handbook.md) holds durable local
  knowledge: tool paths, Divine invocations, Toolkit and Osiris pitfalls.

## Project layout

`src/` mirrors the five folders a Larian Toolkit project uses under the game's `Data/`
directory:

| Repository path | Toolkit purpose |
| --- | --- |
| `src/Projects/Bagception/` | Project registration and settings |
| `src/Editor/Mods/Bagception/` | Editor-only source data |
| `src/Mods/Bagception/` | Packed mod data, metadata, and Osiris story |
| `src/Public/Bagception/` | Root templates, tags, stats |
| `src/Generated/Public/Bagception/` | Generated public assets, if needed |

Plus `src/Localization/English/` for localization, `tools/` for helper scripts, and
`docs/` for the handbook, plan, research, and tracking. `dist/` and `tmp/` are ignored.

The empty folders contain `.gitkeep` files until the Toolkit creates real content. They
do not form a valid mod by themselves.

## Getting started

1. Open the official Baldur's Gate 3 Toolkit on the development machine.
2. Open or create the `Bagception` project. The module UUID in `meta.lsx` is
   provisional; reconcile the Toolkit-generated identity with it before publishing or
   creating long-term saves.
3. Copy `dirs.example.txt` to `dirs.txt` and set `game_dir` and `mod_dir` for your
   machine. `dirs.txt` is ignored by git.
4. Run `.\tools\Sync-ToolkitProject.ps1 -Direction FromGame` to capture Toolkit-created
   files under `src/`. Review the diff before committing.
5. Make content changes in the Toolkit, then sync again after each editing session.

Use **Project Settings -> Publish Local** in the Toolkit to build a test `.pak`, and
the Toolkit's mod.io publishing action only once the mod has been implemented and
tested. Publishing publicly is a separate decision.

`.\tools\Build-Pak.ps1` and `.\tools\Deploy-Pak.ps1` build and install a quick offline
test package. They are a convenience for iteration, not the release path.

## References

- [Larian: Creating a New Mod](https://docs.baldursgate3.game/Getting_Started:_Creating_a_New_Mod)
- [Larian: Publishing a Mod](https://docs.baldursgate3.game/Getting_Started:_Publishing_a_Mod)
