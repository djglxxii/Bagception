# Progress

## Phase 0 — Scaffold

- [x] Create the repository layout following `C:\src\MoreHirelings`.
- [x] Author provisional module identity and Toolkit project registration at 1.0.0.0.
- [x] Add Toolkit sync, offline packaging, and deployment tooling under `tools/`.
- [x] Record the native-only constraint in `AGENTS.md`, `CLAUDE.md`, and the spec preamble.
- [x] Verify the offline packager produces a package with the expected contents.

## Phase 1 — Probe and proof of concept

- [ ] Create the `Bagception` project in the official Toolkit.
- [ ] Reconcile the Toolkit-generated identity with the provisional UUIDs.
- [ ] Author the master bag and one sub-bag, inheriting vanilla container templates.
- [ ] Tag the sub-bag with a vanilla auto-collect tag.
- [ ] Measure in game: which Osiris event reports container ingress, and whether it
      distinguishes root from sub-bag.
- [ ] Measure in game: how much vanilla auto-collect handles unaided.
- [ ] Record both results in the developer handbook.
- [ ] Write and verify the routing goal.

## Research

- [ ] Can the native system make container contents weightless, or approximate it?

Later phases are in [`../implementation-plan.md`](../implementation-plan.md).
Acceptance criteria AC-01 to AC-24 become a checklist here once Phase 1 lands.
