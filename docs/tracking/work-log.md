# Work log

## 2026-09-20

### Initial scaffold (superseded)

- Read `spec.md` and `mod-references.md`, surveyed the sibling BG3 mod repositories in
  `C:\src`, and created a repository scaffold, committed as `8fc6b30`.
- That scaffold was built Script-Extender-first and Nexus-targeted, following the
  runtime dependency stated in `spec.md` instead of the user's instruction to use
  `MoreHirelings` as the template. See the decision log.

### Direction set

- The user set the constraint: native Larian mod system and Osiris only, published
  through the Toolkit to mod.io. No Script Extender, no third-party dependencies,
  no Nexus.
- Answered the open questions: probe build for the ingress event, vanilla-inherited
  templates with custom art deferred to Phase 8, native-first classification, flat
  hierarchy, mod.io release, no MCM.
- Weightless storage became an open research question rather than a settled design.

### Rework

- Removed the Script Extender tree and the Lua tooling. Restructured `src/` to the
  five Toolkit-owned paths plus localization, and rewrote `meta.lsx` in the Toolkit
  shape with a project registration alongside it.
- Replaced the loose-file sync with `Sync-ToolkitProject.ps1`. Kept the Divine
  packager as an offline test path only.
- Rewrote `AGENTS.md`, `CLAUDE.md`, `README.md`, the handbook, the implementation
  plan, and all tracking documents for the native direction, and added a
  superseded-premise preamble to `spec.md`.
- Verified the offline packager still builds a correct package.
- Not done: the Toolkit project has not been created, no content or behaviour exists,
  and nothing has been loaded in game.
