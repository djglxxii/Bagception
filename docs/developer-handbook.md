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
  existing goal's `INITSECTION` does not re-run. Plan roster or registration changes
  around that: new facts need a new goal, not an edit to an old one.
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

### Classifying the six categories with no vanilla tag

Earlier notes said Osiris had no way to ask "is this a weapon". That was wrong — it
has a direct query, and enough besides to cover every category that lacks a tag.

| Category | Method |
| --- | --- |
| Weapons | `IsWeapon(_Item, 1)` |
| Armour | `GetEquipmentSlotForItem` in Helmet, Breast, Cloak, Boots, Gloves, Underwear |
| Shields | offhand slot **and not** `IsWeapon` — there is no Shield slot |
| Jewelry | `GetEquipmentSlotForItem` in Ring, Ring2, Amulet |
| Dyes | `GetStatString` + `Substring`, prefix `OBJ_Dye_` |
| Valuables | `ItemGetGoldValue` above a threshold |

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

Unverified: the shield discriminator, and what gold threshold makes something a
valuable. There **is** a `DYE` tag resource, `d8ef5332-ed2f-42cb-817d-bd2164673223`,
but no root template in Shared or Gustav carries it, so it cannot be used.

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
vanilla-proven. **`Unstorable` has no user anywhere in the shipped stats**, so it is
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
- **Magic pockets see nested items**, so `MagicPocketsMoveToByTag` can act as a bulk
  move primitive rather than routing item by item.

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
  Inherit rather than name one.
- Localization handles are `h` + a GUID with `g` in place of each `-`. They must match
  between the template and `Bagception.xml`, version attribute included.

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
