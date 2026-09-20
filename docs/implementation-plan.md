# Implementation plan

This maps the eight phases in [`../spec.md`](../spec.md) section 44 onto concrete
repository artifacts. It is a routing document, not a restatement of the spec: read
the spec for behaviour, read this for where the work lands.

Nothing below has been started. The repository currently holds a scaffold that builds
a valid but empty module.

## Phase 0 — Scaffold (done)

- Module identity in `src/Mods/Bagception/meta.lsx`, UUID
  `f2470481-03f2-4439-83d5-68f2e26ae076`, version 1.0.0.0.
- Script Extender manifest in `src/Mods/Bagception/ScriptExtender/Config.json`.
- Build, package, deploy, and validation scripts under `tools/`.
- Verified: `Build-Pak.ps1` produces a loadable package layout.

## Phase 1 — Proof of concept

Prove `Longsword -> Weapons`, `Potion -> Potions`, unknown -> `Miscellaneous` through
a nested hierarchy with three containers.

- `src/Public/Bagception/RootTemplates/` master bag and three container templates.
- `src/Public/Bagception/Tags/` the `BAGCEPTION_MASTER` and `BAGCEPTION_INTERNAL` tags.
- `Lua/Server/Bagception/Constants.lua`, `Containers.lua`, `Classifier.lua`,
  `Sorter.lua`, `Logging.lua`.
- `Lua/BootstrapServer.lua` replaces the scaffold load probe with the real requires.
- Ingress event and re-entrancy guard (spec sections 9 and 10).

Open question first: confirm which event fires for a player drag into a container and
whether it reports the destination container reliably. Record the answer in the
handbook before building on it.

## Phase 2 — Weightless storage

Validate spec section 31 Strategy A, then B if nesting breaks weight accounting.
Test: 100+ lb stored, carried weight unchanged.

## Phase 3 — Full classification

All categories from spec section 6, with the precedence order in section 12.
Category tables live in `Lua/Server/Data/Categories.lua`; per-template exceptions in
`Overrides.lua`.

## Phase 4 — Container protection

Removal, Send to Camp, party transfer, vendor, and barter protection plus the
integrity invariant in spec sections 15 to 17. `IntegrityManager.lua`.

## Phase 5 — Story safety

Protected-item detection and denylist, `Data/ProtectedItems.lua`. Unknown items with
story-like properties stay at the root.

## Phase 6 — Persistence and recovery

Existing-save installation, one bag per save, save/load validation, Recover Bagception,
duplicate consolidation. `Recovery.lua`.

## Phase 7 — Compatibility

Test against vanilla autosort bags, Containers Extended, Bag of Holding Reforged,
Automatic Inventory Manager, and common equipment and consumable mods.

## Phase 8 — Polish

Icons, names, tooltips, logging levels, manual Sort, Reorganize, Prepare for Uninstall.

## Acceptance

Spec section 43 lists AC-01 through AC-24. Track them as a checklist in
`docs/tracking/progress.md` once Phase 1 lands.
