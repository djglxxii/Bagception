# Native capability survey

What Bagception can and cannot do without the Script Extender. Researched 2026-09-20
against the installed game build, by extracting and reading vanilla data.

Sources, all reproducible locally:

- Osiris API surface: `C:\src\MoreHirelings\src\Mods\MoreHirelings\Story\RawFiles\story_header.div`
  (1383 lines, the complete generated function list).
- Stats: `Shared.pak` -> `Public/Shared/Stats/Generated/Data/*.txt`.
- Root templates: `Shared.pak`, `Gustav.pak`, `GustavX.pak` -> `*RootTemplates/*`,
  converted to `.lsx` (~41 MB for Shared alone).
- Tags: `Shared.pak` -> `Public/Shared/Tags/*` (650 files, 544 converted).

## Verdict: true weightlessness is not achievable natively

Confirmed three independent ways. There is no mechanism anywhere in the native data
model that suppresses the weight of a container's contents.

| Surface | Finding |
| --- | --- |
| Root templates | **Zero** attributes matching `Weight`, `Carry`, `Extraplanar`, or `Bulk` across every root template in Shared, Gustav, and GustavX. |
| Object stats | The full key list for `Object.txt` contains exactly one weight key, `Weight`, which sets an item's **own** weight. No contents modifier, no reduction field. |
| Osiris | **Zero** functions matching `weight` in the entire API. The only `carry` hit is `OnStartCarrying`, about physically carrying world objects, not inventory load. |

This kills spec section 31 outright. Both strategies there were Script Extender
techniques, and there is no native equivalent to fall back on.

### Why "make things weigh very little" does not work either

Weight is a property of each item's own `Object` stats entry. A mod can set the weight
of items **it defines**, and nothing else. Arbitrary loot and modded items that a
player drops into Bagception keep the weight their own authors gave them, and no
container property overrides that.

It does work for the bags themselves: Bagception and its internal containers can be
authored at weight 0, exactly as vanilla does for `OBJ_Backpack_CampSupplies`
(`data "Weight" "0.1"`). So the containers cost nothing, but their contents still
weigh what they weigh. That is worth doing regardless; it is simply not the feature.

### The viable approximation: raise carrying capacity

Not "the contents are free" but "you can carry far more while holding Bagception".
Both halves are vanilla-proven and need no Osiris:

- `StatusInInventory` is a real `Object.txt` field that applies a status to the holder
  while the item sits in their inventory. Vanilla uses it for the shovel
  (`data "StatusInInventory" "HAS_SHOVEL"`).
- `CarryCapacityMultiplier(N)` is a real boost, used by vanilla passives and statuses
  (Enlarge uses `2.0`, Reduce `0.75`, Astral `3.0`).

Composed: Bagception carries `StatusInInventory` pointing at a mod-owned status whose
`Boosts` include `CarryCapacityMultiplier`. Carrying the bag raises the encumbrance
threshold; dropping it lowers it back.

Known limitations, both structural:

- It is a flat multiplier. It cannot scale with what is actually stored, because
  Osiris cannot read an item's weight or a container's total. A player who stores
  enough will still become encumbered.
- The weight remains visible on the character sheet. This is honestly described as a
  bottomless pack, not a Bag of Holding.

## What the native system does well: auto-collect

The mechanism is two root-template attributes:

```xml
<attribute id="ContainerAutoAddOnPickup" type="bool" value="True" />
<attribute id="ContainerContentFilterCondition" type="LSString" value="Tagged('KEY')" />
```

`ContainerContentFilterCondition` is a small boolean expression language. Every use in
the entire shipped game, all four of them:

| Container | Condition |
| --- | --- |
| Keyring | `Tagged('KEY')` |
| Bookshelf | `Tagged('BOOK') and not Tagged('SCROLL')` |
| Alchemy pouch | `Tagged('ALCH_INGREDIENT') or Tagged('ALCH_EXTRACT')` |
| Camp supply sack | `IsSupply()` |

So `and`, `or`, `not`, grouping, `Tagged('X')`, and `IsSupply()` are all demonstrated.
**No other predicate is used anywhere in the game**, so any richer vocabulary is
unverified and must not be assumed.

### Tag coverage per Bagception category

From the 536 vanilla tag names, against the categories in spec section 6:

| Category | Native tag | Expressible? |
| --- | --- | --- |
| Keys | `KEY` | Yes |
| Scrolls | `SCROLL` | Yes |
| Books | `BOOK and not SCROLL` | Yes, vanilla's own expression |
| Potions | `ALCH_SOLUTION_POTION`, `POTION` | Yes |
| Elixirs | `ALCH_SOLUTION_ELIXIR` | **Yes** — vanilla separates these, which was assumed to need code |
| Coatings | `ALCH_SOLUTION_COATING`, `COATING` | Yes |
| Throwables | `ALCH_SOLUTION_GRENADE`, `GRENADE` | Yes |
| Arrows | `ARROW` | Yes |
| Alchemy | `ALCH_INGREDIENT`, `ALCH_EXTRACT_*` | Yes, vanilla's own expression |
| Camp supplies | `IsSupply()`, `FOOD`, `DRINK` | Yes |
| Lockpicks / tools | `LOCKPICKS` | Partly |
| **Weapons** | none | **No** |
| **Armour and clothing** | none | **No** |
| **Shields** | none | **No** |
| **Jewelry** | none | **No** |
| **Dyes** | none | **No** |
| **Valuables** | none | **No** |

Ten of the seventeen categories are pure data. The equipment-shaped categories have no
vanilla tag and need Osiris, which offers `IsEquipable`, `IsEquipmentWithProficiency`,
and `IsTagged` but no direct "is a weapon" query. Sizing that gap is a Phase 3 task.

## Osiris inventory surface

Confirmed present, sufficient for the sorting pipeline:

| Purpose | Function |
| --- | --- |
| Ingress event | `TemplateAddedTo((ROOT)_ObjectTemplate, (GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder, (STRING)_AddType)` |
| Ingress event, no template | `AddedTo((GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder, (STRING)_AddType)` |
| Move an item | `MoveItemTo((CHARACTER)_Character, (ITEM)_Item, (GUIDSTRING)_Target, (INTEGER)_Amount, (STRING)_Event)` |
| Bulk move | `MoveAllItemsTo`, `MoveAllLootableItemsTo`, `MoveAllStoryItemsTo` |
| Find a container | `GetItemByTagInInventory((STRING)_Tags, (GUIDSTRING)_InventoryHolder, [out](ITEM)_Item)` |
| Identify a container | `IsContainer((ITEM)_Item, [out](INTEGER)_IsContainer)` |
| Tags | `IsTagged`, `SetTag`, `ClearTag` |

`TemplateAddedTo` is confirmed to exist as an Osiris event, so spec section 9's
assumption holds in shape. What remains unknown is whether `_InventoryHolder` reports
the **container** an item was dropped into or the owning **character**. The whole
root-versus-sub-bag distinction depends on that, and it is the first thing the probe
must answer.

`GetItemByTagInInventory` is how the sorter will locate each internal container:
tag them and query, rather than tracking UUIDs. It also gives the integrity manager
its duplicate check for free.

## Open after this survey

- Does `_InventoryHolder` report a container or a character? Probe.
- Does `ContainerAutoAddOnPickup` fire for a container **nested inside** another
  container, and on manual drag rather than only on world pickup? The attribute name
  says "on pickup", which may be literal. Probe. `mod-references.md` reports that Bag
  of Holding Reforged keeps nested auto-filter bags working, so it is likely possible.
- Which Osiris predicates can stand in for the six categories with no vanilla tag?
