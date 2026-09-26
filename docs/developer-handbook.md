# Developer Handbook

Durable project knowledge, recurring pitfalls, and resolved issues. Update this
whenever a session learns something that would otherwise have to be rediscovered.

## Maintenance rules

- Read this handbook before starting a new implementation phase.
- Add a short entry whenever a tool behaves unexpectedly, a command needs a
  non-obvious flag, a local path is confirmed, or a BG3 data relationship is mapped.
- Keep generated output and third-party binaries out of this file. Record the path,
  the command, and the conclusion instead.
- If a lesson changes the plan, also update `docs/tracking/`.

## Project direction

Bagception is built with Larian's official Toolkit and Osiris, published to mod.io.
**No Script Extender, no third-party mod dependencies, no Nexus workflow.** The
`spec.md` draft assumed the Script Extender throughout; its preamble records which
sections that invalidates. `C:\src\MoreHirelings` is the precedent project for
repository shape, tooling, and workflow.

## Local paths and tools

Verified on 2026-09-20 on this machine:

- BG3 game directory: `C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3`
- BG3 mods directory: `C:\Users\djgLXXII\AppData\Local\Larian Studios\Baldur's Gate 3\Mods`
- BG3 Mod Manager: `C:\src\BG3ModManager\BG3ModManager.exe`
- LSLib ExportTool v1.20.4: `tools/external/ExportTool-v1.20.4/Packed/Tools/Divine.exe`,
  copied from `C:\src\RandomizedDisguiseSelf` during setup rather than re-downloaded.
  `tools/Install-ExportTool.ps1` fetches it from GitHub on a clean machine.

The Script Extender loader is present in the game's `bin/` on this machine because
other projects use it. Bagception must not depend on it, and must be tested with it
absent or disabled before release.

## Repository hygiene

- `dirs.txt` is ignored and holds machine-specific paths. `dirs.example.txt` is tracked.
- `dist/`, `tmp/`, and `tools/external/` are ignored.
- Extracted vanilla game data belongs under `tmp/`, never under tracked source.
- BG3 writes its own log files (`errors.*.txt`, `log.*.txt`, `thothlog.*.txt`, and
  friends) into whatever directory it is launched from; those patterns are ignored.

## Toolkit workflow

- The Toolkit owns five folders under the game's `Data/` directory: `Projects/`,
  `Editor/Mods/`, `Mods/`, `Public/`, and `Generated/Public/`. `src/` mirrors all five.
- `tools/Sync-ToolkitProject.ps1 -Direction FromGame` captures Toolkit output into
  `src/`; `-Direction ToGame` restores it. It copies only the five `Bagception`
  folders and never deletes destination files. Use `-WhatIf` first.
- The Toolkit builds the test `.pak` through **Project Settings -> Publish Local**,
  and handles mod.io publishing.
- The Toolkit packs the project workspace verbatim. A stale compiled `.lsf` in `src/`
  ships even when a hand-built package looks correct, so regenerate and sync before
  building there.

## Osiris

- Osiris story goals live under `src/Mods/Bagception/Story/`. They must be compiled in
  the Toolkit Story Editor; an offline package built without `story.div.osi` silently
  contains no story at all. The MoreHirelings builder throws rather than allow this,
  and any offline packager here should do the same once goals exist.
- Osiris asserts `INITSECTION` facts once, when a goal is first initialized in a save.
  A goal added after distribution does initialize on load in an existing save, but an
  existing goal's `INITSECTION` does not re-run. **So sorting data does not live in
  `INITSECTION`.** It is asserted by `PROC_Bagception_LoadData`, which clears and
  reloads every list on `SavegameLoaded` and `LevelGameplayStarted`; see "Updating a
  save already in progress" below.
- `TemplateAddedTo((ROOT)_ObjectTemplate, (GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder, (STRING)_AddType)`
  is confirmed present, as is the simpler `AddedTo`. What `_InventoryHolder` refers to
  is not yet known; the Phase 1 probe answers it.
### An Osiris mod must depend on GustavX

BG3 runs **one** story. A mod that adds goals does not have its story merged in at
load time; it ships a full recompiled `story.div.osi` containing the whole campaign
plus its own goals. That only happens if the mod declares GustavX as a dependency in
`Mods/<Mod>/meta.lsx`, so the Toolkit compiles against the campaign.

With an empty `Dependencies` node the Toolkit compiles happily against Shared alone,
reports `0 error(s), 0 warning(s)`, and produces a story that the game then ignores,
because the campaign's own story is the one that loads. Nothing anywhere says so. The
probe's second silent failure was this: the mod was enabled, the templates loaded,
and the goal simply never ran.

**Check the compiled size, not the compile log.** A story built against the campaign
is tens of megabytes; one built without it is a couple.

```bash
# Should be ~24 MB and should contain vanilla goal names.
ls -la "$BG3/Data/Mods/Bagception/Story/goals.raw"
grep -a -c "GLO_Backgrounds" "$BG3/Data/Mods/Bagception/Story/goals.raw"
```

Zero hits for a vanilla goal name means the dependency is missing or the Toolkit has
not picked it up. Copy the `ModuleShortDesc` for GustavX from
`C:\src\MoreHirelings\src\Mods\MoreHirelings\meta.lsx`; it carries the real
UUID `cb555efe-2d9e-131f-8195-a89329d218ea` and version.

### Resources under Public must ship as `.lsf`

**The game does not read `.lsx` from a package.** A pak whose `Public/` carries only
`.lsx` loads no root templates and no tags, raises no error, and looks in every other
respect like a working mod. The first probe build failed exactly this way: the Osiris
grant rule ran, `TemplateAddTo` was called, and nothing appeared, because the
templates it named did not exist.

The Toolkit generates the `.lsf` beside each authored `.lsx`, which is why the
question never comes up for Toolkit-created resources. Hand-authored ones have
nothing generating them. `tools/Package-Mod.ps1` now compiles every staged
`Public/**/*.lsx` to `.lsf` during packaging, in the same place it compiles `.xml` to
`.loca`, and keeps both files as a Toolkit-built package does. Compare against
`C:\src\MoreHirelings\dist\*.pak`, which ships `_merged.lsf` alongside
`_merged.lsx`.

**A template nested inside another template is ignored, silently.** Every
`GameObjects` node must be a direct child of the one `Templates` children list. A
script once inserted five new containers after the first line of four tabs plus
`</node>` — which also matches the tail of a deeper `</node>`, so the blocks landed
inside the Larder Pack's `Tags` node. The file stayed well-formed XML, the packager
compiled it, the `.lsf` still contained every name, and the game created none of the
five. Match a closing line exactly (the whole line, not a substring), and after any
scripted edit check that no template contains another:

```bash
python -c "import xml.etree.ElementTree as E; r=E.parse('src/Public/Bagception/RootTemplates/_merged.lsx').getroot(); g=[n for n in r.iter('node') if n.get('id')=='GameObjects']; print(len(g), 'templates,', sum(1 for n in g for m in n.iter('node') if m is not n and m.get('id')=='GameObjects'), 'nested')"
```

The nested count must be 0.

Two related conventions, both followed here: root templates live in a file named
`_merged.lsx`, as vanilla and the Toolkit both name it, and a tag resource is named
for its own UUID.

**The general lesson is about silent failures.** Neither the stats compiler nor
Osiris complains about a template that does not exist — `TemplateAddTo` on an unknown
`ITEMROOT` compiles cleanly, because the literal is just a string constant, and then
does nothing at runtime. Any rule that is supposed to produce something visible
should announce that it ran, so "the rule never fired" and "the rule fired and
achieved nothing" stay distinguishable.

### Read the Osiris runtime log

The Script Extender is installed on this machine and writes a complete Osiris
runtime log — every event, query and call — to the directory named in
`bin/ScriptExtenderSettings.json`, currently `C:\src\RandomizedDisguiseSelf\logs`.
A busy session produces a few hundred megabytes, so grep it; do not open it.

This is a **development tool, not a dependency**. Bagception does not use the
Extender and must never require it. But every probe run is recorded there, and two
rounds of "the message vanished before I could read it" were answerable from the log
the whole time. Check the log before designing a new readout.

```bash
cd "$SE_LOGS"
grep -a -o 'OpenMessageBox([^)]*)' "Osiris Runtime <stamp>.log"
grep -a -o 'TemplateAddedTo([^)]*BAGCEPTION[^)]*)' "Osiris Runtime <stamp>.log"
```

Caveat: the Extender is loaded during these runs, so results are not from a clean
vanilla process. Re-check anything surprising with it disabled.

### A container's default contents belong on the template, not in Osiris

A root template's `InventoryList` node names a **treasure table**, and the engine
creates the container already holding what the table yields:

```xml
<node id="InventoryList">
  <children>
    <node id="InventoryItem">
      <attribute id="Object" type="FixedString" value="BAGCEPTION_MasterContents" />
    </node>
  </children>
</node>
```

```
new treasuretable "BAGCEPTION_MasterContents"
new subtable "1,1"
object category "I_OBJ_Bagception_PotionCase",1,0,0,0,0,0,0,0
```

`I_` names a **stats entry**, `T_` names another treasure table. The file lives at
`Public/<Mod>/Stats/Generated/TreasureTable.txt` — note `Generated/`, not
`Generated/Data/` where the object and status files sit. Confirmed working: four
bags produced four Potion Case instances with no Osiris rule involved.

Prefer this to adding contents with `TemplateAddTo` after the parent arrives. It is
one line per container instead of a rule per container, and it removes a real race
between the parent's arrival and the child's insertion.

### Updating a save already in progress

A mod update has to reach players mid-campaign, so "test in a fresh game" is a testing
convenience, never a requirement on players. Two things do not update by themselves:

- **A bag's contents.** The treasure table fills a bag once, at creation. An older bag
  never gains a container added since. `PROC_Bagception_RepairBag` adds whatever is
  missing from `DB_Bagception_InternalContainer`, on `SavegameLoaded` for `DB_Players`
  and on `CharacterJoinedParty` for a companion rejoining from camp. It must never run
  while a bag is being created: the contents arrive in their own events after the bag,
  and a check in that window would duplicate everything. Neither trigger can see a bag
  in that state.
- **`INITSECTION` facts**, as above. Every lookup list is reloaded instead.

**Adding a container therefore takes one more line than it used to:** its entry in
`BAGCEPTION_MasterContents` for new bags, and its `DB_Bagception_InternalContainer` fact
for old ones. Keep `DB_Bagception_InternalContainer` in treasure-table order.

Rule changes themselves reach an existing save only when the game merges the mod's
story into it on load, and it does that when the mod's `Version64` differs from the one
the save recorded. See "The savegame carries its own copy of the story".

### Known issue: a container created at runtime shows no content count until reload

A Bagception granted mid-session displays as empty even though its Potion Case is
inside and usable. Reloading the save fixes it permanently.

**This was first blamed on the Osiris insertion being a separate step, and that was
wrong.** Moving the contents onto the template via a treasure table, so the engine
creates the bag already populated, did not change the symptom. The stale display
belongs to the container being *created at runtime*, not to how it was filled.

Untried, in rough order of promise: forcing a refresh by moving the bag after the
grant; granting during a loading screen rather than after it. Cosmetic, self-healing
on reload, and not worth much more chasing before the sorter exists.

### Classifying the categories with no vanilla tag

Earlier notes said Osiris had no way to ask "is this a weapon". That was wrong — it
has a direct query, and enough besides to cover every category that lacks a tag.

| Category | Method |
| --- | --- |
| Weapons | `IsWeapon(_Item, 1)` and not `TORCH` |
| Armour | `IsEquipable`, slot in Helmet, Breast, Cloak, Boots, Gloves, Underwear, VanityBody, VanityBoots |
| Shields | offhand slot **and not** `IsWeapon` — there is no Shield slot |
| Jewelry | `IsEquipable`, slot in Ring, Ring2, Amulet |
| Tools | stats name in a list (`GetStatString`), **or** `TORCH`, **or** the MusicalInstrument slot |
| Dyes | not untagged after all: `DYE`, inherited from `BASE_LOOT_Dye` |
| Miscellaneous | still at the top level a second later: see below |

Slot sets live in INITSECTION databases (`DB_Bagception_ArmourSlot`,
`DB_Bagception_JewelrySlot`) joined against `GetEquipmentSlotForItem(_Item, _Slot)`,
which is how vanilla keeps its own armour-slot list. Every slot rule asks
`IsEquipable` first: whether the slot query fails or answers Helmet (0) for a
non-equipable item is unmeasured, and the second would file every loose object as a hat.

Torches and lanterns are **weapons**. Their stats inherit from `WPN_Club`, so `IsWeapon`
answers 1. Every carried torch and lantern, the Moonlanterns included, carries the
`TORCH` tag, which is what the weapon rule excludes and the Tool Roll rule matches.

Vanilla already groups tools under a `_Tool` stats base (kits, digging and crafting
tools, and the non-equipable `_Music` instruments), but only five of its 26 entries
carry any tag. The stats name is the one thing they share, so the Tool Roll lists them
by name. `GetStatString` returns the item's stats entry name; the Adamantine Forge
scripts use it the same way.

**Rarity has no query and no tag.** Nothing in `story_header.div` mentions it; it exists
only as the stats entry's `Rarity` field (Common, Uncommon, Rare, VeryRare, Legendary;
unset displays as Common). Filtering on it would need a generated list of stats names,
which was tried and dropped: see the decision log, 2026-09-23.

The `EQUIPMENTSLOT` enum, from `story_header.div` line 45, is: Helmet 0, Breast 1,
Cloak 2, MeleeMainHand 3, MeleeOffHand 4, RangedMainHand 5, RangedOffHand 6, Ring 7,
Underwear 8, Boots 9, Gloves 10, Amulet 11, Ring2 12, Wings 13, Horns 14, Overhead
15, MusicalInstrument 16, VanityBody 17, VanityBoots 18. **No Shield slot**, so a
shield has to be distinguished from a weapon in the same slot.

**`GetStatString` plus `Substring` is the general escape hatch.**
`GetStatString(_Object, _Statname)` returns the item's stats entry name, and
`Substring(_String, _Start, _Count, _Result)` allows a prefix comparison. Anything
following the `WPN_`, `ARM_`, `OBJ_Dye_` naming convention can be classified without
a tag. It relies on convention, so it covers vanilla and well-behaved mods and will
miss items that name themselves freely.

**A catch-all waits rather than negates.** "Matches nothing else" written as one more
`TemplateAddedTo` rule would race every category rule for the same item, since Osiris does
not promise rule order, and the alternative -- repeating every other rule's conditions,
negated -- would have to be kept in step with each new container. Instead every arrival
in the master bag starts `RealtimeObjectTimerLaunch(_Item, "Bagception_Leftover", 1000)`,
and on `ObjectTimerFinished` anything whose `GetDirectInventoryOwner` is still the master
bag goes to the Odds Sack. Realtime, because `ObjectTimerLaunch` ticks by turn in combat.
Vanilla's Adamantine Forge uses the same pair. Containers, story items and gold are
excluded there and stay at the top level.

**Precedence is written into the conditions, not the rule order.** The Quest Satchel
takes story items ahead of every category, and it does so because every other category
rule carries `IsStoryItem((ITEM)_Item, 0)`, never because its rule comes first. A new
category rule must carry the same check, or story items matching it will race.

**Every key is a story item.** All 36 vanilla templates tagged `KEY` resolve
`StoryItem True`, inherited from `BASE_KEY`. Anything keyed on `IsStoryItem` has to
decide about keys explicitly; the Quest Satchel rule excludes `KEY`, and the Key Ring
rule has no story check.

There is no Valuables container. No tag or consistent stats field marks a trade good:
`BASE_LOOT_Valuable` is a parent template that also holds dyes, Netherstones and
Ketheric's crown controllers, and `ObjectCategory` prices some junk above silverware.

**Check the parent chain before calling a tag unused.** The `DYE` tag resource
(`d8ef5332-…`, defined in GustavDev) was written off here once because no dye template
carries it. None does: `BASE_LOOT_Dye` carries it, and all 42 dyes inherit it. A tag
search has to follow `ParentTemplateId` up the chain, as the scratch tooling's
`chain.py` does.

### Item flags, and the `AttributeFlags` list

`data "Flags"` on a stat entry takes values from the **`AttributeFlags`** valuelist
in `Public/Shared/Stats/Generated/Structure/Base/ValueLists.txt`. That list is the
place to look for "can the engine already do this to an item", and it is a fifth
vocabulary beyond the four listed above. It holds 22 values including `Unbreakable`,
`Unstorable`, `InventoryBound`, `Grounded`, `Floating`, `ThrownImmunity` and
`InvulnerableAndInteractive`.

The same values are reachable as boosts through `Attribute(<flag>)`, which is how
vanilla applies them dynamically: `GEN_INVENTORYBOUND` is a ready-made status doing
exactly that, and Flame Blade and Shillelagh use it so a conjured weapon cannot be
dropped. Prefer the static `data "Flags"` form on an item the mod owns; use the
status form only when the binding has to come and go.

Bagception's containers use `InventoryBound;Unstorable`. `InventoryBound` is
vanilla-proven, and verified here in game 2026-09-23: Bagception cannot be dropped,
and the inner bags cannot be taken out of it, sent to camp or given away.
**`InventoryBound` also hides an item from the trade window**, together with
everything inside it when it is a container, so nothing in Bagception can be sold
directly. Removing `Unstorable` alone did not bring it back (tested 2026-09-23),
which is how the cause was isolated. **`Unstorable` has no user anywhere in the
shipped stats**, so its own effect is not isolated; it is
unverified; if a chest still accepts a container, that is the flag that did nothing.

### `TemplateAddTo` is asynchronous, so an inventory count cannot debounce it

The per-character grant handed one character **two** bags on an existing save. The
Osiris log shows both instances created six lines apart, in the same tick:

```
TagSet(BAGCEPTION_CONT_Master_77f38b01-..., e9e54868-...)
TagSet(BAGCEPTION_CONT_Master_c1313565-..., ...)
```

Two trigger rules fired before either `TemplateAddTo` had materialised, so both read
`TemplateIsInInventory(..., 0)` and both granted. The count guard is correct and
vanilla uses it, but it only protects against *already having* the item, never
against a grant that is in flight.

The fix is a database fact, because **DB assertions are immediate while item
creation is not**. Set `DB_Bagception_GrantPending(_Character)` in the same `THEN`
as the grant, guard every trigger with `NOT DB_Bagception_GrantPending(_Character)`,
and retract it when the item's own `TemplateAddedTo` fires. Retracting on arrival
rather than never is what keeps the grant self-healing: lose the bag later and a
subsequent sweep grants a replacement.

**Type the database `GUIDSTRING`, not `CHARACTER`.** The grant rules bind a
`CHARACTER`, but the rule that clears the flag takes its holder from
`TemplateAddedTo`, whose `_InventoryHolder` is a `GUIDSTRING`. A `CHARACTER`-typed
database rejects it — *parameter 1 type mismatch: got (GUIDSTRING), expected
(CHARACTER)*. `GUIDSTRING` accepts a `CHARACTER`; the reverse is an error. The
declaration in `INITSECTION` is what fixes the type, so it is worth writing even
when the database would compile without it.

Assume any rule that both reads and writes game state can fire more than once per
tick. `SavegameLoaded` alone fired four times in one session, and
`LevelGameplayStarted` seven.

### Character creation dummies are in `DB_Players`

`S_GLO_CharacterCreationDummy_001` through `_004` were each handed a Bagception by a
`DB_Players` sweep while the character creator was open. Guard any sweep that hands
out items with `IsCharacterCreationLevel(_Level, 0)`, or filter the characters.

### Inventory event semantics, measured

- **`TemplateAddedTo(_Template, _Object, _InventoryHolder, _AddType)`'s
  `_InventoryHolder` is the destination inventory**, and it is the container when an
  item goes into a container, the character when it goes to a character. Root versus
  sub-bag is therefore expressible.
- **`_AddType` observed values: `Regular`, `Treasure`, `TradeTreasure`.** Every
  player-initiated move is `Regular`, in either direction. `Treasure` and
  `TradeTreasure` come from loot and vendor generation. There is no auto-collect
  value, and `AddType` does not distinguish a deliberate placement from an incidental
  one — use the holder instead.
- **`ContainerContentFilterCondition` also restricts manual placement.** A player
  cannot drag an item into a container whose filter rejects it. The filter is not
  only an auto-collect rule; it is what the container will accept at all.
- **`ContainerAutoAddOnPickup` does not collect into a nested container** on a
  manual drag. Items dropped into the master bag stay in the master bag even with a
  filtering sub-bag inside it. Dragging directly into the sub-bag works.
- **It does collect into a nested container on a world pickup.** A book picked up from
  the ground went straight into the Book Satchel, skipping the master bag. Whether a
  vanilla auto-collect bag of the same kind (Alchemy Pouch, Keychain, Camp Supply Sack)
  wins when the character carries one is not yet measured. The attribute is a per-
  container design choice: `True` only where collecting on pickup is wanted, currently
  the Reagent Pouch, Larder Pack, Key Ring and Coin Purse, and set `False` explicitly
  everywhere else.
- **Vanilla tags are split across `Shared` and `SharedDev`.** `ALCH_EXTRACT` and the
  extract templates live in `SharedDev`. A search of `Shared` alone reports such a tag
  as nonexistent; check every `*Dev` module before concluding a tag is missing.
- **Magic pockets see nested items**, so `MagicPocketsMoveToByTag` can act as a bulk
  move primitive rather than routing item by item.
- **A tag is not a complete category.** Eighteen readable templates (a `BookId` is set)
  carry no `BOOK` tag, and the Rune Slates are unreadable loot a player files as books
  anyway. Where a tag falls short, list the root templates in a DB and match
  `TemplateAddedTo`'s `_Template` against it. To find the templates behind a display
  name, extract `english.loca` from `Localization/English.pak`, look up the handle, then
  search root templates *and* placed level items (`Mods/*/Levels/*/Items/_merged.lsf`),
  which can rename an instance: the Eldritch Tablet is `LOOT_MF_Rune_Tablet_E`.

### Diagnostics have to outlive the moment

`ShowNotification` is transient and easy to flood — a rule matching every item
entering every inventory buries its own output under ordinary looting.
`OpenMessageBox` is modal and waits for a click, which is better, but it is still
gone once dismissed and cannot be re-read.

For anything whose answer is needed after the fact, **write the result into game
state**. The probe adds a named marker item per outcome, using `TemplateAddTo`,
whose `DisplayName` states the result in words. The player reads their inventory
when the test is over. Two probe runs were lost to unreadable output before this was
done.

Without the Script Extender there is no log to read: `DebugText` goes to the Osiris
log, which is not written for a normal game session. Game state is the only durable
channel.

### Item weight: measured behaviour

All four measured in game on 2026-09-20 with two 10 kg probe gems.

- `Weight(N)` in a status's `Boosts` **does apply to items**, not just characters.
- It is **additive**: a delta on the item's own weight, not an assignment.
  `Weight(0)` does nothing.
- It **clamps at zero**. `Weight(-1000)` against a 10 kg item reads 0, not -1000.
  This is the load-bearing fact: it means a single boost larger than anything the
  game contains zeroes any item, so the mod never needs to know an item's weight —
  which it could not find out anyway, as no Osiris query returns one.
- `RemoveStatus(_Object, "STATUS")`, the two-argument vanilla overload, **restores
  the original weight** cleanly.

Applied with `ApplyStatus(_Object, "STATUS", -1.0, 1, _Source)`; `-1.0` is permanent,
so it survives until something removes it — including after the item leaves the
container, and after the mod is uninstalled. Pair every apply with a removal rule on
`RemovedFrom`.

**How the shipping version does it** (1.0.0.5, `BAGCEPTION_WEIGHTLESS`): apply on
`TemplateAddedTo` into a Bagception or inner bag. On `RemovedFrom` either one, wait
250 ms and then look at `GetDirectInventoryOwner` rather than removing straight away,
because a move from the master bag into an inner bag reports a removal and an arrival
in no known order. Do the same for any arrival elsewhere still carrying the status,
which catches split stacks. On load, `IterateInventory` over each party member, their
Bagception and every inner bag reconciles everything else. The four-argument
`ApplyStatus` form, with no `_Source`, is vanilla's own for statuses with no cause.

### Stats boosts are a third place to look

When asking "can the engine do X natively", there are **four** vocabularies, not
three, and it is easy to search only the first three and conclude something is
impossible:

1. root template attributes (612 distinct ones in Shared alone),
2. `Stats/Generated/Data/*.txt` keys, the `data "Key" "Value"` lines,
3. the Osiris API in `story_header.div`,
4. **the boost function vocabulary**, which appears only inside `data "Boosts"`
   values and nowhere else.

Extract it with a regex for `Name(` across the stats files: 618 distinct functions.
`Weight()` lives there and nowhere else, which is how a survey of the first three
concluded that weight was untouchable. `CarryCapacityMultiplier`, `WeightCategory`
and the `Can*Weight` predicates are in the same list.

Note also that `StatusInInventory`, an `Object.txt` key, points from the item to its
**holder** — vanilla uses it for `HAS_SHOVEL`. It does not status a container's
contents.

### Osiris syntax, learned the hard way

Both of these were compile errors on the first Story Editor build of the probe.

- **A tag argument is a `TAG` literal, never a quoted string.** `IsTagged` is declared
  `query IsTagged([in](GUIDSTRING)_Target, [in](TAG)_Tag, [out](INTEGER)_Bool)`, and
  passing `"BAGCEPTION_MASTER"` fails with *parameter 2 type mismatch: got (STRING),
  expected (TAG)* — and the rule is silently **skipped**, not just warned about. The
  literal form is the tag's `Name`, an underscore, then its UUID, unquoted, with a
  `(TAG)` cast:

  ```
  IsTagged(_InventoryHolder, (TAG)BAGCEPTION_MASTER_e9e54868-4241-49d7-b7ac-9202a8cd6397, 1)
  ```

  A bare UUID with no name prefix has no precedent anywhere in vanilla; every call
  site uses `Name_UUID`. The name must match the `Name` attribute in the tag's `.lsx`.
  The same shape applies to other resource literals, such as root templates.
- **A query's out parameter binds only in the condition section.** Putting
  `Concatenate(..., _Line);` in a `THEN` block fails with *parameter 3 is an unbound
  variable*, because `THEN` takes calls and requires every variable already bound.
  Build strings with `AND` steps before `THEN`:

  ```
  AND
  ConcatenateGUID("[Bagception] ingress -> ITEM holder: ", _InventoryHolder, _Line1)
  AND
  Concatenate(_Line1, "; addType: ", _Line2)
  AND
  Concatenate(_Line2, _AddType, _Line)
  THEN
  ShowNotification(_Host, _Line);
  ```

  Vanilla has zero instances of `Concatenate` in a `THEN` block. `Concatenate` takes
  strings, `ConcatenateGUID` takes a GUIDSTRING as its second argument.

- **The `AddType` strings are not enumerated anywhere in `story_header.div`.** Do not
  match them against guessed literals. The probe prints whatever the engine passes;
  record the observed values here.
- Useful calls confirmed for the sorter: `ToInventory` and `MoveItemTo` to move,
  `GetItemByTagInInventory` to locate a container by tag, `IsContainer`, `IsTagged`,
  `IsCharacter`, `IsItem`, `GetHostCharacter`, `ShowNotification` and `DebugText` for
  diagnostics, and the `Concatenate*` family for building message strings.
- **`MagicPockets*` is the party's shared inventory pool, not a bag subsystem.**
  Surveyed against vanilla usage: every function takes a `_Source` that is a
  `CHARACTER` in all 30-odd call sites across Gustav, GustavDev and Shared, and
  `_GLOBAL_ItemEvents.txt` wraps `IsInMagicPockets(_Item, _Char, 1)` as a plain
  "does this character have this item" test. It is not the mechanism behind nested
  bags, so it does not answer the auto-collect question.
- **One MagicPockets call is still worth having: `MagicPocketsMoveToByTag`.** Its
  signature is `(_Source, _Tags, _Amount, _DestinationInventory, _ShowNotification,
  _ClearOriginalOwner)`, which is a bulk "move every item tagged X into container Y"
  primitive — close to the whole sorter for the ten tag-expressible categories, in
  one call rather than a rule per item. Whether it is usable depends on whether the
  pool sees through container nesting, since Bagception's items sit inside a bag
  rather than loose. The probe now asks, via two `IsInMagicPockets` rules that move
  nothing. Companion queries if it works out: `TaggedItemsGetCountInMagicPockets`
  and `TemplateGetCountInMagicPockets`.
- The Story compiler requires custom tags to be passed as explicit `(TAG)<uuid>`
  values. Passing a custom tag's display/name string to `IsTagged` produces a
  function-definition conflict. In a diagnostic action block, use `Concatenate`
  for message text; this Toolkit build reports `ConcatenateGUID`'s output parameter
  as unbound there.

### Authored container templates

- Both probe containers inherit `CONT_Bag_A`,
  `3e6aac21-333b-4812-a554-376c2d157ba9`, from **Gustav.pak**: `InventoryType 11`,
  `Stats OBJ_GenericLootItem`, with icon, visual, physics and bounds. Inheriting it
  means not setting those, which is why the templates are short.
- Do not invent icon names. `Item_CONT_GEN_Bag_A` was assumed during authoring and
  does not exist; the real icon on `CONT_Bag_A` is `Item_LOOT_Bag_Blackpowder`.
  Every bag now names its own icon, `Bagception_<Name>`, written by
  `tools/Build-Icons.py`; see "Custom icons" below.
- Localization handles are `h` + a GUID with `g` in place of each `-`. They must match
  between the template and `Bagception.xml`, version attribute included.

## Custom icons

Source art is `art/icons/*.png`; `python tools/Build-Icons.py` generates everything else
and sets each template's `Icon`. `docs/containers.md` lists the files. What it relies
on, checked against vanilla's `Shared.pak` and `Game.pak`:

- **An item icon is found by name in two places.** The inventory grid looks the name up
  in an icon sheet index (`Public/<Mod>/GUI/*.lsx`: `IconUVList` of MapKey and UVs,
  plus `TextureAtlasInfo` naming the sheet's path and UUID). Tooltips and the controller
  UI look for a loose file of that name under `Mods/<Mod>/GUI/Assets/...` and
  `.../AssetsLowRes/...`, one per size. Without them, tooltips show no art.
- **The sheet must also be registered as a texture.** Its UUID has to match a
  `TextureBank` resource in `Public/<Mod>/Content/UI/[PAK]_UI/_merged.lsx`, shaped as
  vanilla's entry for `Icons_Items`. The index alone points at nothing.
- **Ship the GUI index as `.lsx`, not `.lsf`.** Vanilla does, and `Package-Mod.ps1`
  skips `GUI` when compiling resources for that reason. The TextureBank is compiled.
- **UVs are inset half a texel** on each side of the cell, as vanilla's are, so
  filtering never picks up the neighbouring icon.
- **Formats:** sheet and tooltip icons DXT5 with the legacy DDS header; controller
  icons BC7 with the DX10 header. No mipmaps. Generated files match vanilla's byte
  sizes exactly, which is a quick check that the format is right.
- **Do not use Pillow's DXT5 writer.** It emits whole 4 × 4 blocks of pure magenta
  inside opaque, ordinary-coloured regions near soft edges. `texconv` (DirectXTex,
  fetched by `Install-Texconv.ps1`) does not. Pillow still does the resizing.
- **Resize premultiplied, then refill transparent pixels' colour** from the object.
  Otherwise the soft edge fades through black, or, where near-zero alpha is divided
  back out, through saturated noise that block compression smears into the visible edge.
- **Loose icons go under `Mods/<Mod>/GUI`, not `Public/Game/GUI`.** Every published
  Toolkit mod with custom item icons in the user's Mods folder ships them as
  `Mods/<Mod>/GUI/Assets/Tooltips/ItemIcons/<Icon>.DDS` and the matching
  `ControllerUIIcons/items_png` and `AssetsLowRes` folders. The Toolkit packs
  `Mods/<Mod>` whole, so they ship; it never packs `Public/Game`. 1.0.0.7 to
  1.0.0.10 went out without them.
- **Loose files in the game's `Data` folder are loaded by the game.** The Toolkit
  workspace lives there. When `Sync-ToolkitProject.ps1` copied `Public/Game/GUI` into
  it, the game read the icons from that folder, so 1.0.0.10 tested fine although its
  package lacked them. They vanished once the workspace copy was deleted. Judge a
  package by `tools/Test-Package.ps1`, never by how the game looks on this machine.

## Localization and the Toolkit

**Publish Local packs only `Mods/<Module>/Localization/<Language>/*.xml`.** It ignores
the top-level `Localization/` folder that the offline packager compiles, so 1.0.0.7
went to mod.io with no strings: every name and description read "Not Found". It went
unnoticed because the offline `Bagception.pak` sat beside the published one in the
Mods folder and supplied the text. MoreHirelings, the precedent, keeps both copies.

- Edit `src/Localization/English/Bagception.xml`, then copy it over
  `src/Mods/Bagception/Localization/English/english.xml`. `Package-Mod.ps1` refuses to
  build while the two differ.
- **Never test a release with a second Bagception package in the Mods folder.** Both
  load, and one can hide what the other lacks.
- **Publish Local packs whatever story the Story Editor last wrote.** On 2026-09-26 a
  "rebuilt" story was still the 2026-09-23 build, and the package shipped it without
  complaint. The freshness check now also harvests the goals' own `"Bagception_*"`
  timer and event names, since a change that adds only rules adds nothing else, and
  `Test-Package.ps1` runs it against the package's `goals.raw`.
- **Run `tools/Test-Package.ps1 -PakPath <pak>` on the Publish Local output before
  uploading.** It checks for strings, story, templates, stats, the icon sheet and every
  tooltip and controller icon.

## LSLib and Divine

Divine is a convenience for offline test packages only. Releases go through the Toolkit.

- Divine requires absolute paths for extraction destinations. A relative `-d tmp\...`
  fails with `Cannot proceed without absolute path`.
- Run one `extract-package` per `-x` glob. Semicolon-separated patterns have silently
  extracted nothing in sibling projects.
- Create a package:

  ```powershell
  .\tools\external\ExportTool-v1.20.4\Packed\Tools\Divine.exe -a create-package -g bg3 -s "<stage dir>" -d "<pak path>"
  ```

- Inspect one:

  ```powershell
  .\tools\external\ExportTool-v1.20.4\Packed\Tools\Divine.exe -a list-package -g bg3 -s "<pak path>"
  ```

## Localization

- The game reads compiled `.loca`, not the authored `.xml`. `tools/Package-Mod.ps1`
  compiles every staged localization `.xml` in place and leaves both in the package.
- Conversion works in both directions with `convert-loca`; `convert-resource` does not
  accept `-i loca -o xml`:

  ```powershell
  ... \Divine.exe -g bg3 -a convert-loca -s "<source>" -d "<target>"
  ```

- Vanilla English strings live in `Data\Localization\English.pak`, file
  `Localization/English/english.loca`.
- The Toolkit reads localization from the project workspace. MoreHirelings keeps two
  copies in sync, one for the Toolkit and one for its offline builder; watch for the
  same requirement here once strings exist.

## Validation

- A successful `Build-Pak.ps1` proves the layout stages and packs. It proves nothing
  about in-game behaviour; the user verifies that.
- BG3 Mod Manager will not list the mod until a `.pak` exists in the BG3 Mods folder.
- `Deploy-Pak.ps1` fails if BG3 is running, because the installed pak is locked.

## Mod identity

- Module UUID `bc5967cf-55d7-382b-8618-3420a83c8b03`. **Reconciled 2026-09-20**: the
  Toolkit generated this when the `Bagception` project was created, and the
  provisional `f2470481-03f2-4439-83d5-68f2e26ae076` was discarded in its favour, in
  both `src/Mods/Bagception/meta.lsx` and `src/Projects/Bagception/meta.lsx`. The
  Toolkit's identity wins because it is the one the Toolkit will publish under.
  Never reuse another mod's UUID, and never reissue this one.
- Toolkit project UUID `88f0c9c4-9b87-596f-ba72-7c82912f19db`, reconciled the same way
  (was `a1b4cb49-e5c2-44a0-92bd-5d90378e7723`).
- `Version64` packs as `major << 55 | minor << 47 | revision << 31 | build`.
  1.0.0.0 is `36028797018963968`. Update it in both `ModuleInfo` and `PublishVersion`.

## Reading a container's contents

Three calls walk an inventory, and all three are used by vanilla:

```
call IterateInventory((GUIDSTRING)_InventoryHolder, (STRING)_Event, (STRING)_CompletionEvent)
call IterateInventoryByTag((GUIDSTRING)_InventoryHolder, (STRING)_Tags, (STRING)_Event, (STRING)_CompletionEvent)
call IterateInventoryByTemplate((GUIDSTRING)_InventoryHolder, (GUIDSTRING)_Template, (STRING)_Event, (STRING)_CompletionEvent)
```

Each raises `_Event` once per item and `_CompletionEvent` when the walk finishes, so
a sweep is written as two rules rather than a loop. Anything that needs to reason
about what is already in a bag — a re-sort pass, a repair sweep, a count — goes
through these.

Resolving a single known item is cheaper and needs no event round-trip:

```
query GetItemByTemplateInInventory([in](ITEMROOT)_ItemTemplate, [in](GUIDSTRING)_InventoryHolder, [out](ITEM)_Item)
query GetItemByTagInInventory([in](STRING)_Tags, [in](GUIDSTRING)_InventoryHolder, [out](ITEM)_Item)
query GetDirectInventoryOwner([in](GUIDSTRING)_Object, [out](GUIDSTRING)_DirectInventoryHolder)
```

`GetItemByTemplateInInventory` is what lets the sorter find a sub-container inside a
particular Bagception without storing an instance map: the template is fixed and
known, the bag instance comes from the event, and the lookup is done on demand. A
stored map would have to be built in the right order and kept in sync; this cannot
drift.

`GetDirectInventoryOwner` returns the immediate holder, as against
`GetInventoryOwner`, which returns the top-level one. An earlier note in this
handbook claimed only the top-level holder was reachable. That was wrong.

## Moving an item into a container

```
call ToInventory((GUIDSTRING)_Object, (GUIDSTRING)_TargetObject, (INTEGER)_Amount, (INTEGER)_ShowNotification, (INTEGER)_ClearOriginalOwner)
```

The target is a `GUIDSTRING`, so it can be a container and not just a character.
Vanilla conventions worth copying: `_Amount` of `-1` moves the whole stack,
`_ShowNotification` of `0` keeps a bulk operation silent, and `_ClearOriginalOwner`
of `0` preserves ownership — passing `1` would launder a stolen item.


## Which direction the sync goes, and why a build can lie

The Toolkit builds the story from the game data directory
(`<game>\Data\Mods\<module>\`), not from `src\`. `src\` is the repository's copy, and
the two are joined only by `tools\Sync-ToolkitProject.ps1`:

| Direction  | Copies              | Run it when                                  |
|------------|---------------------|----------------------------------------------|
| `ToGame`   | `src\` → game data  | after editing a goal, **before** rebuilding   |
| `FromGame` | game data → `src\`  | after a Toolkit build, to capture its output  |

Both directions fail silently when run in the wrong order, and the two failures
compound:

- Editing a goal under `src\` and rebuilding without `ToGame` compiles the *previous*
  goal. The build succeeds and reports no errors, because the file it compiled is
  valid — it simply is not the file that was edited.
- Running `FromGame` while `src\` holds uncommitted edits overwrites them with the
  older Toolkit copy. Git shows a clean tree, which looks like success.

Done in that order, an edit is compiled away and then deleted, and every signal along
the way — clean build, no errors, clean `git status` — reads as normal.

`tools\Package-Mod.ps1` now refuses to package when this has happened. It collects
every `DB_`, `PROC_` and `QRY_` identifier from the authored goals and checks each one
appears in the compiled `goals.raw`, failing with the list of missing names and the
sync command to run. The check is identifier-based on purpose: a timestamp comparison
cannot catch it, because the rebuild that compiled the wrong file still refreshes the
timestamp. Only the module's own prefixed identifiers are usable — matching on a name
vanilla also defines proves nothing, as vanilla's copy is always present.


## The savegame carries its own copy of the story

BG3 serialises the compiled story into every savegame as `StorySave.bin` — 55 MB in a
mid-game save — and restores the story from there on load. It does not re-read the
story from the mod. A story change therefore does not reach a save that already
contains that goal, no matter how many times the mod is rebuilt, repackaged and
redeployed.

This failure has no error message and every check on disk passes. The mod is enabled,
the pak is correct, the compiled story in the pak contains the new rule, and the game
runs the old one.

**The one signal that reports it** is in the Script Extender log, at every launch:

```
ScriptExtender::OnAfterOsirisLoad: 151484 nodes
```

Compare that number across launches. Adding or removing a rule must move it. If it is
identical after a story change, the running story is the savegame's copy and any test
result is meaningless. This was measured across three launches that spanned the
deletion of five rules and roughly 190 lines: the count did not move by one.

**But the game also merges, and that is how an update reaches a save.** Two loads on
2026-09-23 show it in the Extender runtime log: the savegame's story loads, then the
mod's, then the two are merged, and the mod's rules run from then on.

```
ScriptExtender::OnAfterOsirisLoad: 151453 nodes     <- the savegame's copy
ScriptExtender::OnAfterOsirisLoad: 151704 nodes     <- the story in the paks
ScriptExtender::MergeWrapper() - Started merge
ScriptExtender::MergeWrapper() - Finished merge
```

One was a save made with an earlier build of this session; the other an Act 1 save that
had never had the mod, which is how its goal came to initialise and grant bags there.
Other loads the same day show one node count and no merge. **What triggers the merge
is not established.** The measurement above that found no change may have been
confounded: it fell in the same stretch as the CRLF goal that the compiler was silently
dropping, so the paks' story may not have changed between those launches at all.

What a merge keeps and what it does not, as Osiris merges go: rules come from the new
story, database contents come from the save, a goal the save has never seen is
initialised, and an existing goal's `INITSECTION` does not re-run. That last point is
why sorting data is reloaded by a PROC rather than asserted there.

**Measured 2026-09-23, loading one Act 2 save with a newer build:** no merge. The session
ran the new story through character creation, then the save was loaded, and from
`SavegameLoaded` on the Osiris log shows only the save's older rules -- no reload PROC, no
repair, no explosives rule. The save's `meta.lsf` records every mod as
`ModuleShortDesc` with `Version64` **and an `MD5` of the pak**. Here the MD5 differed from
the installed pak and `Version64` did not (1.0.0.0 both), so **a changed pak alone does
not trigger a merge**. A save with no Bagception entry at all did merge.

**A `Version64` bump does trigger it.** The same save, loaded after bumping 1.0.0.0 to
1.0.0.1 with nothing else changed, merged: two node counts and the merge lines in the
Extender log, `PROC_Bagception_LoadData` and the repair ran on `SavegameLoaded`, and the
explosives rule filed a Smokepowder Satchel and a Runepowder Vial.

So: **every release that changes the story must bump `Version64`**, or players' saves
keep running the old rules. The release workflow already bumps it; this is why it is
not optional. The same bump is the way to test a story change against an existing save
during development. A new game remains the quickest test of the rules themselves.

## Never write a section keyword in a goal comment

The Story Editor finds a goal's sections by the words themselves, and a comment does
not hide them. A comment inside `INITSECTION` that mentioned "the KB section" by its
keyword name produced `syntax error: "KBSECTION" unexpected` and `goal KB section
incorrect`, with line numbers in the combined story rather than the goal. Mentioning
`INITSECTION` in comments has compiled without complaint, but treat all four keywords
(`INITSECTION`, `KBSECTION`, `EXITSECTION`, `ENDEXITSECTION`) as reserved in comments
and write "the init section" or "the rules below" instead. Unlike most failures in this
handbook, this one does appear in the error list.

## Goal files must use LF line endings

The story compiler reads `Version 1` as a goal's first line. With CRLF it sees
`Version 1\r`, fails the header parse, and **omits the goal from the build entirely
while reporting `0 error(s), 0 warning(s)`**. The file still ships inside the pak, so
every check short of reading the compiled story passes.

The symptom is indistinguishable from the savegame problem above: a rule that should
fire does not, and nothing anywhere reports a reason. The two can stack, and did.

`.gitattributes` pins `src/Mods/*/Story/RawFiles/Goals/*.txt` to `eol=lf`. When adding
a goal, match the byte-level convention of an existing one rather than assuming the
platform default:

```
head -c 20 <goal>.txt | xxd -p     # 0a between tokens, never 0d0a
```

Confirming a goal actually compiled is a grep against the built story, not the
authored file:

```
grep -c 'Goal([0-9]*).Title("<GoalName>")' <Story>/goals.raw
```

## Event parameter types, and where a cast is needed

`TemplateAddedTo` binds its item as a `GUIDSTRING`, not an `ITEM`:

```
event TemplateAddedTo((ROOT)_ObjectTemplate, (GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder, (STRING)_AddType)
```

GUIDSTRING does not narrow to ITEM on its own, so any query taking an `[in](ITEM)`
needs an explicit `(ITEM)` cast when fed from this event. The compiler reports
`parameter 1 type mismatch: got (GUIDSTRING), expected (ITEM)` and **skips the rule**
— the same silent-skip class as the earlier TAG mismatch, though this one at least
appears in the error list.

Which queries need the cast, for the sorter's untagged categories:

| Query | First parameter | Cast needed from `TemplateAddedTo` |
|---|---|---|
| `IsTagged` | `(GUIDSTRING)_Target` | no |
| `GetItemByTemplateInInventory` | `(ITEMROOT)`, `(GUIDSTRING)` holder | no |
| `IsWeapon` | `(ITEM)_Item` | **yes** |
| `IsEquipable` | `(ITEM)_Item` | **yes** |
| `GetEquipmentSlotForItem` | `(ITEM)_Item` | **yes** |
| `ItemGetGoldValue` | `(ITEM)_Item` | **yes** |
| `IsStoryItem` | `(ITEM)_Item` | **yes** |
| `GetStatString` | `(GUIDSTRING)_Object` | no |

So the tag-expressible categories route without a cast, and nearly every untagged one
requires it; the Tool Roll's stats-name rule is the exception. That asymmetry is why the potion rule
compiled and the shield rule did not.

An `EQUIPMENTSLOT` constant is accepted in the out-parameter position, the same way an
integer is: `GetEquipmentSlotForItem((ITEM)_Item, EQUIPMENTSLOT.MeleeOffHand)` asserts
the slot rather than binding it. Vanilla always binds and joins a database instead, so
this has no precedent in the goals, but the compiler accepts it.

## Treasure tables: one subtable per guaranteed item

A subtable picks *from* its entries according to the counts in its header. This does
not give a bag two containers — it gives it one of the two, chosen at random:

```
new treasuretable "BAGCEPTION_MasterContents"
new subtable "1,1"
object category "I_OBJ_Bagception_PotionCase",1,0,0,0,0,0,0,0
object category "I_OBJ_Bagception_ShieldRack",1,0,0,0,0,0,0,0
```

Each guaranteed item needs its own subtable, and subtables roll independently:

```
new treasuretable "BAGCEPTION_MasterContents"
new subtable "1,1"
object category "I_OBJ_Bagception_PotionCase",1,0,0,0,0,0,0,0
new subtable "1,1"
object category "I_OBJ_Bagception_ShieldRack",1,0,0,0,0,0,0,0
```

Vanilla `ST_MagicItems_Unique` is the first shape, a pick-one list of four uniques.
`GOB_Goblin_Generic` is the second, rolling a loot category and gold separately.

The subtable header is a list of `count,weight` pairs: `"1,1"` always drops one entry,
`"0,1; 1,3; 2,3"` drops none, one or two at 1:3:3 odds. The number after an object
category is that entry's weight within its subtable, not a count.

The failure is quiet — a bag simply arrives holding fewer containers than intended,
with nothing logged — so adding a container means adding a subtable *and* an object
line, and verifying the bag's contents in a fresh game.

## What ContainerContentFilterCondition can express

The whole game contains four of these, all in Shared, none in Gustav:

```
Tagged('KEY')
Tagged('BOOK') and not Tagged('SCROLL')
Tagged('ALCH_INGREDIENT') or Tagged('ALCH_EXTRACT')
IsSupply()
```

So the vocabulary in evidence is `Tagged('<name>')`, the built-in `IsSupply()`, and the
operators `and`, `or`, `not`. There is no predicate for equipment slot, item type or
stat name, and no example of anything else. Candidates beyond this list are guesses,
and a filter that fails to parse is a silent trap: the container either accepts
everything or nothing, with no error.

**A container can only be filtered if its category is tag-expressible.** That splits the
set in two:

- The tagged categories get a filter, which gates manual placement. A player cannot
  put a gem in the Scroll Case by hand. Dyes are one of them (`Tagged('DYE')`).
- Shields, weapons, armour, jewelry, tools and the Odds Sack cannot have one. Manual
  placement into those containers is unrestricted — anything can be dropped in by hand,
  not merely things that are nearly right. Auto-routing is unaffected, since Osiris does
  that.

Vanilla shields confirm why: `WPN_HUM_Shield_B_0` carries **no tags at all**, and its
stats entry is `ARM_Shield` under a `WPN_` template name. Nothing about it is reachable
from a tag expression, which is the same reason it needs the slot-and-not-a-weapon test
in Osiris.

Closing the manual-placement gap would mean an eject rule: catch `TemplateAddedTo` where
the holder is an internal container, decide the item does not belong, and move it back
to the master bag with `GetDirectInventoryOwner`. That is a second mechanism with its
own failure modes — a misfiring eject fights the player — for a case where the player
deliberately placed the item. Not built.
