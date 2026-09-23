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
- [x] Write and verify the routing goal. `Bagception_Sorter.txt`, per-item routing on
      `TemplateAddedTo`.

## Phase 3 — The sorter

- [x] Choose the routing mechanism. Per-item on `TemplateAddedTo`, not bulk
      `MagicPocketsMoveToByTag`; reasoning in the decision log.
- [x] Establish the rule shape on one category. Shields into the Shield Rack,
      verified in a fresh game: shields route, an off-hand dagger does not. First
      confirmed Osiris routing — the Potion Case result was native auto-collect.
- [x] Confirm the discriminator for the hardest category. Shields share MeleeOffHand
      with off-hand weapons and are separated by `IsWeapon`.
- [x] Confirm all sixteen categories are classifiable. The six with no vanilla tag
      resolve through `IsWeapon`, `GetEquipmentSlotForItem`, `GetStatString` +
      `Substring`, and `ItemGetGoldValue`.
- [ ] Settle whether native auto-collect covers the ten tag-expressible categories
      on its own. Build the next tagged container with a filter and no Osiris rule;
      if it sorts, those ten are data-only and need no rules.
- [x] Author the remaining containers: root templates, Object entries,
      localization, and treasure-table contents. Seventeen internal containers; the
      spec's Valuables was dropped in favour of one catch-all.
- [x] Write the routing rule for each. Sixteen verified in game 2026-09-23; the Odds
      Sack catch-all awaiting test.
- [x] Settle the shield discriminator. Valuables dropped, so no gold threshold.
- [x] Verify whether a new goal merges into a save that has never seen it. It does:
      the 2026-09-23 Act 1 load granted bags and initialised the goal in a save that
      had never had the mod.
- [x] Verify that rule changes reach a save made with an earlier build. They do when
      `Version64` changes (2026-09-23, Act 2 save, 1.0.0.0 to 1.0.0.1), and not otherwise.
- [ ] See the bag repair add a missing container in a save whose bags predate one.

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
