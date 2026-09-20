# Bagception

## Weightless Nested Auto-Sorting Inventory System for Baldur's Gate 3

**Document Type:** Software / Mod Design Specification
**Working Title:** Bagception
**Target Game:** Baldur's Gate 3
**Primary Platform:** PC
**Primary Runtime Dependency:** Norbyte's Baldur's Gate 3 Script Extender
**Version:** 1.0 Draft

---

# 1. Overview

**Bagception** is a Baldur's Gate 3 inventory-management mod centered around a single magical **Bag of Holding**.

The Bagception master bag is:

* weightless;
* effectively capable of holding unlimited weight;
* portable;
* a container for a predefined collection of specialized sorting containers;
* automatically organized whenever items are placed directly into it.

Conceptually:

```text
Player Inventory
│
├── Equipped Items
├── Other loose items
│
└── Bagception
    │
    ├── Weapons
    ├── Armor
    ├── Jewelry
    ├── Arrows
    ├── Scrolls
    ├── Potions
    ├── Elixirs
    ├── Coatings
    ├── Throwables
    ├── Alchemy
    ├── Camp Supplies
    ├── Books & Notes
    ├── Keys
    ├── Tools
    ├── Dyes
    ├── Valuables
    ├── Miscellaneous
    └── [protected top-level items]
```

The user interacts primarily with **one inventory item: Bagception**.

When an item is placed directly into Bagception, the mod determines its type and immediately moves it into the appropriate internal specialized container.

Example:

```text
Player drags:

    Potion of Speed
        ↓
    Bagception
```

The resulting hierarchy becomes:

```text
Bagception
└── Potions
    └── Potion of Speed
```

The player does not need to manually locate the Potion container.

---

# 2. Design Goals

Bagception should satisfy the following goals.

## 2.1 One visible inventory container

The player should normally need only one organizational container in their character inventory:

**Bagception**

All organizational containers exist inside it.

---

## 2.2 Automatic organization

Items placed directly into Bagception should automatically be classified and routed to their appropriate sub-container.

No manual "Sort" operation should normally be required.

---

## 2.3 Weightless storage

Bagception should function as a true Bag of Holding for gameplay purposes.

The following should contribute **zero effective carried weight**:

* Bagception itself;
* internal sorting containers;
* all items stored within the sorting containers;
* miscellaneous items temporarily remaining at Bagception's top level.

The intended behavior is:

```text
Empty Bagception             → 0 effective weight
Bagception containing 50 lb  → 0 effective weight
Bagception containing 500 lb → 0 effective weight
```

Existing BG3 mods demonstrate that Script Extender-driven "extraplanar" storage can make container contents effectively weightless. Containers Extended currently uses this technique for its extraplanar containers.

---

# 3. Scope

## 3.1 In Scope

Version 1.0 should provide:

* one Bagception master container;
* predefined specialized internal containers;
* automatic classification;
* automatic routing;
* weightless contents;
* stack consolidation where practical;
* save/load persistence;
* installation into existing games;
* protection of internal containers;
* recovery of missing internal containers;
* handling of unknown/modded items;
* protection against sorting loops;
* manual full re-sort command;
* safe-uninstall procedure.

---

## 3.2 Out of Scope

Version 1.0 should **not** automatically:

* collect everything the player picks up;
* manage inventory outside Bagception;
* distribute equipment among party members;
* equip items;
* sell valuables;
* send supplies to camp;
* consume items;
* manage party members' inventories;
* change item rarity;
* modify item statistics.

Bagception is an **inventory container**, not a global inventory manager.

The fundamental rule is:

> **Sorting begins when an item enters the top level of Bagception.**

---

# 4. Master Bag

## 4.1 Name

**Bagception**

Suggested item description:

> *It's bags all the way down.*

Longer tooltip text may explain:

> *An extradimensional container containing an improbable collection of smaller extradimensional containers. Items placed inside are automatically filed away according to type.*

---

# 5. Container Hierarchy

Bagception owns a fixed set of internal containers.

Internal containers are identified using unique templates and/or Bagception-specific tags.

Suggested structure:

```text
Bagception
│
├── Armory
│   ├── Weapons
│   └── Shields
│
├── Wardrobe
│   └── Armor & Clothing
│
├── Jewelry Box
│
├── Quiver
│
├── Scroll Case
│
├── Potion Case
│
├── Elixir Case
│
├── Coatings Case
│
├── Throwables Bag
│
├── Alchemy Pouch
│
├── Camp Supplies Sack
│
├── Library
│
├── Keyring
│
├── Tool Bag
│
├── Dye Pouch
│
├── Valuables Pouch
│
└── Miscellaneous Bag
```

The exact visual hierarchy may be flattened if BG3's nested-container UX makes two nested levels inconvenient.

For example, instead of:

```text
Bagception
└── Armory
    ├── Weapons
    └── Shields
```

Version 1.0 may simply use:

```text
Bagception
├── Weapons
├── Shields
└── Armor & Clothing
```

The logical classifier should remain independent of the presentation hierarchy.

---

# 6. Default Sorting Categories

## 6.1 Weapons

Includes:

* swords;
* daggers;
* axes;
* clubs;
* maces;
* hammers;
* spears;
* glaives;
* halberds;
* quarterstaves;
* bows;
* crossbows;
* hand crossbows;
* other melee or ranged weapons.

Magic weapons should still be classified as weapons.

Rarity should not affect classification.

---

# 6.2 Shields

Includes all equipable shields.

Shields should be checked independently of weapons and general armor.

---

# 6.3 Armor & Clothing

Includes:

* body armor;
* helmets;
* hats;
* gloves;
* boots;
* cloaks;
* clothing;
* camp clothing;
* underwear;
* other equipable clothing.

---

# 6.4 Jewelry

Includes:

* rings;
* amulets;
* necklaces;
* other accessory-slot equipment.

---

# 6.5 Arrows

Includes:

* special arrows;
* magical arrows;
* elemental arrows;
* utility arrows;
* other ammunition-like arrow items.

Examples:

```text
Arrow of Fire
Arrow of Ice
Arrow of Many Targets
Arrow of Roaring Thunder
```

---

# 6.6 Scrolls

Includes all spell scrolls.

---

# 6.7 Potions

Includes potion-class consumables.

Examples:

```text
Potion of Healing
Potion of Greater Healing
Potion of Speed
Potion of Invisibility
```

---

# 6.8 Elixirs

Elixirs should be separated from normal potions.

Examples:

```text
Elixir of Hill Giant Strength
Elixir of Bloodlust
Elixir of Peerless Focus
```

---

# 6.9 Coatings and Poisons

Includes:

* weapon coatings;
* poisons;
* weapon oils;
* toxins intended for application.

---

# 6.10 Throwables

Includes:

* grenades;
* bombs;
* explosive flasks;
* throwable damaging consumables;
* utility throwables.

Examples:

```text
Alchemist's Fire
Smokepowder Bomb
Void Bulb
Spiked Bulb
```

---

# 6.11 Alchemy

Includes:

* alchemical ingredients;
* extracts;
* salts;
* suspensions;
* essences;
* ashes;
* vitriols;
* sublimates;
* other alchemy-system materials.

---

# 6.12 Camp Supplies

Includes:

* food;
* drinks;
* camp-supply packs;
* other objects recognized by BG3 as camp supplies.

---

# 6.13 Books & Notes

Includes:

* books;
* letters;
* notes;
* journals;
* readable documents;
* maps that behave as readable inventory objects.

Story-critical documents are subject to the protected-item rules described later.

---

# 6.14 Keys

Includes normal game keys.

Keys may use either:

* Bagception's internal key container; or
* BG3's native key-storage behavior if compatibility testing demonstrates that this is safer.

---

# 6.15 Tools & Utility Items

Includes items such as:

* thieves' tools;
* trap-disarm kits;
* shovels;
* torches;
* utility kits;
* similar reusable/non-consumable adventuring equipment.

---

# 6.16 Dyes

All dye items should route to the Dye Pouch.

---

# 6.17 Valuables

Includes items whose principal gameplay purpose is sale.

Examples may include:

* gems;
* ingots;
* silverware;
* paintings;
* decorative valuables;
* non-equippable jewelry;
* other trade goods.

Items explicitly marked as quest/story items must override this classification.

---

# 6.18 Currency

Gold should normally be left to BG3's existing currency handling.

Bagception should **not** interfere with normal player gold unless testing shows a clear reason to provide a Coin Purse.

A Coin Purse can be added later as an optional category.

---

# 6.19 Containers

Arbitrary containers introduced by BG3 or other mods require special treatment.

Bagception should **not recursively sort arbitrary containers by default**.

An unknown container placed into Bagception should remain at Bagception's top level.

This avoids:

* unintended recursive nesting;
* infinite sorting loops;
* breaking another mod's auto-sort system;
* unexpectedly dismantling player-created organization.

---

# 6.20 Miscellaneous

Anything recognized as safe but not matching another category should enter:

**Miscellaneous**

However, unknown items with suspicious story/quest properties should remain at the Bagception top level rather than automatically entering Miscellaneous.

---

# 7. Story and Quest Item Safety

Story items represent an important exception to normal sorting.

Existing inventory mods have encountered cases where moving story-critical items into specialized containers can interfere with BG3 game logic. Containers Extended specifically removed/planned to remove automatic Story Item storage because items such as the Book of Thay and Mysterious Artifact could interfere with scripting.

Therefore Bagception should use a conservative strategy.

## 7.1 Protected Item Rule

Before normal classification, determine whether the item appears to be:

* story-critical;
* quest-critical;
* bound to scripted interactions;
* specifically denylisted.

If so:

```text
DO NOT move into a sub-container.
```

Instead leave the item directly inside Bagception.

Example:

```text
Bagception
├── Weapons
├── Potions
├── Scrolls
├── ...
│
└── Mysterious Artifact
```

The item still receives Bagception's weightless-storage benefit.

---

## 7.2 Explicit Safety Lists

The classifier should support:

```text
ProtectedTemplates
ProtectedTags
ProtectedUUIDs
```

These should take precedence over all classification rules.

---

## 7.3 Future Whitelisting

Known-safe quest items may later be allowed into a dedicated:

**Quest Items**

container.

This should not be the Version 1.0 default.

---

# 8. Sorting Pipeline

Whenever an item enters Bagception directly, the following pipeline executes:

```text
Item Added to Bagception
        │
        ▼
Is item one of Bagception's internal containers?
        │
       YES ─────► Ignore
        │
       NO
        ▼
Is item protected/story-critical?
        │
       YES ─────► Leave at Bagception root
        │
       NO
        ▼
Does item have explicit override?
        │
       YES ─────► Use override category
        │
       NO
        ▼
Run classification rules
        │
        ▼
Category found?
     │        │
    YES       NO
     │        │
     ▼        ▼
Move to    Miscellaneous
category    or root
container
```

---

# 9. Sorting Event

Script Extender should be used for dynamic routing.

A suitable implementation can listen to BG3's item-add events such as `TemplateAddedTo`.

Automatic Inventory Manager currently uses `TemplateAddedTo` for its own inventory classification system, demonstrating that this event is suitable for detecting newly transferred inventory items.

Conceptual Lua:

```lua
function OnItemAdded(item, destination)
    if destination ~= BagceptionId then
        return
    end

    if IsBagceptionInternalContainer(item) then
        return
    end

    QueueForSorting(item)
end
```

Sorting should preferably occur through a short queue rather than immediately performing complex work inside the event callback.

---

# 10. Reentrancy Protection

Moving:

```text
Bagception
    ↓
Potion Case
```

will itself cause inventory/container events.

The mod must prevent this from recursively triggering another sort operation.

Possible implementation:

```lua
SortingItems[itemUUID] = true

MoveItem(itemUUID, targetContainer)

SortingItems[itemUUID] = nil
```

And:

```lua
if SortingItems[itemUUID] then
    return
end
```

Internal containers must also be recognizable through a common custom tag such as:

```text
BAGCEPTION_INTERNAL
```

---

# 11. Classification Architecture

Classification should not be implemented as one enormous hard-coded function.

Use a rule-based model.

Conceptually:

```lua
Categories = {
    Weapons = {...},
    Armor = {...},
    Arrows = {...},
    Scrolls = {...},
    Potions = {...},
    Elixirs = {...},
    Coatings = {...},
    Throwables = {...},
    Alchemy = {...},
    Supplies = {...},
    Books = {...},
    Keys = {...},
    Tools = {...},
    Dyes = {...},
    Valuables = {...}
}
```

Each category may inspect:

* item template;
* item type;
* statistics type;
* tags;
* item use type;
* equipment slot;
* weapon properties;
* armor properties;
* consumable properties;
* root template;
* known UUID mappings.

Existing inventory-management mods demonstrate that BG3 item classification can use information such as root template UUID, equipment type, armor type and other entity properties.

---

# 12. Classification Precedence

Some BG3 objects qualify for multiple categories.

Therefore rule precedence must be deterministic.

Recommended precedence:

```text
1. Bagception internal object
2. Protected / quest / story item
3. Explicit template override
4. Key
5. Arrow
6. Scroll
7. Potion
8. Elixir
9. Coating / poison
10. Throwable
11. Alchemy
12. Camp supply
13. Weapon
14. Shield
15. Armor / clothing
16. Jewelry
17. Dye
18. Tool / utility
19. Book / document
20. Valuable
21. Known miscellaneous
22. Unknown / top-level fallback
```

Explicit mappings always beat generic classification.

---

# 13. Modded Item Support

Bagception should make a best effort to categorize items added by other mods.

Classification should first rely on generic properties rather than UUIDs.

For example:

```text
Modded Longsword
```

should normally be classified as:

```text
Weapon
```

without Bagception knowing that item's UUID.

Likewise:

```text
Modded Spell Scroll
```

should route to:

```text
Scrolls
```

when the object exposes the expected BG3 properties/tags.

---

# 14. Classification Overrides

Provide a data-driven override mechanism.

Example conceptual configuration:

```json
{
  "ItemOverrides": {
    "SOME_TEMPLATE_UUID": "Potions",
    "ANOTHER_TEMPLATE_UUID": "Miscellaneous"
  },
  "ProtectedItems": [
    "STORY_ITEM_UUID"
  ]
}
```

This allows compatibility fixes without rewriting core classifier logic.

---

# 15. Internal Container Protection

Bagception's specialized containers are implementation infrastructure and should behave differently from normal containers.

They **must not be removable from Bagception**.

The following operations must not permanently succeed:

* drag internal bag into player inventory;
* drag to another character;
* Send to Camp;
* Send To another character;
* drop;
* throw;
* sell;
* barter;
* add to wares;
* place inside another container.

---

# 16. Internal Container Invariant

The fundamental invariant is:

> Every Bagception internal sorting container must always be a direct or approved descendant of its owning Bagception master container.

For Version 1.0 with a flat hierarchy:

```text
Parent(SubBag) == Bagception
```

at all times.

---

# 17. Protection Enforcement

UI-level prevention should be used where practical.

However, the runtime invariant is authoritative.

If the player or another mod succeeds in transferring:

```text
Potion Case
```

from:

```text
Bagception
```

to:

```text
Camp Chest
```

Bagception should detect this and immediately restore it:

```text
Camp Chest
    Potion Case
        ↓

Bagception
    Potion Case
```

This enforcement should use:

* unique internal tags;
* transfer-event monitoring;
* periodic integrity checking as backup.

No contents should be lost during restoration.

---

# 18. Missing Container Recovery

On:

* game load;
* session initialization;
* Bagception creation;
* explicit repair command;

the mod should validate its structure.

Example:

```text
Expected:
17 internal containers

Found:
16
```

The missing container should be recreated.

---

# 19. Duplicate Container Recovery

If Bagception somehow contains two internal Potion Cases:

```text
Potion Case A
Potion Case B
```

the repair routine should:

1. designate one canonical container;
2. move contents from the duplicate into the canonical container;
3. remove the duplicate.

No contents should be destroyed.

---

# 20. Bag Ownership

Version 1.0 should use **one canonical Bagception per campaign/save**.

The Bagception master bag itself may be:

* transferred between party members;
* placed into the camp chest;
* returned to a party member.

Its internal bags remain attached to it.

The owner of Bagception is therefore simply whichever inventory currently contains the master bag.

---

# 21. Master Bag Restrictions

Recommended behavior:

Bagception itself:

**Allowed**

* transfer between characters;
* Send to Camp;
* retrieve from camp;
* move normally.

**Recommended to prohibit**

* selling;
* barter;
* Add to Wares;
* destruction through ordinary inventory actions.

This prevents accidental permanent loss.

---

# 22. Initial Distribution

The mod should support both new and existing campaigns.

Recommended behavior:

On first initialization for a save:

```text
Does campaign already contain Bagception?
        │
      YES
        │
        ▼
   Repair/validate
        │
       NO
        │
        ▼
Create Bagception
        │
        ▼
Create internal containers
        │
        ▼
Place Bagception into currently controlled player inventory
```

A persistent marker should prevent repeated creation.

---

# 23. Recovery Mechanism

Provide a recovery action in case the master bag becomes inaccessible.

Suggested ability:

**Recover Bagception**

Behavior:

1. locate Bagception anywhere in the party/camp inventory system;
2. if found, transfer it to the active player;
3. if not found, reconstruct it;
4. validate sub-containers;
5. preserve/recover contents wherever possible.

This action should not create duplicates.

---

# 24. Automatic Stack Consolidation

When appropriate, identical stackable items placed into Bagception should merge with existing stacks inside their target container.

Example:

```text
Potion Case
└── Potion of Healing × 8
```

Player adds:

```text
Potion of Healing × 3
```

Desired result:

```text
Potion Case
└── Potion of Healing × 11
```

Bag of Holding Reforged demonstrates that aggressive stacking into existing stacks inside nested containers is possible with Script Extender-based inventory logic.

Stack consolidation must respect items that cannot legitimately stack.

---

# 25. Bulk Transfer

The following operation should work:

Player multi-selects:

```text
Longsword
Potion of Healing
Fire Arrow
Scroll of Misty Step
Diamond
Apple
Book
Drow Poison
```

and drags all of them into Bagception.

After processing:

```text
Bagception
│
├── Weapons
│   └── Longsword
│
├── Arrows
│   └── Fire Arrow
│
├── Scrolls
│   └── Scroll of Misty Step
│
├── Potions
│   └── Potion of Healing
│
├── Coatings
│   └── Drow Poison
│
├── Camp Supplies
│   └── Apple
│
├── Library
│   └── Book
│
└── Valuables
    └── Diamond
```

Bulk insertion should use a sorting queue so large transfers do not produce event storms or recursive sorting.

---

# 26. Manual Placement Into Sub-Bags

The user may manually place items directly into an internal bag.

Version 1.0 should treat this as an explicit user decision.

Therefore:

> Items manually placed directly into a sub-bag should **not** automatically be moved elsewhere.

Example:

The player deliberately places a shovel in:

```text
Weapons
```

Bagception should leave it there.

Automatic classification applies only to ingress through:

```text
Bagception root
```

This provides a useful manual override without requiring configuration.

---

# 27. Removing Items

Taking an ordinary item out of a sub-container must behave normally.

Example:

```text
Bagception
└── Potions
    └── Potion of Speed
```

Dragging Potion of Speed to the player inventory should simply remove it.

Bagception must **not immediately suck it back in**.

This is another reason sorting should only trigger when an item enters the Bagception root.

---

# 28. Top-Level Fallback

Some objects should remain directly in Bagception:

```text
Bagception
│
├── [internal sorting bags]
│
├── Protected Quest Item
├── Unknown Mod Item
└── Unknown Container
```

Top-level placement is not considered a sorting failure.

It is the safe fallback behavior.

---

# 29. Manual "Sort Bagception" Command

Provide:

**Sort Bagception**

This command examines all ordinary loose items currently at Bagception's root and attempts to classify them again.

It should not automatically reorganize existing internal bags.

Use cases:

* another mod inserted items without triggering the expected event;
* an older Bagception version did not recognize an item;
* classification rules were updated;
* the player wants to retry unknown objects.

---

# 30. Full Re-Sort Command

Optionally provide:

**Reorganize Bagception**

This stronger operation:

1. scans all internal containers;
2. extracts all ordinary items;
3. runs the current classifier;
4. redistributes them.

This is useful after major classification updates.

The player should deliberately invoke this operation rather than having it happen silently on every game load.

---

# 31. Weightless Storage Architecture

The master Bagception and internal bags should use the same general concept demonstrated by existing extraplanar container mods.

The effective weight calculation must work through nested containers.

Possible implementation strategies should be tested in this order:

### Strategy A — Extraplanar status on Bagception

Apply weight-negating storage behavior to the master bag.

Test whether nested descendants inherit the effective zero-weight behavior.

### Strategy B — Extraplanar status on all Bagception containers

If nesting prevents Strategy A from accounting correctly:

```text
Bagception             → extraplanar
Weapons                → extraplanar
Armor                  → extraplanar
Potions                → extraplanar
...
```

All internal container templates themselves should also have negligible or zero base weight.

---

# 32. Save Persistence

The following must survive save/load unchanged:

* Bagception ownership;
* Bagception contents;
* internal containers;
* internal container contents;
* classification override data;
* relevant Script Extender state.

Bagception should avoid storing unnecessary per-item persistent data.

Classification should normally be stateless.

---

# 33. Performance

Bagception should perform **event-driven sorting**, not continuous inventory scanning.

Do not:

```text
scan every inventory every frame
```

Instead:

```text
TemplateAddedTo
       ↓
Relevant destination?
       ↓
YES
       ↓
Queue item
       ↓
Classify
       ↓
Move once
```

Full hierarchy scans should occur only during:

* initialization;
* repair;
* manual re-sort;
* recovery.

---

# 34. Compatibility

Bagception should minimize interference with other mods.

## 34.1 Do Not Globally Intercept Inventory

Do not reorganize:

* normal player inventory;
* other custom containers;
* camp chest;
* companion inventories.

Only Bagception is Bagception's responsibility.

---

## 34.2 Do Not Claim Foreign Containers

Other mods' auto-sort containers should remain untouched.

An unknown container placed in Bagception should remain at the Bagception root unless an explicit compatibility rule exists.

---

## 34.3 Event Loop Protection

Other auto-sort mods may respond to the same item movement events.

Bagception must ensure:

```text
Bagception → Potion Case
```

does not result in:

```text
Bagception → Potion Case → Other Mod → Bagception → ...
```

Internal move guards and container recognition are mandatory.

---

# 35. Logging

Provide configurable logging levels:

```text
ERROR
WARN
INFO
DEBUG
TRACE
```

Example DEBUG output:

```text
[Bagception] Item entered master bag:
Potion of Speed
UUID: ...

[Bagception] Classified:
Category = POTION

[Bagception] Destination:
Potion Case

[Bagception] Transfer complete.
```

Unknown objects should generate useful diagnostic information:

```text
[Bagception] Unable to classify item.
Name: Example Item
Template: ...
StatsType: ...
Tags: ...
Leaving item at Bagception root.
```

This will make compatibility reports significantly easier to diagnose.

---

# 36. Configuration

Core behavior should work without user configuration.

Optional future configuration may include:

```json
{
  "AutoStack": true,
  "SortCampSupplies": true,
  "SortKeys": true,
  "SortBooks": true,
  "SortValuables": true,
  "LogLevel": "INFO"
}
```

A future MCM integration may expose these settings through UI.

MCM should **not** be required for Version 1.0.

---

# 37. Suggested Project Structure

Conceptually:

```text
Bagception/
│
├── Mods/
│   └── Bagception/
│       ├── meta.lsx
│       └── ScriptExtender/
│           └── Config.json
│
├── Public/
│   └── Bagception/
│       ├── RootTemplates/
│       ├── Stats/
│       └── ...
│
├── ScriptExtender/
│   └── Lua/
│       ├── Bootstrap.lua
│       ├── Events.lua
│       │
│       ├── Bagception/
│       │   ├── Constants.lua
│       │   ├── Containers.lua
│       │   ├── Classifier.lua
│       │   ├── Sorter.lua
│       │   ├── WeightManager.lua
│       │   ├── IntegrityManager.lua
│       │   ├── Recovery.lua
│       │   └── Logging.lua
│       │
│       └── Data/
│           ├── Categories.lua
│           ├── Overrides.lua
│           └── ProtectedItems.lua
│
└── README.md
```

Norbyte's Script Extender supports Lua/Osiris scripting, engine events, stats, templates, JSON and other APIs suitable for this architecture.

---

# 38. Core Components

## Classifier

Responsible only for answering:

```text
Given item X, what category does it belong to?
```

It should not move items.

---

## Sorter

Responsible for:

```text
Item
  +
Classification
  +
Current Bagception instance
        ↓
Transfer Item
```

---

## Container Manager

Responsible for locating:

```text
Weapons container
Potions container
Scroll container
...
```

inside a particular Bagception.

---

## Integrity Manager

Responsible for verifying:

```text
Master bag exists
Internal bags exist
No duplicates exist
Internal bags are inside master
```

---

## Weight Manager

Responsible for ensuring Bagception and its descendants retain their weightless-storage behavior.

---

## Event Manager

Responsible for subscribing to BG3/Script Extender events and passing relevant events to Bagception's domain logic.

---

# 39. Data-Driven Container Definition

Internal bags should be defined using metadata rather than duplicated code.

Conceptually:

```lua
ContainerDefinitions = {
    {
        Id = "WEAPONS",
        Name = "Weapons",
        Template = "...",
        Order = 10
    },
    {
        Id = "ARMOR",
        Name = "Armor & Clothing",
        Template = "...",
        Order = 20
    },
    {
        Id = "ARROWS",
        Name = "Quiver",
        Template = "...",
        Order = 30
    }
}
```

Adding another category should primarily require adding another definition and classifier.

---

# 40. Internal Tags

Recommended custom tags:

```text
BAGCEPTION_MASTER
BAGCEPTION_INTERNAL
BAGCEPTION_PROTECTED_CONTAINER
```

Category-specific tags may optionally be used:

```text
BAGCEPTION_WEAPONS
BAGCEPTION_ARMOR
BAGCEPTION_SCROLLS
BAGCEPTION_POTIONS
...
```

Do not depend exclusively on display names to identify containers.

---

# 41. Safe Uninstall

Because Bagception contains custom nested containers, uninstalling the mod while items remain inside them could potentially make those items inaccessible.

Therefore provide:

**Prepare Bagception for Uninstall**

The command should:

1. locate Bagception;
2. move all normal contents from every internal container into the owning player's inventory where possible;
3. overflow to the camp chest if necessary;
4. move protected top-level items out;
5. remove internal containers;
6. remove Bagception;
7. clear Bagception-specific persistent state.

Display a confirmation when complete.

The user can then save the game and uninstall the mod.

---

# 42. Error Handling

Bagception must prioritize:

> Never lose the player's items.

When uncertain:

```text
Do not move the item.
```

When a transfer fails:

```text
Leave the item where it currently exists.
```

When classification fails:

```text
Leave it at Bagception root.
```

When a destination container cannot be found:

```text
Recreate destination
        ↓
Retry once
        ↓
If still unsuccessful:
leave item at Bagception root
```

Never destroy an item to resolve an organizational error.

---

# 43. Acceptance Criteria

Version 1.0 is considered functionally complete when all of the following pass.

## AC-01 — Master Bag

Given Bagception is in a player's inventory, it can be opened like a normal container.

---

## AC-02 — Internal Structure

Opening Bagception displays all expected sorting containers.

---

## AC-03 — Potion Sorting

When a normal potion is placed into Bagception root, it moves into Potion Case.

---

## AC-04 — Weapon Sorting

When a weapon is placed into Bagception root, it moves into Weapons.

---

## AC-05 — Armor Sorting

When armor is placed into Bagception root, it moves into Armor & Clothing.

---

## AC-06 — Scroll Sorting

When a scroll is placed into Bagception root, it moves into Scroll Case.

---

## AC-07 — Arrow Sorting

When a special arrow is placed into Bagception root, it moves into Quiver.

---

## AC-08 — Bulk Sorting

When multiple items belonging to different categories are transferred simultaneously into Bagception, every recognized item reaches the correct container.

---

## AC-09 — Unknown Item

An unrecognized item remains safely at Bagception root.

---

## AC-10 — Quest Safety

A protected story item remains at Bagception root and is not placed into a specialized container.

---

## AC-11 — Weight

Adding heavy objects to Bagception does not increase the carrying character's effective carried weight.

---

## AC-12 — Internal Bag Removal

Attempting to move an internal sorting bag outside Bagception does not permanently succeed.

---

## AC-13 — Send to Camp Protection

Attempting to Send to Camp an internal Bagception container leaves or restores it inside Bagception.

---

## AC-14 — Party Transfer Protection

Attempting to send an internal Bagception container to another character leaves or restores it inside Bagception.

---

## AC-15 — Master Transfer

The Bagception master bag can be moved to another party member while retaining all contents and internal structure.

---

## AC-16 — Camp Storage

The Bagception master bag can be sent to and retrieved from camp without losing contents or internal structure.

---

## AC-17 — Save/Load

Bagception and its entire hierarchy remain intact after saving, exiting the game and reloading.

---

## AC-18 — Missing Bag Repair

Deleting/removing an internal container in a development test causes the Integrity Manager to reconstruct it without affecting unrelated contents.

---

## AC-19 — Duplicate Bag Repair

If duplicate internal bags exist, repair consolidates their contents without item loss.

---

## AC-20 — Manual Removal

Taking an ordinary item out of a Bagception sub-container does not cause the item to be automatically returned.

---

## AC-21 — Manual Sub-Bag Placement

An item manually placed directly into an internal container remains there even if it does not match the normal classifier.

---

## AC-22 — Modded Equipment

A conventional modded weapon or armor item exposing standard BG3 properties is correctly classified without requiring an explicit UUID rule.

---

## AC-23 — No Infinite Events

Sorting an item generates no recursive or infinite inventory-transfer loop.

---

## AC-24 — Safe Uninstall

Prepare for Uninstall empties Bagception and its internal bags without destroying normal player items.

---

# 44. Development Phases

## Phase 1 — Proof of Concept

Create:

```text
Bagception
├── Weapons
├── Potions
└── Miscellaneous
```

Implement:

* item-add event;
* classification;
* movement;
* recursion protection.

Goal:

Prove:

```text
Longsword → Weapons
Potion → Potions
Unknown → Miscellaneous
```

through a nested Bagception hierarchy.

---

## Phase 2 — Weightless Storage

Implement and validate extraplanar behavior through nested containers.

Test:

```text
100+ lb stored
character weight unchanged
```

---

## Phase 3 — Full Classification

Add all Version 1 categories.

---

## Phase 4 — Container Protection

Implement:

* removal prevention;
* Send to Camp prevention;
* transfer protection;
* vendor protection;
* repair logic.

---

## Phase 5 — Story Safety

Implement:

* protected-item detection;
* known denylist;
* unknown-story fallback.

---

## Phase 6 — Persistence and Recovery

Implement:

* existing-save installation;
* one-per-save creation;
* save/load validation;
* Recover Bagception;
* duplicate recovery.

---

## Phase 7 — Compatibility

Test against:

* vanilla autosort bags;
* Containers Extended;
* Bag of Holding mods;
* Automatic Inventory Manager;
* common equipment mods;
* common consumable mods.

---

## Phase 8 — Polish

Add:

* custom icons;
* container names;
* tooltip descriptions;
* logging;
* manual Sort;
* Reorganize command;
* Prepare for Uninstall.

---

# 45. Primary Technical Principle

Bagception should remain architecturally simple:

```text
                 ┌──────────────┐
                 │  Bagception  │
                 └───────┬──────┘
                         │
                  Item enters root
                         │
                         ▼
                  ┌────────────┐
                  │ Classifier │
                  └─────┬──────┘
                        │
               Category identified
                        │
                        ▼
                   ┌────────┐
                   │ Sorter │
                   └───┬────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
     Weapons         Potions       Scrolls
```

Bagception should **not** become a generalized party inventory-management framework.

Its responsibility is:

> **Anything intentionally placed into Bagception gets neatly filed into Bagception.**

That constraint should keep the implementation understandable, predictable, compatible, and maintainable.

---

# 46. Product Definition

The shortest definition of Bagception is:

> **Bagception is a weightless Bag of Holding containing permanent specialized auto-sorting bags. Items placed into Bagception are automatically routed into the correct internal bag, while the internal bags themselves can never leave Bagception.**

Or, less formally:

> **One bag in your inventory. Every other bag inside it. Everything where it belongs.**
