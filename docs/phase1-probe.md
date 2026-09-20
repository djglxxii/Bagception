# Phase 1 probe: procedure

The files are prepared. This is what to do with them, and what each outcome means.

The probe sorts nothing and moves nothing. It exists to answer two questions from
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

## What to do in game

Watch the on-screen notifications. Drag, in this order:

1. A potion into the **master bag**.
2. A potion directly into the **Potion Case**.
3. A potion **out** of the Potion Case.
4. Any non-potion, a longsword say, into the **master bag**.

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

**Vocabulary.** Note the `addType:` value printed in each notification. Those strings
are the undocumented `AddType` enum; record them in the handbook. The difference
between a player drag, an auto-collect, and a pickup is likely visible there, and the
real sorter will need to filter on it to satisfy spec section 27.

Step 3 confirms that taking an item out does not trigger a re-add loop. Step 4 shows
what happens to an item no filter claims; it should simply stay at the root.

## After

Record every answer in `docs/developer-handbook.md`, update open questions, then
delete this goal. It must not ship.
