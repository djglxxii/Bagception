# Decision log

## 2026-09-20: Native only, Toolkit, mod.io

The defining constraint, set by the user:

- **Bagception uses Larian's native mod system and Osiris scripting only.** No Script
  Extender, no third-party mod dependencies, no Nexus release workflow. Release is
  through the official Toolkit to mod.io and the in-game mod manager.
- `C:\src\MoreHirelings` is the template for repository shape, tooling, and workflow.
  It is the same kind of project and its `AGENTS.md` already carries this rule.
- `spec.md` was drafted assuming the Script Extender and is superseded where it
  depends on that. Its preamble records exactly which sections. The spec is a draft
  input, not an authority that outranks the user's instruction.
- MCM configuration is ruled out as a consequence, not as a preference: MCM is itself
  a Script Extender framework.

### Correction

The first scaffold, commit `8fc6b30`, was built Script-Extender-first and
Nexus-targeted because `spec.md` names the Script Extender as its primary runtime
dependency. That was wrong: the user had named MoreHirelings as the template, and
MoreHirelings' `AGENTS.md` explicitly forbids all three of Script Extender,
third-party dependencies, and a Nexus workflow. The conflict between the two inputs
should have been raised as a question before any file was written. It was instead
resolved unilaterally and recorded as settled. This rework reverses it.

## 2026-09-20: Architecture

- **Classification is native-first.** BG3's auto-collect containers do the bulk of the
  sorting via vanilla tags; Osiris covers only what they cannot. This was chosen as a
  hybrid while the Script Extender was still in scope, and survives the constraint
  because its native half is the part being kept. `mod-references.md` argues, from
  Simple Sorting Bags, that vanilla tags handle a surprising amount including modded
  items.
- **Flat hierarchy.** All containers sit directly in Bagception, one level deep. The
  spec offers this as a permitted 1.0 shape, it minimizes clicks, and it gives vanilla
  auto-collect the best chance of working.
- **Vanilla-inherited root templates.** New templates get their own UUIDs, names, and
  tags, and inherit vanilla container behaviour, icons, and visuals. Only two bags are
  authored for the probe, a master and one sub-bag, rather than all 17.
- **Custom art for every container is wanted** and is deferred to Phase 8 polish, not
  dropped.
- **The ingress event is settled empirically.** Phase 1 begins with a probe build that
  logs what actually fires when the user drags items into the root, into a sub-bag,
  and back out. The same build measures how much vanilla auto-collect does unaided.
- **Weightless storage is unresolved and may not survive.** Both strategies in spec
  section 31 were Script Extender techniques. Research native options first, then
  choose between a native mechanism, an approximation via a carrying-capacity boost,
  and dropping the goal. AC-11 depends on it.

## 2026-09-20: Repository setup

- Mirror the five Toolkit-owned paths under `src/`, as MoreHirelings does.
- Provisional module UUID `f2470481-03f2-4439-83d5-68f2e26ae076` and project UUID
  `a1b4cb49-e5c2-44a0-92bd-5d90378e7723`, at version 1.0.0.0. Both must be reconciled
  with the Toolkit-generated identity when the project is created.
- Keep an offline Divine packager for quick iteration, in the role MoreHirelings gives
  `Build-Prototype.ps1`. The Toolkit remains the release path.
- Compile localization to `.loca` during packaging rather than committing a compiled
  artifact.
- Keep `spec.md` and `mod-references.md` at the repository root, as the sibling
  projects keep their design documents.

## 2026-09-20: Native capability survey

Findings recorded in [`../research/native-capabilities.md`](../research/native-capabilities.md).

- **True weightlessness is not achievable natively.** No root-template attribute, no
  `Object.txt` field, no Osiris function. Spec section 31 is dead, and the user's
  "make things weigh very little" alternative does not substitute: weight belongs to
  each item's own stats entry, so it can only be set on items this mod defines, never
  on the arbitrary loot a player stores.
- **Bagception's own containers should still be authored at zero weight**, as vanilla
  does for the camp supply sack. Free, and worth doing regardless of the decision above.
- **The native auto-collect mechanism is confirmed and richer than expected.**
  `ContainerAutoAddOnPickup` plus `ContainerContentFilterCondition`, a boolean
  expression language over `Tagged('X')` and `IsSupply()`. Ten of the seventeen
  categories are expressible as pure data, including the potion/elixir split that was
  assumed to need code. Weapons, armour, shields, jewelry, dyes, and valuables have no
  vanilla tag and will need Osiris.
- **The Osiris inventory surface is sufficient** for the sorting pipeline:
  `TemplateAddedTo` for ingress, `MoveItemTo` for routing,
  `GetItemByTagInInventory` for locating internal containers by tag rather than by
  tracked UUID, and `MoveAllItemsTo` for uninstall and duplicate consolidation.

Still to decide: whether to ship the carrying-capacity approximation or drop the
weight goal. See open questions.
