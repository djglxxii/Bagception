# Implementation plan

Where the work lands in this repository. Read [`../spec.md`](../spec.md) for behaviour,
starting with its preamble: the document was drafted against a Script Extender
implementation and several sections are superseded.

The architecture under the native-only constraint is:

```text
Item enters Bagception root
        |
        +-- BG3 native auto-collect files most items by itself
        |
        +-- Osiris covers only the gaps:
              categories vanilla lacks
              protected / story items
              container protection and integrity
              manual Sort / Reorganize
```

Nothing past Phase 0 has been started.

## Phase 0 — Scaffold (done)

- Toolkit-shaped `src/` with the five Toolkit-owned paths plus localization.
- Provisional module identity, version 1.0.0.0, to be reconciled with the
  Toolkit-generated identity when the project is created.
- `Sync-ToolkitProject.ps1` plus an offline Divine packager for quick iteration.

## Phase 1 — Probe and proof of concept

The probe comes first because two assumptions have to be tested before any pipeline is
written, and one build answers both.

1. Create the Toolkit project and reconcile identities.
2. Author two containers, both inheriting vanilla container templates: the Bagception
   master bag and one sub-bag. No custom art.
3. Give the sub-bag a `ContainerContentFilterCondition`, and author both bags at
   zero weight.
4. Measure, in game:
   - Which Osiris event reports an item entering a container, and whether it
     distinguishes the Bagception root from a sub-bag.
   - How much vanilla auto-collect does unaided: potion, elixir, coating, modded
     weapon. This sizes the gap Osiris has to cover and validates the hybrid.
5. Record both answers in the handbook, then write the routing goal.

## Phase 2 — Weightless storage (dropped, then built)

> **Built natively in 1.0.0.5 (2026-09-23)**, after the measurements proved it
> possible. The text below is kept as the record of why it was first dropped.

Not achievable natively, and the requirement was dropped on 2026-09-20. The slot is
kept so the numbering still matches spec section 44.

One piece survives and belongs in Phase 1: author Bagception and every internal
container at zero weight, as vanilla does for the camp supply sack. The bags
themselves then cost nothing to carry.

A carrying-capacity approximation remains available if ever wanted, and is plain
native data rather than a dependency. See
[`research/native-capabilities.md`](research/native-capabilities.md).

## Phase 3 — Full classification

The remaining containers from spec section 6, flat at one level, each with the right
vanilla auto-collect tag. Osiris rules only for categories vanilla does not
distinguish, following the precedence in spec section 12.

## Phase 4 — Container protection

Removal, Send to Camp, party transfer, and vendor protection, plus the invariant in
spec sections 15 to 17. Osiris detects a departed container and restores it.

## Phase 5 — Story safety

Protected-item detection and denylist. Unknown items with story-like properties stay
at the root.

## Phase 6 — Persistence and recovery

Existing-save installation, one bag per save, save/load validation, Recover Bagception,
duplicate consolidation. Note the Osiris `INITSECTION` behaviour recorded in the
handbook before designing registration.

## Phase 7 — Compatibility

Vanilla autosort bags and common equipment and consumable mods. The Script Extender
reference mods are worth testing against as neighbours, but this mod must also work
with the extender absent entirely.

## Phase 8 — Polish

**Custom art for every container**, which the user has asked for. Plus names,
tooltips, manual Sort, Reorganize, and Prepare for Uninstall.

## Acceptance

Spec section 43 lists AC-01 through AC-24. AC-11, the weight test, is removed with
the weight goal. Track the remaining 23 as a checklist in `docs/tracking/progress.md`
once Phase 1 lands.
