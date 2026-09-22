# Phase 1 probe: procedure

The files are prepared. This is what to do with them, and what each outcome means.

The probe sorts nothing and moves nothing. It exists to answer four questions from
[`tracking/open-questions.md`](tracking/open-questions.md) that the whole design rests
on, and to learn the `AddType` vocabulary, which is not documented anywhere in
`story_header.div`.

## What is prepared

| File | Purpose |
| --- | --- |
| `src/Public/Bagception/RootTemplates/Bagception.lsx` | Master bag `856bd140-…` and Potion Case `8bf1ed2d-…`, both inheriting `CONT_Bag_A` |
| `src/Public/Bagception/Tags/*.lsx` | `BAGCEPTION_MASTER` and `BAGCEPTION_INTERNAL` |
| `src/Public/Bagception/Stats/Generated/Data/Object.txt` | Both containers at `Weight 0` |
| `src/Localization/English/Bagception.xml` | Four strings, handles already wired into the templates |
| `src/Mods/Bagception/Story/RawFiles/Goals/Bagception_Probe.txt` | The diagnostic goal |

The Potion Case carries `ContainerContentFilterCondition` =
`Tagged('ALCH_SOLUTION_POTION')`, the native auto-collect filter.

## Steps

1. Create the `Bagception` project in the official Toolkit.
2. **Reconcile identity.** The Toolkit generates its own module UUID. Either adopt it
   into `src/Mods/Bagception/meta.lsx` and `src/Projects/Bagception/meta.lsx`, or set
   the Toolkit's to the provisional values. Do this before any save exists. Record
   which way it went in the handbook.
3. `.\tools\Sync-ToolkitProject.ps1 -Direction ToGame -WhatIf`, review, then run it
   for real to place these files in the Toolkit workspace.
4. Build the story in the Toolkit Story Editor so `Bagception_Probe` compiles.
5. `.\tools\Sync-ToolkitProject.ps1 -Direction FromGame` to capture the compiled
   `story.div.osi` and any Toolkit-generated files.
6. Publish Local to build a test `.pak`, or use `.\tools\Build-Pak.ps1` **only if**
   the compiled story came back in step 5. A data-only package has no story and the
   probe will appear to do nothing.
7. In game, spawn or grant the two containers, put the Potion Case inside the master
   bag, and put the master bag in a character's inventory.

## Getting the bags

The goal grants both containers to the host character the first time it initializes:
once on `LevelGameplayStarted`, with `SavegameLoaded` as a fallback for a save loaded
without a level transition, guarded by a `DB_Bagception_NeedsGrant` marker that is
retracted on the first grant so it cannot fire twice.

Two 10 kg **probe weights** come with them, a diamond and a ruby, for the weight
test below.

They arrive **loose in your inventory, not nested**. That is deliberate — dragging the
Potion Case into the master bag by hand is part of what the probe measures. Do that
first, before the drag sequence below.

The grant announces itself first: **"grant rule fired; 4 items requested"**. That
notification is the fork in the road.

- No notification and no items: the goal never ran. Check the Story Editor error
  list, and that the mod is enabled.
- Notification but no items: the rule ran and the templates it named do not exist.
  The usual cause is resources shipped as `.lsx` only — the game reads `.lsf`, and
  fails silently when it is absent. This is what went wrong on the first build; see
  the handbook. Confirm with `divine -a list-package` that `Public/` contains `.lsf`.

(The notification needs one Story Editor rebuild after the fix; a package built
before that grants the items without announcing it.)

## Reading the result: marker items

Every diagnostic drops a **named marker item** into the player's inventory as well as
showing a message. The messages carry the `addType` string and nothing else can, but
they are gone the moment they are dismissed; two runs produced answers that could not
be read afterwards. The markers are still there when the drag is over, and each one
states its result in its own name:

| Marker in inventory | Means |
| --- | --- |
| `PROBE RESULT: holder is the CHARACTER` | `_InventoryHolder` is the owning character |
| `PROBE RESULT: holder is the CONTAINER` | `_InventoryHolder` is the container — question 1 answered the good way |
| `PROBE RESULT: ROOT ingress fired` | the tag test matched the master bag |
| `PROBE RESULT: SUB-BAG ingress fired` | something landed in the potion case |

They weigh nothing, so they never disturb a weight reading. Check the inventory after
the drags rather than trying to read anything mid-drag.

**If no marker appears at all**, the rule did not fire, and that is itself the
answer: for question 1 it means neither `IsCharacter` nor `IsItem` matched the
holder, which would be a genuinely surprising result worth stopping on.

## What to do in game

Watch the on-screen notifications. Drag, in this order:

0. The **Potion Case** into the **master bag**, so the nesting exists at all.
1. A potion into the **master bag**.
2. A potion directly into the **Potion Case**.
3. A potion **out** of the Potion Case.
4. Any non-potion, a longsword say, into the **master bag**.
5. **Note your carried weight.** Then drag **Probe Weight A** into the master bag,
   note it again, drag **Probe Weight B** in, and note it a third time.

## Reading the result

**Question 1 — what is `_InventoryHolder`?**

- `ingress -> ITEM holder` plus `ROOT ingress` on step 1 means the holder is the
  container. The root-versus-sub-bag rule in spec sections 26 and 27 is directly
  expressible, and the sorter can be written as designed.
- `ingress -> CHARACTER holder` only means the event reports the owning character, not
  the container. The distinction is not expressible from this event alone, and Phase 1
  needs a different approach before any sorting is written. Stop and re-plan.

**Question 2 — does nested auto-collect work?**

- `SUB-BAG ingress` firing on step 1, without step 2 having happened, means the Potion
  Case auto-collected the potion while nested. Native auto-collect works nested, the
  ten data-expressible categories are genuinely free, and the native-first classifier
  holds.
- Only `ROOT ingress`, with the potion sitting in the master bag, means auto-collect
  does not fire nested, or does not fire on manual drag. Osiris has to route
  everything, Phase 3 grows considerably, and the hybrid decision needs revisiting.

**Question 2b — do magic pockets see into a nested container?**

Free to ask in the same session, and it decides how the sorter is written rather than
whether it can be. `MagicPocketsMoveToByTag` is a bulk "move everything tagged X into
container Y" call, which would replace a rule-per-item sorter for the ten
tag-expressible categories — but only if the party pool sees items that sit inside a
bag.

- `magic pockets DO see an item nested in the potion case` means the bulk call is
  worth trying in Phase 3.
- `do NOT see` means route items individually with `ToInventory` or `MoveItemTo`,
  as originally planned. No loss either way.

Note that these two rules fire only when something lands in the Potion Case, so they
depend on step 1 or step 2 producing a `SUB-BAG ingress` in the first place.

### First run, 2026-09-20

Both gems went into the master bag. The bag read **10.4 kg**: 10 kg of gem plus four
potions at 0.1 each. Ten of the twenty kilograms of gem are gone, so **`Weight()`
does reach items** — the mechanism is real and native.

Hovering each gem settled which: **A read 10, B read 0.** Both statuses applied,
`Weight(0)` did nothing and `Weight(-10)` took ten kilograms off. **`Weight()` is
additive** — a delta, not an assignment.

### Second run, 2026-09-20: weight answered

Both gems read 10 loose, **0** inside Bagception, and **10 again** once taken out.

- Gem A carried `Weight(-1000)` against 10 kg and read 0, not -1000: **weight clamps
  at zero.** One boost bigger than anything in the game zeroes any item.
- Gem B, the `Weight(-10)` control, behaved as before.
- Both restored on egress, so `RemoveStatus` undoes it cleanly.

Native weightless storage is achievable. See the decision log for what it costs and
why it is still not in 1.0.

**Vocabulary.** Note the `addType:` value printed in each notification. Those strings
are the undocumented `AddType` enum; record them in the handbook. The difference
between a player drag, an auto-collect, and a pickup is likely visible there, and the
real sorter will need to filter on it to satisfy spec section 27.

Step 3 confirms that taking an item out does not trigger a re-add loop. Step 4 shows
what happens to an item no filter claims; it should simply stay at the root.

## After

Record every answer in `docs/developer-handbook.md`, update open questions, then
delete this goal. It must not ship.
