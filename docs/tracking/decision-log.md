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

## 2026-09-20: Weightless storage dropped

The user dropped the weightless requirement to keep Bagception a standard Larian mod.

- **Bagception is an organizer, not a Bag of Holding.** Spec sections 2.3 and 31, the
  "weightless contents" scope line in 3.1, and acceptance criterion AC-11 are removed.
  23 acceptance criteria remain.
- **The bags themselves are still authored at zero weight**, as vanilla does for the
  camp supply sack. Contents weigh what they weigh.
- **The carrying-capacity approximation is deferred, not rejected.**
  `StatusInInventory` granting a `CarryCapacityMultiplier` boost is plain native data
  and would not have introduced a dependency, so it remains available if the user
  later wants it. It is not in 1.0.

This simplifies the project considerably. Phase 2 disappears, the product is easier to
describe, and nothing in the mod now competes with the engine's own accounting.

## 2026-09-20: Script Extender companion kept under consideration

Dropping weightlessness from the base mod does not close the door on it. The user
wants to keep open a **separate Script Extender package** that adds weightless storage,
shipped alongside the native mod rather than replacing it. Recorded in
[`../script-extender-edition.md`](../script-extender-edition.md).

- The base mod stays native-only and must never require, detect-or-fail on, or degrade
  without the companion. The no-Script-Extender rule in `AGENTS.md` is unchanged for
  work in this repository.
- Preferred shape is an add-on that depends on the base rather than a duplicated
  standalone edition, so there is one source of truth for templates and categories.
- Two constraints on 1.0 follow, both cheap now and expensive to retrofit: **container
  tags become a published contract** once released, and **container template UUIDs are
  never reissued**. A companion locates Bagception's containers through those.
- The companion would ship on Nexus, since mod.io does not carry Script Extender mods.
  That does not pull the base mod's release path away from mod.io.

Not scheduled, not scoped, no mod identity reserved.

## 2026-09-20: Correction — "weightlessness is impossible natively" was wrong

`docs/weightless.md`, supplied by the user, challenged the verdict recorded above.
Re-checking against extracted game data shows the verdict was wrong, though not for
the reason that document gives.

**What the document gets wrong.** `EXTRAPLANAR_STORAGE` is not a Larian mechanism.
Across every root template and tag in Shared, Gustav, GustavX and Patch8 the only
match for "extraplanar" is the **WARLOCK** tag, whose description mentions "an
extraplanar entity". There is no extraplanar tag and no template-level extraplanar
behaviour; the name belongs to Containers Extended. Nor is there any container weight
attribute: Shared's root templates carry 612 distinct attributes and not one concerns
weight, capacity, bulk or encumbrance. `MaxWeight` and `WeightLimit` exist in the data
as Anubis behaviour-script parameters on pressure plates.

**What the earlier research got wrong, which matters more.** `Weight()` is a real
boost function. Vanilla uses it once, `Weight(100)` on the `EnlargeWeightLarge`
passive. Weight is therefore reachable through the boost and status system, which is
plain native data. The original survey searched root-template attributes, `Object.txt`
keys and the Osiris API, and concluded from three consistent negatives that the
answer was settled. All three were the wrong places to look. Three confirmations of
the same blind spot are not three independent confirmations.

The supporting evidence should also have prompted doubt: **ContainersExtendedExtraplanar
is published on mod.io**, which cannot host Script Extender mods.

**What is still unknown**, and is being measured rather than assumed: whether
`Weight()` is absolute or additive, whether it applies to items at all, and how a
status would reach a container's contents. `StatusInInventory` points the wrong way,
statusing the holder rather than the contents.

Weightlessness stays out of 1.0. This entry does not reinstate it; it records that
the reason for dropping it was unsound, so the decision is the user's to make again
once the probe reports. Spec sections 2.3 and 31 and AC-11 remain removed for now.

## 2026-09-20: Weight is reachable natively, but only as per-item bookkeeping

Measured in game, not inferred.

- **`Weight()` reaches items.** Two 10 kg gems in the master bag; the bag read
  10.4 kg, which is 10 kg of gem plus four potions at 0.1. The mechanism is real and
  entirely native.
- **`Weight()` is additive, not absolute.** Gem A with `Weight(0)` read 10; gem B
  with `Weight(-10)` read 0. It is a delta applied to the item's own weight.
- **The status persists after the item leaves.** Gem B taken out of the bag still
  read 0. The probe applied the status with duration -1.0 and never removed it. That
  is a missing rule rather than a property of the boost, but it exposes the real
  shape of the problem.

**What this means for the design.** There is no container property that makes
contents weightless; the effect has to be a status applied to each item on the way in
and removed on the way out. Bagception would therefore own persistent state on items
it did not create, and every gap in that bookkeeping — a move the event model does
not report, a crash, an uninstall, a load order change — leaves a player's item
permanently altered. `docs/weightless.md` advised against exactly this design, and
recommended reproducing a native container mechanism instead. The measurements say
there is no such mechanism to reproduce.

Two things are still open and both are being measured before any decision:

1. **Does weight clamp at zero?** If a boost larger than the item's own weight lands
   on zero rather than going negative, one large negative zeroes anything, and the
   mod never needs to know what an item weighs — which matters because Osiris cannot
   read an item's weight. Testing `Weight(-1000)` against a 10 kg item.
2. **Does removal restore the weight?** `RemovedFrom` plus a two-argument
   `RemoveStatus` is now wired into the probe.

Weightlessness remains out of 1.0. Nothing here reinstates it.

## 2026-09-20: Native weightless storage is achievable

Measured in game. `Weight(-1000)` applied to a 10 kg gem read **0**, not -1000. Weight
**clamps at zero**. Removing both gems from the bag restored both to 10 kg.

Full result set:

| Question | Answer |
| --- | --- |
| Does `Weight()` reach items? | Yes |
| Absolute or additive? | Additive — a delta on the item's own weight |
| Does it clamp at zero? | **Yes** |
| Does removal restore the original weight? | **Yes**, cleanly, both gems back to 10 |

**Clamping is what makes this viable.** Additive alone was nearly useless, because
zeroing an arbitrary item would need its exact weight and Osiris cannot read item
weight. With a clamp, one boost large enough to exceed anything — `Weight(-100000)`
— zeroes any item whatever it weighs, and the mod never has to know. The earlier
"impossible natively" verdict is now wrong twice over: wrong about the mechanism
existing, and wrong about it being unusable.

So weightless Bagception is buildable with no Script Extender, using only a status
with a `Weight()` boost, `ApplyStatus` on ingress and `RemoveStatus` on egress.

**The cost is unchanged and is the real decision.** There is no container property
doing this. The mod holds persistent state on items it did not create, and the state
outlives the mod. Every gap in the bookkeeping leaves an item permanently altered:

- a move the event model does not report, or reports in an order that strips a status
  just applied — the master-bag-to-sub-bag case is explicitly untested;
- an uninstall, which leaves the status on every stored item with no rule left to
  remove it. Whether the boost stops applying once its stats entry is gone is
  untested and decides how bad this is;
- a crash or a load-order change mid-transfer.

CLAUDE.md forbids destroying or altering a player item to resolve a sorting problem.
Permanently zeroing the weight of someone's greatsword is a mild form of that.

**Not reinstated for 1.0 by this entry.** What changes is that it is now a genuine
choice with evidence under it, rather than a capability that does not exist. The
recommendation is still to ship 1.0 as an organizer, and to treat weightlessness as
a deliberate follow-up with an uninstall path designed first, not bolted on.

## 2026-09-20: A container's own weight cannot mask its contents

Tested at the user's suggestion, and it would have been the better design: give the
master bag `Weight -100000` so the total floors at zero, and no per-item state is
needed at all — nothing to apply, nothing to remove, nothing left behind on
uninstall.

It does not work. The empty bag read **0**, and two 10 kg gems took it to **20**.

So the clamp measured earlier is **per entity, not per container total**. An
entity's own weight floors at zero, and a container's contents sum on top of that
floor. A negative container weight buys nothing.

That leaves the per-item status as the only native route to weightlessness, with the
bookkeeping cost recorded in the previous entry. The cheap, safe version of this
idea does not exist.

Master bag weight is back to 0, as vanilla does for the camp supply sack.

## 2026-09-21: Phase 1 answered, from the Osiris runtime log

The Script Extender is installed on the development machine and writes a full Osiris
runtime log to `C:\src\RandomizedDisguiseSelf\logs`. Every probe run of 2026-09-20
was recorded there, including the messages nobody could read on screen. The answers
had already been captured; they just had not been looked at.

**Question 1 — `_InventoryHolder` is the destination container.** Answered.

```
ingress -> ITEM holder: BAGCEPTION_CONT_Master_44127d26-...; addType: Regular
ingress -> CHARACTER holder: Gnomes_Female_Forest_Player_be43c7a0-...; addType: Regular
```

A gem dragged into the master bag reported the bag; the same gem dragged back out
reported the character. The event reports whatever inventory actually received the
item. **The root-versus-sub-bag distinction is expressible**, so spec sections 26 and
27 are implementable as written. This was the question the whole design rested on.

**Question 2 — native auto-collect does not do the work.** Answered, negatively.

In the session where the Potion Case was nested inside the master bag, three healing
potions were dropped into the master bag and all three stayed there. No follow-up
event moved any of them into the case. A potion dragged *directly* into the case
landed there, so the case itself works; what does not happen is collection.

The probe cannot separate "does not fire while nested" from "does not fire on a
manual drag", because `ContainerAutoAddOnPickup` may only mean pickup from the world.
For Bagception the distinction does not matter: the player drags items into the
master bag, and nothing collects them.

**This is the expensive answer.** The native-first classifier assumed ten of
seventeen categories were free. They are not. Osiris has to route everything, and
Phase 3 grows accordingly.

**Question 2b — magic pockets see nested items.** Answered, positively.

`magic pockets DO see an item nested in the potion case`, in two independent runs. So
`MagicPocketsMoveToByTag(_Source, _Tags, _Amount, _DestinationInventory, ...)` is a
viable bulk primitive: one call moves every item with a given tag into a container,
rather than a rule firing per item. That partly offsets the loss above, for the ten
tag-expressible categories at least.

**`AddType` vocabulary.** Three values observed across the logs: `Regular`,
`Treasure`, `TradeTreasure`. **Every player-initiated move is `Regular`** — into a
bag, out of a bag, between inventories. `Treasure` and `TradeTreasure` come from loot
and vendor generation. There is no distinct value for an auto-collect move, which is
consistent with auto-collect never having fired.

Spec section 27 wanted to distinguish a deliberate placement from an incidental one.
`AddType` alone does not do that; `Regular` covers both. The holder identity from
question 1 is the usable signal instead.

### Caveat on the test environment

The Script Extender is loaded while testing. Bagception does not use it and must
never require it, but the probe results were not gathered in a clean vanilla process.
Nothing observed looks Extender-dependent — these are base-game Osiris events — but
anything surprising should be re-checked with the Extender disabled before it is
treated as settled.

## 2026-09-21: Carry capacity instead of weightless contents

Decided by the user after the measurements. Bagception grants
`CarryCapacityMultiplier(2.0)` to whoever carries it, through a `BAGCEPTION_CARRY`
status attached to the master bag's Object entry via `StatusInInventory`. This is
shipping content, not a probe.

**Why this and not true weightlessness.** Weightlessness is achievable natively;
that was measured, not assumed. What killed it was the repair problem rather than
the mechanism. It can only be a per-item status applied on ingress and removed on
egress, and Osiris offers no way to enumerate a container's contents, while
`GetInventoryOwner` returns only the top-level holder. There is therefore no way to
write a sweep that detects or repairs a missed removal, so correctness would rest
entirely on never missing an egress event — and a miss permanently alters an item
the mod does not own. That sits badly with the rule in `CLAUDE.md` against altering
a player's items to solve a sorting problem.

**Correction, 2026-09-22.** The premise of the paragraph above is wrong. Osiris
*can* enumerate a container's contents: `IterateInventory`,
`IterateInventoryByTag` and `IterateInventoryByTemplate` walk a holder and raise a
per-item event plus a completion event, and vanilla uses all three.
`GetDirectInventoryOwner` also returns the immediate holder, so the top-level-only
limitation attributed to `GetInventoryOwner` was never binding either. A repair
sweep for a per-item weight status is therefore writable, and the stated reason for
rejecting weightlessness does not hold.

This does not reverse the decision. `CarryCapacityMultiplier` is implemented,
tested and accepted, and it still carries no per-item state. But if weightlessness
is ever revisited, the blocker recorded here is not a real one, and the reason to
prefer the carry boost is that it owns no bookkeeping, not that the alternative was
impossible.


The carry boost has none of that exposure: no per-item state, nothing to clean up,
nothing stranded on uninstall. The engine owns the effect and the mod owns no
bookkeeping at all.

**What it is not.** It is a flat multiplier, not proportional to what is stored, so
a player who fills Bagception with several hundred kilograms will still become
encumbered. The felt outcome is close to the goal — carrying the bag lets you carry
more — but it is not the same mechanism, and the docs should not describe Bagception
as weightless.

**Precedent and tuning.** The pattern is vanilla's own: `OBJ_Tool_Shovel` grants
`HAS_SHOVEL` through `StatusInInventory`, and the same property flags are reused so
the status stays out of the combat log and off the portrait. The multiplier is the
one balance knob; 2.0 matches Enlarge, against 1.25 for Rage and 1.25-1.5 for the
Giant's carrying-capacity passive.

Weightlessness stays recorded as feasible, and remains the natural centrepiece of a
Script Extender companion, where inventories can be enumerated and the missing
repair sweep becomes writable.

## 2026-09-21: One Bagception per character

The user's decision: every character carries their own Bagception, the way vanilla
gives each character a camp supply pack, keyring and alchemy pouch, rather than a
single bag shared by the party.

Implemented on vanilla's own pattern, from Gustav's `_Gustav_Init`:

```
IF CharacterJoinedParty(_Character)
AND TemplateIsInInventory(BAGCEPTION_CONT_Master_..., _Character, 0)
THEN TemplateAddTo(BAGCEPTION_CONT_Master_..., _Character, 1, 0);
```

Vanilla adds `QRY_OnlyOnce` because the camp pack is one per party. Bagception is
one per character, so that guard is dropped and `TemplateIsInInventory(..., 0)` does
the work. That count check is the important part: it makes every grant rule
**idempotent and self-healing**, so they can fire as often as they like and a
character still ends up with exactly one bag. It replaces the earlier
`DB_Bagception_NeedsGrant` flag, which was consumed once and could never recover if
the grant was missed — a real weakness, since the grant was in fact missed twice.

Three triggers cover the cases: `CharacterJoinedParty` for recruits and hirelings,
and `SavegameLoaded` and `LevelGameplayStarted` joined against `DB_Players` for
everyone already present, which is what makes installing into an existing save work.
`DB_Players` binds once per party member, so those rules fire per character.

The internal containers are added by a separate rule reacting to the bag's own
arrival, because the bag's instance GUID does not exist until it has been added and
`TemplateAddedTo` carries it.

### Consequences, some of which need a decision later

- **The carry boost is now per character.** Each carrier gets their own
  `CarryCapacityMultiplier(2.0)`. That is consistent, and probably what is wanted,
  but it is a much larger total party benefit than one shared bag would have been.
  Worth revisiting when the multiplier is tuned.
- **Container count multiplies.** Seventeen internal containers per character
  across a party of four plus hirelings is a lot of container entities. No
  performance problem is known; none has been looked for either.
- **A departing companion leaves with their bag and everything in it.** Vanilla
  avoids this by giving the camp pack once, to the avatar. This is the first real
  design question the change raises, and spec section 15's container-protection
  invariant does not cover it: the bag is not leaving Bagception, the character is
  leaving the party. Unresolved.
- **The spec's "one bag" framing is now wrong** wherever it implies a single shared
  container. The mod is one bag per character, each self-contained.

**Verified in game, 2026-09-21.** A newly created character starts with a Bagception,
and Lae'zel had one on joining the party, so both the `DB_Players` sweep and
`CharacterJoinedParty` work. Not yet checked: the Potion Case nesting, duplicate
suppression across a reload, and the carry boost following the bag.

### Footnote on the mechanism

The user pointed out that vanilla gives these pouches per character, which is
correct, and it is done in `Equipment.txt`: 27 equipment sets — the 17
character-creation class sets plus the origin companions — each list
`OBJ_Camp_Pack`, `OBJ_Keychain`, `OBJ_Bag_AlchemyPouch` and
`OBJ_Backpack_CampSupplies`. Copying that literally was rejected: it would mean
overriding 27 vanilla files, would do nothing for an existing save, and would miss
modded hirelings entirely, including this author's own MoreHirelings. The Osiris
grant reaches all three cases and overrides nothing.

## 2026-09-21: Containers are sticky

Requested by the user: a Bagception cannot be dropped, handed to another character,
or sent to a chest. Implemented as `data "Flags" "InventoryBound;Unstorable"` on
both container stat entries — plain data, no Osiris, no status.

`InventoryBound` is a vanilla `AttributeFlags` value, applied in the base game
through the `GEN_INVENTORYBOUND` status and used by Flame Blade and Shillelagh to
stop a conjured weapon being dropped. `Unstorable` is in the same valuelist but has
no user anywhere in the shipped stats, so it is the unproven half of the pair.

**Verified in game, 2026-09-21.** All three hold: the bag cannot be dropped, cannot
be handed to another character, and cannot be sent to the camp chest. **`Unstorable`
works** despite having no vanilla user, so no Osiris guard is needed for the chest.

**Also confirmed: `ContainerContentFilterCondition` gates manual placement, not just
auto-collect.** A non-potion could not be dropped into the Potion Case by hand. That
is a larger finding than it looks — the filter is a real restriction on what a
container will accept, so the seventeen containers enforce their own categories
without any Osiris involvement. It does not help with sorting, which still has to be
driven by Osiris, but it does mean a misfiled item cannot be filed by hand either.

**Consequences worth noting.**

- The carry-capacity boost can no longer be moved between characters, which is how
  it was verified earlier. That test is no longer repeatable, and that is the point:
  each character keeps their own bag and their own boost.
- Applied to the Potion Case as well, this may deliver spec sections 15 to 17 — the
  container-protection invariant — as data rather than as the Osiris machinery
  Phase 4 assumed. An internal container bound to its inventory cannot be dragged
  out. To be confirmed in game; if it holds, Phase 4 shrinks to almost nothing.
- It also removes the drop-and-reload bag duplication raised against the
  self-healing grant. A bag that cannot be dropped cannot be farmed, so the
  self-healing behaviour keeps its upside and loses its main downside.

## 2026-09-22: Per-item routing, and the sorter's first category

The sorter routes on `TemplateAddedTo` one item at a time, rather than sweeping in bulk
with `MagicPocketsMoveToByTag`. Verified working in a fresh game: potions dropped into
the master bag file themselves into the Potion Case, on more than one party member.

**Why not bulk.** `MagicPocketsMoveToByTag` matches only tags, so it cannot reach the
six categories that have no vanilla tag — per-item logic is required regardless, and
bulk would be a second mechanism to maintain rather than a replacement. Its `_Source`
is the party inventory pool, so sweeping by tag would pull items out of a character's
own inventory and into Bagception, which is sorting outside our hierarchy. And it takes
an `_Amount`, which we would have to know in advance.

**The holder test is a tag check.** The master bag's root template carries
`BAGCEPTION_MASTER`, so `IsTagged` answers "is this a Bagception" directly. An earlier
version kept a `DB_Bagception_Master` registry with a repair rule on `SavegameLoaded`;
it was replaced because it was unnecessary, not because it failed — it was never
actually running (see below). The tag check needs no bookkeeping, no repair path, and
works the moment the mod loads.

The tag is also the containment guarantee: routing requires the holder to **be** a
master bag, never merely to contain one, so a character's own inventory is never swept.

**What this cost to find.** Four test rounds reported the sorter not working, and the
first three diagnoses were wrong, because two independent silent failures were stacked:

1. The goal file was written with CRLF line endings while every other goal uses LF. The
   compiler failed the header parse and dropped the goal from the build, reporting zero
   errors. The file still shipped inside the pak.
2. Every test ran against an existing save, and BG3 restores the story from the
   savegame's own `StorySave.bin` rather than from the mod.

Either one alone produces "the rule does not fire, and nothing says why". Both were
mine to avoid: the first by matching the existing convention, the second by testing in
a fresh game from the start. Both are now in `docs/developer-handbook.md`, along with
the Script Extender node count, which is the only signal that reports the second.

Discarded along the way, and recorded so they are not re-derived: that node sharing
between rules with identical condition prefixes was suppressing the rule, and that
`GetItemByTemplateInInventory` was broken at runtime. Neither was true. The rule
containing it had simply never been loaded.

**Correction.** The paragraph this replaces claimed the sorter was verified on
potions. It was not. The pak under test contained no routing rule and no sorter goal
at all — the Story Editor had silently declined to compile an unregistered goal — and
the potions were filed by **native auto-collect**: the Potion Case carries
`ContainerAutoAddOnPickup` with `Tagged('ALCH_SOLUTION_POTION')`, and the engine did
the work. All four negative cases are equally explained by the native filter. The
lesson is that a passing test proves nothing unless the mechanism under test is
confirmed present in the build.

I attributed the potion routing to native auto-collect, and wrote that this overturned
the Phase 1 finding. That was wrong too, and the correction is recorded below rather
than edited away, because the mistake was reasoning from a single observation to a
mechanism without testing the mechanism.

**Verified in game, fresh game.** Shields dropped into the master bag file themselves
into the Shield Rack, and an off-hand dagger does not, so `IsWeapon` separates shields
from off-hand weapons as intended. This is the first confirmed Osiris routing, and it
is unambiguous: the Shield Rack has no `ContainerContentFilterCondition` and no
auto-collect, because "shield" cannot be written as a tag expression. Nothing but the
rule could have moved it.

That result carries the riskiest classification in the spec. The same shape now covers
weapons, armour and jewelry, which are simpler — a direct `IsWeapon` and slot tests.

Both containers arrive in the bag together, after a treasure-table fix: a subtable
picks from its entries, so two object lines under one `new subtable "1,1"` dropped one
of the two at random. Each guaranteed container needs its own subtable.

**Still unverified.** Whether a brand-new goal merges into a save that has never seen
it. Everything so far was tested in a fresh game, which sidesteps the question.

## 2026-09-22: Native auto-collect does not reach a nested container

Settled by building the Scroll Case with a `ContainerContentFilterCondition` and
deliberately **no** Osiris rule. Scrolls dropped into the master bag stayed loose. The
filter itself works — placing a gem into the Scroll Case by hand is refused — so the
container is configured correctly and simply never collects on its own.

This re-confirms the original Phase 1 measurement and retracts the correction above.
**Every category needs an Osiris routing rule.** The ten tag-expressible categories are
not data-only; they are the same rule shape as potions, with a different tag.

`ContainerContentFilterCondition` still earns its place on every tag-expressible
container, because it gates manual placement. The player cannot file a gem in the
Scroll Case by hand. Categories with no tag expression — shields, weapons, armour,
jewelry, dyes, valuables — cannot have one, so manual placement there is unrestricted.

**What moved the potions is still not established.** Native auto-collect is now ruled
out, since the identical configuration fails for scrolls. The leading explanation is
that BG3 loads the Toolkit's loose files under `Data/Mods/<module>/` alongside the
deployed pak, and the loose story at that moment contained the rule even though the pak
did not. That is a hypothesis, not a measurement, and it matters for testing: verifying
a pak's contents does not prove what the game will run. Until it is settled, confirm a
change is present in **both** the pak and the loose story before trusting a test.

## 2026-09-22: Sort only what enters Bagception; widen throwables; route extracts

Three results from the eleven-container test.

**A picked-up book went straight into the Book Satchel.** `ContainerAutoAddOnPickup` does
collect into a nested container on a world pickup, though not on a drag. That bypasses
the master bag, which is wrong for most categories: Bagception should sort what the
player puts into it. The attribute is therefore a per-container choice rather than a
default. It is `True` on the Reagent Pouch and the Larder Pack, at the user's request —
ingredients, extracts and camp supplies are collected on pickup, as vanilla's own
Alchemy Pouch and Camp Supply Sack do — and `False` on every other container. The filter
is kept everywhere for manual placement.

The same test showed no such collection for categories that have a vanilla auto-collect
bag. Whether that is because the vanilla bag claims the item first, or because those
items simply were not picked up from the world during the test, is not established.

This is also the likely answer to what moved potions in the rule-less build: potions have
no vanilla auto-collect bag, so a potion picked up from the world would have gone
straight into the Potion Case. Likely, not confirmed — it depends on how those potions
were obtained, which was not recorded.

**Void bulbs did not reach the Grenade Satchel.** They carry `GRENADE`, not
`ALCH_SOLUTION_GRENADE`. `GRENADE` is the broad throwable tag (71 templates, including
caltrops and flasks); the alchemy tag covers eleven, all but one of which carry `GRENADE`
too. The Grenade Satchel now takes either, with the second rule excluding `GRENADE` so no
item matches twice.

**Extracts land in the character's inventory, not the Reagent Pouch.** The earlier
statement that extracts need no handling was wrong on two counts: extraction deposits
into the character, and `ALCH_EXTRACT` does exist — in `SharedDev`, which the tag search
had not covered. Extracts now route to the Reagent Pouch when dragged into Bagception,
matching vanilla's Alchemy Pouch. Extraction itself is not intercepted by Osiris: the
character's inventory is outside Bagception's hierarchy. Whether the Reagent Pouch's
pickup collection also catches a freshly extracted item is untested.

The camp-supply container is renamed from Larder Sack to Larder Pack (display name only;
the template name and UUID are unchanged).

## 2026-09-22: Books the BOOK tag misses are listed by template

The user noticed the Rune Slate and the Eldritch Tablet staying at the top level. Neither
is a book to the game: all six `LOOT_MF_Rune_Tablet_*` templates are untagged generic loot
(`OBJ_GenericLootItem`) with no `BookId`, so they cannot be read. The Eldritch Tablet is a
placed instance of `LOOT_MF_Rune_Tablet_E` in `TUT_Avernus_C` with its own display name.
They go in the Book Satchel because that is where a player looks for them.

Checking for them turned up a real gap: eighteen readable templates (`BookId` set) without
`BOOK` — the three MOO maps, the Gortash poster, the Highberry and Stormshore Tabernacle
books, the Nightsong pamphlet and a parchment. Placed level items add no further templates.

Both groups are asserted as `DB_Bagception_BookTemplate` facts in `INITSECTION` and
matched against `TemplateAddedTo`'s template by a second Book Satchel rule. None carries
`BOOK` or `SCROLL`, so the tag rules and this one stay disjoint.

Two consequences:

- The Book Satchel's filter is tag-only, so these items cannot be dragged **directly**
  into it by hand. Dragging them into Bagception works through the rule. Whether the
  filter also refuses a scripted `ToInventory` is untested; if it does, the item stays at
  Bagception's top level, which is safe.
- `INITSECTION` facts reach only games that start with this story. Fresh-game testing
  covers it; how an existing save picks up new facts is the open question on goal changes
  already recorded above.

## 2026-09-22: Weapons, Armour, Jewelry, Tools and Dyes

Five containers built in one pass: Weapon Roll, Armour Trunk, Jewel Box, Tool Roll and
Dye Pouch. All set `ContainerAutoAddOnPickup` False, so they sort only what the player
puts into Bagception. Only the Dye Pouch has a filter; the other four categories are not
tag-expressible.

- **Weapons:** `IsWeapon` 1, excluding `TORCH`. Shields answer 0, so the Shield Rack rule
  and this one are disjoint.
- **Armour & Clothing:** `IsEquipable` and a slot in `DB_Bagception_ArmourSlot`, which
  includes the camp-clothing slots VanityBody and VanityBoots.
- **Jewelry:** the same shape, slots Ring, Ring2 and Amulet. No other accessory slot
  holds items in vanilla.
- **Tools:** three disjoint rules. The stats names under vanilla's own `_Tool` base (26
  entries: kits, digging and crafting tools, non-equipable instruments), matched through
  `GetStatString`; anything tagged `TORCH`; and equipable instruments, which have the
  MusicalInstrument slot and are armour in the stats. Bards' instruments went here
  rather than to the Armour Trunk because the spec's Tools section is the one about
  reusable adventuring equipment, and a lute is not clothing.
- **Dyes:** `DYE`. The handbook said no template carried it; `BASE_LOOT_Dye` does, and
  every dye inherits it. The earlier search did not follow the parent chain.

Checked against the built categories: no `Weapon.txt` or `Armor.txt` template carries
any earlier category's tag except `TORCH`, and no `_Tool` or dye template does either.

Known and left for Phase 5 (story safety): the Moonlanterns are `TORCH`-tagged weapons,
so they now go to the Tool Roll, and a few named uniques (Gale's flute, Oskar's torches)
sort like their kind. Nothing in the sorter guards story items yet.

## 2026-09-23: Equipment sorts at any rarity; Jewelry Box

After play, the user asked whether the Weapon Roll, Armour Trunk and Jewel Box could
take only Uncommon and better, since common gear is mostly junk. Osiris has no rarity
query and no tag carries rarity, so it was built as a generated list of 537 common
vanilla stats entries to skip. The user then withdrew it: a hard-coded item list is the
wrong shape for a mod meant to sit alongside equipment mods, and filing is already
opt-in, since nothing sorts until the player puts it into Bagception. Rarity stays out
of classification, as spec §6.1 says.

The Jewel Box is renamed **Jewelry Box** in game, so nobody expects gems in it. The
template and stats keep the `JewelBox` identifier.

## 2026-09-23: One catch-all, no Valuables container

Spec §6.17 wants a Valuables container for items whose purpose is sale, and §6.20 a
Miscellaneous one for the rest. Nothing in the game marks a trade good: there is no tag,
`BASE_LOOT_Valuable` is a parent template that also holds dyes and story items, and
`ObjectCategory` is inconsistent. The choices were a gold threshold (mod-friendly but
fuzzy), a generated list of vanilla trade goods (precise but blind to mods), or no
Valuables at all. The user chose none: everything unclaimed goes to one **Odds Sack**.

The catch-all runs on a one-second realtime timer started when an item arrives in the
master bag. When it fires, an item still lying directly in the master bag is one no
category took, and it moves to the Odds Sack. This keeps the catch-all independent of
the category rules: no rule order is assumed, and no list of other categories exists to
keep in step. The cost is a visible second's delay before misc items file.

Left at the top level, per spec: any container (§6.19), story items (§7; the first
story check in the sorter), and gold (§6.18).

## 2026-09-23: Explosives go to the Grenade Satchel

The Smokepowder Satchel and the Runepowder Vial carry `EXPLOSIVES`
(`f6e89388-…`, "all the smokepowder, runepowder and other explosive items") but not
`GRENADE`, so they fell through to the Odds Sack. A third Grenade Satchel rule takes
`EXPLOSIVES`, excluding both grenade tags so it stays disjoint from the other two, and
the filter gains `Tagged('EXPLOSIVES')`.

The tag also marks the smokepowder and runepowder barrels and the firework boxes, all
under `BASE_CONT`. The user asked for them in the satchel unless they count as
containers, which spec §6.19 keeps at the top level. The rule asks `IsContainer` at
runtime, so the barrels file only if the engine says they are not containers. Which way
it answers is not yet observed. The filter cannot express that test, so a barrel dragged
into the satchel by hand is accepted either way. The user accepted that: a player who drags a
barrel in by hand has chosen to.

## 2026-09-23: Updates must reach saves in progress

The user questioned why every test needed a new game, since a bug-fix release that only
reached new games would be no release at all. Two parts of the design did not update in
an existing save, and fresh-game testing had been hiding them:

- **Internal containers.** The treasure table fills a bag once, when it is created. A
  player updating from an earlier version would never have received the five equipment
  bags or the Odds Sack.
- **Lookup data in `INITSECTION`.** The book, slot and tool lists were asserted once per
  save, so a later version could never add to them.

Fixes: every lookup list moved to `PROC_Bagception_LoadData`, which clears and reloads
on `SavegameLoaded` and `LevelGameplayStarted`. Clearing first makes the reload exact,
so a dropped entry is dropped from saves too, and it removes the copies earlier
versions put there. A new `DB_Bagception_InternalContainer` lists every container, and
`PROC_Bagception_RepairBag` adds any a bag lacks, on `SavegameLoaded` and
`CharacterJoinedParty`. Neither trigger can observe a bag between its creation and the
arrival of its treasure-table contents, which is the window that would duplicate them.

Expected cost: a container added to an existing bag may not be drawn until the next
reload, the same stale-display issue seen with runtime-created containers before.

## 2026-09-23: A version bump is what carries an update into a save

Tested on one Act 2 save made with an earlier build. Loaded with a newer pak at the same
`Version64`, the game kept the story stored in the save: none of the new rules ran. The
save records each mod's `Version64` and the pak's MD5, so a changed pak alone is not the
trigger. Loaded again after bumping Bagception to 1.0.0.1 and changing nothing else, the
game merged the mod's story into the save, the data reload and bag repair ran, and the
explosives rule filed the Smokepowder Satchel and Runepowder Vial.

Consequence: every release that changes the story bumps `Version64`, which the release
workflow already does, and the reload-and-repair work of the same day is what makes a
merged update complete. The development build was at 1.0.0.1, unpublished; it went
to 1.0.0.2 the same day to carry the Coin Purse into the same save, and to 1.0.0.3
for the Quest Satchel.

## 2026-09-23: A Coin Purse for gold

Requested by the user. Spec §6.18 left gold to the game's own handling unless there was
a reason for a purse, and allowed one as an optional addition later; the request is the
reason. The purse follows the rule every other bag does: it files only gold the player
puts into Bagception, and never gathers gold from the character's own inventory or from
pickup.

Every gold stack in the game is `LOOT_Gold_A` or a child of it, and that template alone
carries `LOOT_GOLD` (`6c6b7cac-…`), so one tag identifies gold for both the sorter rule
and the hand-placement filter. The Odds Sack keeps its gold exclusions, so in a bag
missing its purse gold stays loose instead of going to the catch-all.

Unverified: whether gold inside a container still counts towards the party's gold when
trading. If it does not, filing gold into the purse would hide it from traders, and the
purse would need rethinking. That is the first thing to test.

## 2026-09-23: Keys and gold are collected on pickup

At the user's request the Key Ring and the Coin Purse now set `ContainerAutoAddOnPickup`,
joining the Reagent Pouch and the Larder Pack. A key or gold picked up in the world
goes straight into its bag rather than waiting to be dragged onto Bagception. Keys match
vanilla's own Keychain, which collects the same way. Gold already in the character's
own inventory is still never gathered.

Data only: the templates change, the story does not. Open questions: whether a vanilla
Keychain the character carries takes a key before the Key Ring does, and which other
ways gold arrives (a trader's change, a quest reward, looting a body) count as a pickup.

## 2026-09-23: Bagception's item count includes its bags, and stays that way

The user asked whether the inner bags could be left out of the item count the game
shows on Bagception, so an empty Bagception would read 0 rather than 18. They cannot,
natively. The count is drawn by the inventory UI from the items directly in the
container. Checked for anything that would hide an item from it: the full
`AttributeFlags` valuelist (25 values, none about visibility or counting) and every
boolean root template attribute vanilla sets on items. The one plausible name,
`Unimportant`, is used only on world decoration such as mirrors, crates and posters.
Osiris has no call that reaches the display.

The only route would be overriding the game's inventory UI. That would change the count
for every container in the game, would break with UI patches or other UI mods, and
reaches outside Bagception's own hierarchy, so it was ruled out. The count is recorded
as a known limitation in `docs/containers.md`.

## 2026-09-23: A Quest Satchel for story items, ahead of every category

Spec §7 kept story items loose at Bagception's top level, and until now only the Odds
Sack honoured that; a story item matching a category, such as the Moonlantern, was
filed. At the user's request story items instead get a bag of their own, the Quest
Satchel, checked ahead of every category. The sorter asks `IsStoryItem`: a Quest
Satchel rule takes story items, and every other category rule carries `IsStoryItem 0`,
so no rule order matters.

Keys are the exception, chosen by the user. Every vanilla key is a story item, all 36
templates tagged `KEY` inheriting `StoryItem` from `BASE_KEY`, so story-first without an
exception would have emptied the Key Ring. Containers stay loose even when marked as
story, as every container does (§6.19).

Limits: the filter language cannot test for story items, so the satchel accepts
anything placed by hand, cannot collect on pickup, and cannot stop the Reagent Pouch,
Larder Pack or Coin Purse collecting a story item on pickup. Unverified: whether quest
and dialogue checks find an item two bags deep. Uninstall was also raised: removing the
mod may take the bags and their contents, story items included. The user's position is
that the game already warns that removing a mod can destabilise a playthrough, so that
is on the player.

## 2026-09-23: Container protection is native

Tested by the user: Bagception cannot be dropped, and none of its inner bags can be
taken out of it. Both carry `InventoryBound;Unstorable` in their stats, and
`InventoryBound` is the vanilla mechanism that pins conjured weapons to their owner.
Phase 4's planned Osiris detect-and-restore rule is therefore not needed, which also
avoids fighting the player. Every route has since been tested and is blocked: send to
camp, giving to another character, a chest or other container, and trading (where
Bagception is hidden entirely; see the entry below).

## 2026-09-23: Items are sold by taking them out of Bagception first

The user found Bagception absent from the trade window, so nothing in it can be sold
directly, and asked whether that could change. A test build removed `Unstorable`
from all twenty bags and kept `InventoryBound`; Bagception stayed hidden. The flag
hiding it is therefore `InventoryBound`, the same one that makes Bagception
impossible to drop, send to camp or give away.

The only way to make it tradeable would be to drop `InventoryBound` and replace it
with an Osiris rule that returns Bagception whenever it leaves a character. That is
real work, it weakens a protection that currently cannot fail, and a rule that pulls
items back can fight the player. The test was reverted, both flags stay, and the
workaround is documented: drag an item out of Bagception into the character's own
inventory, then sell it.
