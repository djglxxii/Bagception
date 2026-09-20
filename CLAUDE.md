# Claude Instructions for Bagception

Read [`AGENTS.md`](AGENTS.md) first; it holds the layout, conventions, and the
load-bearing implementation rules. Read `docs/developer-handbook.md` before starting a
new implementation phase, and update it whenever a session learns something that would
otherwise have to be rediscovered.

## Constraints (always apply)

- Never destroy or delete a player item to resolve a sorting problem.
- Never sort anything outside Bagception's own hierarchy.
- Never `tostring()` a BG3SE proxy object; describe it defensively instead.
- Never hold BG3SE entity or component userdata across a tick. Keep string UUIDs and
  reacquire with `Ext.Entity.Get` inside the callback.
- Never copy code verbatim from the reference mods in `mod-references.md`. Study them.
- Commit only when the user explicitly asks.
- Give concrete in-game test steps before reporting a task complete; the user verifies.

## Local workflow

```powershell
.\tools\Test-LocalPaths.ps1                              # validate dirs.txt
.\tools\Test-Lua.ps1                                     # syntax-check Lua
.\tools\Build-Pak.ps1                                    # stage + pack dist\Bagception.pak
.\tools\Deploy-Pak.ps1 -PakPath .\dist\Bagception.pak    # copy to the BG3 Mods folder
```

Close BG3 before deploying; a running game locks the installed `.pak`.

## Release workflow

When the user asks for a version bump:

1. Update `Version64` in both `ModuleInfo` and `PublishVersion` in `meta.lsx`
   (`major << 55 | minor << 47 | revision << 31 | build`).
2. Syntax-check all Lua with `tools\Test-Lua.ps1`.
3. Build with `tools\Build-Pak.ps1` and deploy with `tools\Deploy-Pak.ps1`.
4. Update `CHANGELOG.md` with the new version entry.
5. Commit, then move the annotated tag to the new commit.
