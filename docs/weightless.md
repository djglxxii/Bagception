The claim that a weightless Bag of Holding **requires Script Extender appears to be incorrect**. There is good evidence that Bagception can remain entirely inside Larian’s supported modding pipeline.

Most importantly, **Bag of Holding - Patch 7** exists as a mod.io version and explicitly says that objects placed inside the bag become weightless. Its Nexus page lists the current version as “Mod.io” and does not list Script Extender as a requirement. ([Nexus Mods][1])

There is also **Containers Extended**, whose Extraplanar Containers add-on makes items placed into its containers effectively weightless using the game’s `EXTRAPLANAR_STORAGE` behavior. Its changelog specifically says the extraplanar tag was eventually applied at the **template level**, which strongly suggests this is fundamentally game-data/container behavior rather than something that inherently requires Lua. ([Nexus Mods][2])

Larian’s current official modding support also explicitly supports Osiris scripting, and Osiris can apply statuses to **items as well as characters**. ([Larian Studios Forums][3])

So I would revise the Bagception design accordingly.

### Recommended Larian-only architecture

Make **every Bagception container extraplanar**, not merely the outer bag:

```text
Bagception                    [EXTRAPLANAR]
│
├── Weapons                   [EXTRAPLANAR]
├── Armor                     [EXTRAPLANAR]
├── Arrows                    [EXTRAPLANAR]
├── Scrolls                   [EXTRAPLANAR]
├── Potions                   [EXTRAPLANAR]
├── Elixirs                   [EXTRAPLANAR]
├── Coatings                  [EXTRAPLANAR]
├── Throwables                [EXTRAPLANAR]
├── Alchemy                   [EXTRAPLANAR]
├── Camp Supplies             [EXTRAPLANAR]
├── Books                     [EXTRAPLANAR]
├── Valuables                 [EXTRAPLANAR]
└── Miscellaneous             [EXTRAPLANAR]
```

This is preferable to assuming the master bag's weight suppression recursively applies through nested containers.

For example:

```text
Bagception
└── Weapons
    └── Greatsword
```

If the game only applies extraplanar behavior to an item's **immediate container**, `Weapons` being extraplanar still guarantees the Greatsword doesn't count toward carried weight.

The master Bagception also remains extraplanar because it can contain things directly:

```text
Bagception
├── Weapons
│   └── Greatsword
│
└── Protected Quest Item
```

The quest item at the root should also be weightless.

### Osiris can handle the rest

Your actual sorting logic fits nicely within officially supported Osiris.

Larian documents `TemplateAddedTo` as firing whenever an entity is added to another entity's inventory, with `_InventoryHolder` identifying the destination. ([Baldur's Gate 3][4])

So:

```text
TemplateAddedTo(ItemTemplate, Item, InventoryHolder, AddType)
```

becomes:

```text
InventoryHolder == Bagception?
           │
      ┌────┴────┐
      │         │
     NO        YES
      │         │
   Ignore    Determine type
                │
                ▼
          Move to sub-bag
```

And `ToInventory` is an officially documented Osiris call that can transfer an existing item into a **container object**, not just a character. ([Baldur's Gate 3][5])

Therefore the core behavior:

```text
Potion
   ↓ player manually drops it
Bagception
   ↓ TemplateAddedTo
Osiris determines POTION
   ↓ ToInventory
Potion Bag
```

doesn't need Script Extender.

### One thing I would *not* do

I wouldn't make Osiris individually manipulate every item's weight.

For example, don't design it as:

```text
Item added
→ apply custom zero-weight status
→ remember item
→ remove status when item leaves
```

unless testing proves that's necessary.

That's much more stateful and error-prone.

Instead, first reproduce the same **native extraplanar-container mechanism** used by the existing Bag of Holding / Containers Extended approach. The engine should own the weight behavior, while Osiris owns only the organization.

That separation is cleaner:

```text
               LARIAN TOOLKIT ONLY

           ┌─────────────────────┐
           │      Bagception     │
           │ EXTRAPLANAR STORAGE │
           └──────────┬──────────┘
                      │
                Osiris sorting
                      │
       ┌──────────────┼──────────────┐
       ▼              ▼              ▼
    Potions         Weapons        Scrolls
 EXTRAPLANAR      EXTRAPLANAR    EXTRAPLANAR
       │              │              │
       ▼              ▼              ▼
 Native engine    Native engine   Native engine
 weight handling  weight handling weight handling
```

### Why you may have been told Script Extender is required

There is some understandable confusion here because many older Bag of Holding mods **do** use Script Extender, and Containers Extended's GitHub repository itself contains a `ScriptExtender` directory. ([GitHub][6])

But that doesn't establish that *weightless containers themselves* require SE.

The much stronger counterexample is SydMeier's post-Patch-7 **mod.io Bag of Holding**, which explicitly advertises weightless contents while having no Script Extender dependency listed. ([Nexus Mods][1])

And Larian's official toolkit can package:

* stats;
* root templates;
* Osiris scripts;
* statuses;
* game resources;

all within the supported mod package. ([Baldur's Gate 3][7])

### What I would prototype first

Before doing any of the sorting work, I'd make a tiny official-Toolkit test mod containing exactly:

```text
Test Bag
└── Test Sub-Bag
```

Then perform three tests:

| Test                                                    | Expected                             |
| ------------------------------------------------------- | ------------------------------------ |
| Put 100 lb directly in Test Bag                         | character weight unchanged           |
| Put 100 lb in Test Sub-Bag while nested inside Test Bag | character weight unchanged           |
| Remove item from bags                                   | character weight immediately returns |

If the second test fails with only the master marked extraplanar, mark the **sub-bag** extraplanar as well. I strongly suspect that's the architecture we'll want for Bagception anyway.

So at this point I would make **"No Script Extender; Larian Toolkit/Osiris only" a hard requirement for Bagception**. Nothing we've identified yet requires abandoning that goal.

The only qualification is that being acceptable to the **official PC mod.io pipeline** and being approved for **console distribution** are separate questions; I would not assume console approval merely from a mod being on mod.io. But from a runtime/technical standpoint, true weightless container contents appear achievable without Script Extender.

[1]: https://www.nexusmods.com/baldursgate3/mods/9065?utm_source=chatgpt.com "Bag of Holding - Patch 7 at Baldur's Gate 3 Nexus - Mods and community"
[2]: https://www.nexusmods.com/baldursgate3/mods/7980 "Containers Extended at Baldur's Gate 3 Nexus - Mods and community"
[3]: https://forums.larian.com/ubbthreads.php?Number=948625&ubb=showflat&utm_source=chatgpt.com "Modding: Guidelines & FAQ - Larian Studios forums"
[4]: https://docs.baldursgate3.game/index.php?title=TemplateAddedTo&utm_source=chatgpt.com "TemplateAddedTo - Baldur's Gate 3 Modding"
[5]: https://docs.baldursgate3.game/index.php?title=ToInventory&utm_source=chatgpt.com "ToInventory - Baldur's Gate 3 Modding"
[6]: https://github.com/darkcharl/containers-extended "GitHub - darkcharl/containers-extended: BG3 Containers Extended · GitHub"
[7]: https://docs.baldursgate3.game/Getting_Started%3A_Creating_a_New_Mod?utm_source=chatgpt.com "Getting Started: Creating a New Mod - Baldur's Gate 3 Modding"
