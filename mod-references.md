Yes. I’d use several mods as references, because no single one appears to solve all of Bagception’s requirements cleanly.

| Reference                             | Best thing to study for Bagception                                               |
| ------------------------------------- | -------------------------------------------------------------------------------- |
| **Containers Extended**               | Auto-sort bag definitions, item tags/categories, extraplanar/weightless behavior |
| **Automatic Inventory Manager (AIM)** | Script Extender inventory events, classification engine, configurable filters    |
| **Bag of Holding Reforged**           | Weightless container contents, nested auto-filtering bags, stacking edge cases   |
| **Quality of Life Hotkeys**           | Recursive/nested bag traversal, identifying auto-collect bags, stack merging     |
| **Simple Sorting Bags**               | Vanilla-style auto-sort tags and how broad item categories are represented       |
| **Auto Send Food To Camp**            | Safe inventory-transfer event handling and avoiding false positives              |
| **BG3 MCM**                           | Optional configuration/persistence if Bagception later becomes configurable      |

The two I would consider the **primary code references** are:

### 1. Containers Extended

This is probably the single most useful reference.

Its source is public on GitHub, including both its PAK content and Script Extender code. ([GitHub][1])

[Containers Extended source repository](https://github.com/darkcharl/containers-extended?utm_source=chatgpt.com)

Study it for:

* how autosort containers are defined;
* which BG3 tags identify arrows, potions, scrolls, weapons, armor, jewelry, etc.;
* custom container templates;
* how modded items can inherit normal sorting behavior;
* the `EXTRAPLANAR_STORAGE` mechanism;
* workarounds for BG3 autosorting occasionally failing.

Its extraplanar add-on specifically makes both its containers **and the contents placed into them effectively weightless**. ([Nexus Mods][2])

That maps directly onto:

```text
Bagception
    ↓
weightless contents
    ↓
nested autosort containers
```

I would probably start Bagception by understanding this codebase before writing anything.

---

### 2. Automatic Inventory Manager

AIM is probably the best reference for the **Script Extender side of your classifier**.

Its complete source is also public. ([GitHub][3])

[Automatic Inventory Manager source repository](https://github.com/osirisOfGit/BG3_Automatic_Inventory_Manager?utm_source=chatgpt.com)

It supports categories such as:

* healing potions;
* weapons;
* armor;
* arrows;
* grenades;
* scrolls;
* camp supplies;
* books;
* coatings;
* consumables.

More importantly, AIM uses Larian's `TemplateAddedTo` event to detect inventory transfers. ([Nexus Mods][4])

For Bagception, that suggests a very clean model:

```lua
TemplateAddedTo(item, destination)

if destination == Bagception then
    Sort(item)
end
```

That is almost exactly your desired semantic:

> Don't care when the item was picked up.
> Don't care what's in the player's inventory.
> Only react when the destination is Bagception.

AIM is also valuable for understanding how to inspect an item and determine what it actually is rather than maintaining thousands of item UUIDs.

---

### 3. Bag of Holding Reforged

This one is extremely relevant even though I did not find a public GitHub repository for it.

Its behavior is almost a proof-of-concept for the physical container architecture you want.

It does three particularly relevant things:

* items inside its Bag of Holding have their effective weight reduced;
* **auto-filtering bags continue to work while they themselves are inside the Bag of Holding**;
* it can merge incoming items with stacks already stored inside nested auto-filter bags. ([Nexus Mods][5])

That means something very close to this is already demonstrated:

```text
Bag of Holding
│
├── Alchemy Pouch
├── Supply Sack
└── Custom Auto-Sort Bag
```

with the child bags continuing to function.

That is a major validation for Bagception's architecture.

It has also encountered useful edge cases you should study from its changelog:

* consuming items directly from the bag affecting calculated weight;
* splitting stacks;
* very large stacks;
* gold behaving strangely;
* auto-stacking;
* bag names/state during initialization. ([Nexus Mods][5])

Those are precisely the kinds of obscure BG3 inventory bugs a new implementation might otherwise rediscover.

---

### 4. Quality of Life Hotkeys

This newer mod is valuable specifically for **nested inventories**.

Its Organize function:

* discovers matching auto-collect bags;
* fills them;
* merges stacks;
* sorts containers;
* traverses bags inside other bags;
* handles nested bags in one operation rather than requiring repeated sorting passes. ([Nexus Mods][6])

That makes it a strong reference for Bagception's hierarchy traversal:

```text
Bagception
    └── Potion Case
         └── items
```

It also says it reads each bag's own auto-collect rule rather than maintaining a hard-coded list of bags. ([Nexus Mods][6])

That's potentially useful if Bagception eventually allows third-party sorting bags inside it.

Even if you don't implement that initially, the technique is worth studying.

---

### 5. Simple Sorting Bags

This one is useful because it relies heavily on **vanilla BG3 sorting behavior** rather than building an elaborate Script Extender classifier.

It has auto-sort containers for:

* coatings;
* grenades;
* arrows;
* scrolls;
* elixirs;
* potions;
* dyes;
* books;
* rings/amulets;
* weapons;
* armor;
* camp clothing. ([Nexus Mods][7])

The especially useful detail is that the author notes most containers use **vanilla tags for autosorting**, which means items added by other mods generally sort automatically if they use standard BG3 item metadata. ([Nexus Mods][7])

That may change how I would implement Bagception.

Rather than writing:

```lua
if item is potion then
    MoveTo(Potions)
elseif item is scroll then
    MoveTo(Scrolls)
...
```

for everything, you may be able to let BG3's existing auto-collect behavior do much of the work.

Potentially:

```text
Player places 20 mixed objects into Bagception

           ↓

Bagception contains native-style autosort containers

           ↓

BG3 auto-filter mechanics distribute eligible objects
```

and use Lua only to handle the things BG3 doesn't handle reliably.

That would be preferable if it proves dependable.

---

### 6. Auto Send Food To Camp

This sounds less related, but its **event safety logic** is highly relevant.

The mod has dealt with cases where inventory events can mean very different things:

* player actually picked something up;
* item was dropped;
* item was thrown;
* item was bought;
* item was sold;
* item was transferred between containers;
* player was interacting with camp storage. ([Nexus Mods][8])

Its changelog specifically mentions fixes for accidentally reacting to movement/drop/throw events and safeguards around container interactions. ([Nexus Mods][8])

For Bagception, this is useful because we want the event semantics to be extremely strict:

```text
Was item placed DIRECTLY into Bagception?
        │
        ├── NO → ignore
        │
        └── YES → sort
```

I would study this one specifically for **guard clauses**, not classification.

---

### 7. BG3 Mod Configuration Menu

You probably don't need MCM for Bagception 1.0.

But if you eventually want options such as:

```text
☑ Sort armor
☑ Sort books
☑ Sort camp supplies
☑ Auto-stack
☐ Sort quest items

Unknown items:
    [Leave in Bagception ▼]
```

then MCM is the obvious reference.

It provides persistent configuration, JSON-backed settings, save-specific ModVars, events, localization, keybindings, and an in-game interface. ([GitHub][9])

I would keep it **optional or absent for V1**, though.

Bagception is attractive partly because its behavior is obvious.

---

## How I'd divide up the research

If I were giving the coding agent a reference package, I'd tell it:

**Containers Extended**
→ Learn how containers, item tags and extraplanar storage work.

**AIM**
→ Learn how `TemplateAddedTo`, item inspection and classification work.

**Bag of Holding Reforged**
→ Learn the edge cases of weight reduction, nested auto-filter containers and stacking.

**Quality of Life Hotkeys**
→ Learn how to traverse and manipulate nested containers safely.

**Simple Sorting Bags**
→ Learn how much classification can be delegated to BG3's native auto-sort tags.

**Auto Send Food To Camp**
→ Learn event filtering and safe inventory transfer guards.

That leads to a potentially simpler Bagception implementation than the design spec initially assumed:

```text
                 Bagception
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
      Quiver     Potion Case   Scroll Case
       │             │             │
   BG3-native    BG3-native     BG3-native
   autofilter    autofilter     autofilter
        \            |            /
         \           |           /
          └────── Bagception ────┘
                   Lua
                    │
           only handles:
           • ingress event
           • forced sort if needed
           • weightlessness
           • container protection
           • repair/recovery
```

I actually think **that hybrid architecture is worth investigating before implementing a large custom classifier**. Containers Extended and Simple Sorting Bags indicate that BG3 already knows how to classify a surprising amount of inventory through its native tags, while Script Extender can supply the behaviors that vanilla containers can't provide. ([Nexus Mods][7])

That would likely make Bagception considerably smaller and more compatible with modded items.

[1]: https://github.com/darkcharl/containers-extended?utm_source=chatgpt.com "GitHub - darkcharl/containers-extended: BG3 Containers Extended · GitHub"
[2]: https://www.nexusmods.com/baldursgate3/mods/7980?utm_source=chatgpt.com "Containers Extended at Baldur's Gate 3 Nexus - Mods and community"
[3]: https://github.com/osirisOfGit/BG3_Automatic_Inventory_Manager "GitHub - osirisOfGit/BG3_Automatic_Inventory_Manager · GitHub"
[4]: https://www.nexusmods.com/baldursgate3/mods/6163?utm_source=chatgpt.com "Automatic Inventory Manager (AIM) at Baldur's Gate 3 Nexus - Mods and community"
[5]: https://www.nexusmods.com/baldursgate3/mods/10878?utm_source=chatgpt.com "Bag of Holding Reforged at Baldur's Gate 3 Nexus - Mods and community"
[6]: https://www.nexusmods.com/baldursgate3/mods/23380?utm_source=chatgpt.com "Quality of Life Hotkeys at Baldur's Gate 3 Nexus - Mods and community"
[7]: https://www.nexusmods.com/baldursgate3/mods/7891?utm_source=chatgpt.com "Simple Sorting Bags at Baldur's Gate 3 Nexus - Mods and community"
[8]: https://www.nexusmods.com/baldursgate3/mods/6086?utm_source=chatgpt.com "Auto Send Food To Camp at Baldur's Gate 3 Nexus - Mods and community"
[9]: https://github.com/AtilioA/BG3-MCM/blob/main/wiki.md?utm_source=chatgpt.com "BG3-MCM/wiki.md at main · AtilioA/BG3-MCM · GitHub"
