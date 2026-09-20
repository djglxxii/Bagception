# Claude Instructions for Bagception

Read [`AGENTS.md`](AGENTS.md) first. It holds the layout, the hard constraints, and the
load-bearing implementation rules. Read `docs/developer-handbook.md` before starting a
new implementation phase, and update it whenever a session learns something that would
otherwise have to be rediscovered.

## Constraints (always apply)

- **No Script Extender, no third-party mod dependencies, no Nexus release workflow.**
  Native Larian mod system and Osiris only. If something seems to need the Script
  Extender, raise it; do not add it.
- Never destroy or delete a player item to resolve a sorting problem.
- Never sort anything outside Bagception's own hierarchy.
- Never copy code verbatim from the reference mods; study them.
- Prefer native auto-collect behaviour over Osiris wherever it works.
- Commit only when the user explicitly asks.
- Give concrete in-game test steps before reporting a task complete; the user verifies.

## Precedent

When a question about repository shape, tooling, or workflow comes up, follow
`C:\src\MoreHirelings`. It is the same kind of project: Toolkit-built, Osiris-scripted,
mod.io-published, no Script Extender. The Script Extender projects in `C:\src`
(`RandomizedDisguiseSelf`, `PlanarEmissary`) are not the model for this one.

## Local workflow

The Toolkit is the build path. These scripts support it:

```powershell
.\tools\Test-LocalPaths.ps1                                  # validate dirs.txt
.\tools\Sync-ToolkitProject.ps1 -Direction FromGame -WhatIf  # preview capture
.\tools\Sync-ToolkitProject.ps1 -Direction FromGame          # capture Toolkit output
.\tools\Build-Pak.ps1                                        # offline test package
.\tools\Deploy-Pak.ps1 -PakPath .\dist\Bagception.pak        # copy to BG3 Mods folder
```

Close BG3 before deploying; a running game locks the installed `.pak`.

Once Osiris goals exist, build the story in the Toolkit and sync `FromGame` before
building an offline package. A data-only package silently lacks the compiled story.

## Release workflow

Releases go through the Toolkit's Publish Local and mod.io publishing actions, not
through the offline packager. When the user asks for a version bump:

1. Update `Version64` in both `ModuleInfo` and `PublishVersion` in `meta.lsx`
   (`major << 55 | minor << 47 | revision << 31 | build`).
2. Build and verify a local `.pak` through the Toolkit.
3. Update `CHANGELOG.md`.
4. Commit, then move the annotated tag to the new commit.
