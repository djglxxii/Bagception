# Progress

## Phase 0 — Scaffold

- [x] Create the repository layout following `C:\src\MoreHirelings`.
- [x] Author provisional module identity and Toolkit project registration at 1.0.0.0.
- [x] Add Toolkit sync, offline packaging, and deployment tooling under `tools/`.
- [x] Record the native-only constraint in `AGENTS.md`, `CLAUDE.md`, and the spec preamble.
- [x] Verify the offline packager produces a package with the expected contents.

## Phase 1 — Probe and proof of concept

- [x] Create the `Bagception` project in the official Toolkit.
- [x] Reconcile the Toolkit-generated identity with the provisional UUIDs.
      Adopted the Toolkit's `bc5967cf-…` and `88f0c9c4-…`.
- [x] Author the master bag and one sub-bag, inheriting vanilla container templates,
      both at zero weight.
- [x] Give the sub-bag a `ContainerContentFilterCondition`.
- [x] Author the mod-owned tags, localization, and the Osiris probe goal.
- [x] Verify every authored resource converts and packages.
- [x] Compile the probe goal without errors in the Story Editor.
- [x] Run the probe in game. Procedure: [`../phase1-probe.md`](../phase1-probe.md).
- [x] Measure in game: which Osiris event reports container ingress, and whether it
      distinguishes root from sub-bag. **`TemplateAddedTo`; yes, holder is the container.**
- [x] Measure in game: how much vanilla auto-collect handles unaided. **None of it
      while nested; Osiris must route everything.**
- [x] Record both results in the developer handbook.
- [ ] Write and verify the routing goal.

## Shipping content so far

- [x] Master bag and Potion Case root templates, vanilla-inherited, zero weight.
- [x] `BAGCEPTION_CARRY`: `CarryCapacityMultiplier(2.0)` while the bag is carried,
      granted by `StatusInInventory` on the master bag. Replaces weightless contents.
- [x] Verified in game 2026-09-21: a new character starts with a Bagception, and
      Lae'zel had one on joining the party. Both grant paths work — the
      `DB_Players` sweep at level start and `CharacterJoinedParty`.
- [x] Potion Case confirmed inside each bag.
- [x] Carry boost confirmed to follow the bag: Lae'zel 420 -> 210 when hers was
      given away.
- [x] Duplicate grant **found and fixed**. An existing save gave one character two
      bags, because `TemplateAddTo` is asynchronous and two triggers both saw an
      empty inventory in the same tick. Debounced with `DB_Bagception_GrantPending`.
- [x] Character creation dummies were also being given bags; sweep now skips
      character creation levels.
- [x] **Duplicate fix verified on the real failure path**, 2026-09-21. A save where
      the mod had never been enabled — so every character started at zero bags,
      which is the exact condition that produced duplicates — gave every character
      exactly one bag, each containing a Potion Case.
- [ ] Cosmetic: the master bag shows no content count despite holding the Potion
      Case. Suspected to be a weight display with zero-weight contents rather than a
      bug; confirm by putting a potion in the bag.

## Research

- [x] Can the native system make container contents weightless, or approximate it?
      Answered: no. See `docs/research/native-capabilities.md`. The requirement was
      dropped; Bagception is an organizer.

Later phases are in [`../implementation-plan.md`](../implementation-plan.md).
Acceptance criteria AC-01 to AC-24 become a checklist here once Phase 1 lands.
