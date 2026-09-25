# Container types

Every bag in Bagception, with the name the player sees in game and what files into it.
This is also the brief for the art: each bag's picture should read as the name in the
first column.

Bagception itself is the bag the player carries. The other nineteen live inside it and
can never be taken out.

## How sorting works

An item sorts when the player **puts it into Bagception**, by dragging it onto the bag.
It is then moved into the bag below that claims it. Items picked up in the world go to
the character's own inventory and are not sorted, with four exceptions marked
*collects on pickup*: those bags gather their items straight from the world, as vanilla's
Alchemy Pouch, Camp Supply Sack and Keychain do. Items already in the character's own
inventory are never gathered.

Anything no bag claims moves into the Odds Sack about a second later.

## The bags

| # | In game | What sorts into it |
|---|---------|--------------------|
| — | **Bagception** | The bag the player carries. Holds the nineteen bags below. Other containers stay loose at its top level. |
| 1 | **Weapon Roll** | Every weapon, melee and ranged, at any rarity. Torches and lanterns go to the Tool Roll instead. |
| 2 | **Shield Rack** | Shields. |
| 3 | **Armour Trunk** | Helmets and hats, body armour and clothing, cloaks, gloves, boots, underwear, and camp clothes and shoes. |
| 4 | **Jewelry Box** | Rings and amulets. Loose gems are not jewelry and go to the Odds Sack. |
| 5 | **Quiver** | Arrows of every kind. |
| 6 | **Scroll Case** | Spell scrolls. |
| 7 | **Potion Case** | Potions: healing and every other drinkable potion. |
| 8 | **Elixir Rack** | Elixirs, kept apart from potions. |
| 9 | **Coating Kit** | Weapon coatings, oils and poisons. |
| 10 | **Grenade Satchel** | Things meant to be thrown: grenades, bombs, alchemist's fire and other flasks, caltrops, void bulbs, and smokepowder and runepowder. |
| 11 | **Reagent Pouch** | Alchemy ingredients and extracts. *Collects on pickup.* |
| 12 | **Larder Pack** | Anything that counts as camp supplies: food, drink and supply packs. *Collects on pickup.* |
| 13 | **Book Satchel** | Books, letters, notes and journals, plus maps, posters, pamphlets, and the Rune Slates and Eldritch Tablet. |
| 14 | **Key Ring** | Keys. *Collects on pickup.* |
| 15 | **Tool Roll** | Thieves' tools and the other kits (trap disarm, disguise, forgery, poisoner), shovels and hand tools, musical instruments, torches and lanterns. |
| 16 | **Dye Pouch** | Dyes, and dye remover. |
| 17 | **Quest Satchel** | Quest items: anything the game marks as a story item, such as the Moonlantern, the netherstones and the rune slates. Checked before every other bag, so a quest item that is also a light or a book comes here. Keys are the exception and stay on the Key Ring. See below. |
| 18 | **Coin Purse** | Gold coins. *Collects on pickup.* See below. |
| 19 | **Odds Sack** | Everything the bags above do not claim: gems, silverware, trinkets and junk. |

Twenty pieces of art in total: the nineteen bags plus Bagception itself.

**Placing items by hand.** A player can also drag an item straight into one of the inner
bags. Twelve bags refuse anything that does not belong: the Quiver, Scroll Case, Potion
Case, Elixir Rack, Coating Kit, Grenade Satchel, Reagent Pouch, Larder Pack, Book Satchel,
Key Ring, Dye Pouch and Coin Purse. The other seven (Weapon Roll, Shield Rack, Armour
Trunk, Jewelry Box, Tool Roll, Quest Satchel and Odds Sack) accept anything placed by
hand, because the game's filter cannot express their categories. Items sort correctly either way when dropped
into Bagception itself.

**The Quest Satchel.** Added 2026-09-23 at the user's request. The spec (§7) kept story
items loose at Bagception's top level; a bag of their own keeps them together instead.

- **What counts as a quest item.** Whatever the game itself marks as a story item, the
  same mark that stops such items being sold or destroyed. There is no list to keep up,
  and a mod's quest items are covered if the mod marks them.
- **Ahead of every category.** The Moonlantern is a light, the Orphic Hammer a weapon,
  and several quest items are books; all of them come here rather than to the Tool
  Roll, Weapon Roll or Book Satchel.
- **Keys stay on the Key Ring.** Every key in the game is marked as a story item (all
  36 vanilla key templates inherit it), so putting story first without an exception
  would leave the Key Ring empty.
- **Containers stay loose**, as every other container does, even when marked as story.
- **Only what is put into Bagception.** It does not collect on pickup: the game's
  collection filter cannot test for story items. For the same reason, a quest item
  collected on pickup by the Reagent Pouch, Larder Pack or Coin Purse stays there.
- **Never in the Odds Sack.** If a bag lacks its satchel, as an older bag can until the
  repair adds one, quest items stay loose at Bagception's top level.
- **Not yet verified:** that quest and dialogue checks still find an item two bags
  deep, and whether any quest item refuses to go into a container at all. A refused
  item stays loose; nothing is lost.

**The Coin Purse.** Added 2026-09-23 at the user's request; the spec (§6.18) left gold to
the game unless there was a reason for a purse, and allowed one as a later addition.

- **What counts as gold.** Every gold stack in the game is one template, `LOOT_Gold_A`,
  or a child of it, and it alone carries the `LOOT_GOLD` tag. Sorting and the
  hand-placement filter both test that tag, so gold from another mod sorts too if it
  inherits the vanilla gold template.
- **Collected on pickup.** Gold picked up in the world goes straight into the purse,
  at the user's request (2026-09-23), as the Reagent Pouch, Larder Pack and Key Ring do
  with their items. Gold dropped onto Bagception is filed into it too. Gold already in
  the character's own inventory is never gathered.
- **Not yet known:** whether gold that arrives some other way than a world pickup
  (a trader's change, a quest reward, looting a body) counts as a pickup.
- **Never in the Odds Sack.** The catch-all refuses gold. If a bag lacks its purse, as an
  older bag can until the repair adds one, gold stays loose at Bagception's top level.
- **Older saves.** Bags created before the purse existed get one from the repair that
  runs on load, once the save has merged a version that contains it.
- **Spending works.** Verified 2026-09-23: gold in the purse counts towards the party's
  total at traders.

The spec also proposed a Valuables container. It was dropped: nothing in the game marks
an item as a trade good, short of a gold threshold or a hard-coded list, and one
catch-all was preferred to either. See the decision log, 2026-09-23.

## Not containers

One thing in the spec is policy rather than storage, and needs no art:

- **Arbitrary containers.** A bag or pouch from vanilla or another mod that is placed
  into Bagception stays at the top level and is never sorted into, to avoid recursive
  nesting and to leave another mod's organisation alone.

## Known limitations

- **Other containers inside Bagception keep their contents' weight.** Everything placed
  directly in Bagception or one of its bags weighs nothing, including a vanilla pouch or
  another mod's bag. What is inside that pouch is not directly in one of ours and keeps
  its weight (decision log, 2026-09-23).
- **Bagception's item count includes its own bags.** The number the game shows on
  Bagception counts the nineteen bags inside it, so an otherwise empty Bagception
  shows 19, not 0. The count is drawn by the game's inventory screen, which counts
  every item directly in a container, and the bags are items. Nothing the mod can
  set changes that: no item flag or template attribute hides an item from the
  count, and Osiris cannot reach the display. Changing it would mean replacing the
  game's inventory UI, which would alter every container in the game, not only
  Bagception's, and was ruled out (decision log, 2026-09-23).
- **A bag added during play looks empty until a reload.** A Bagception granted
  mid-session, or a bag added to one by the repair on load, may show no count and
  none of the game's container styling until the save is reloaded once. The bag and
  its contents work normally in the meantime.
- **Bagception does not appear in the trade window.** Nothing inside it can be sold
  directly. **Workaround:** drag the item out of Bagception into the character's own
  inventory, then sell it from there. The cause is what keeps Bagception safe: the
  flag that stops it being dropped, sent to camp or given away also marks it as
  untradeable, and the trade window hides it together with everything inside.
  Removing that flag would leave Bagception unprotected, with only a script to put
  it back after it left; that was judged not worth it (decision log, 2026-09-23).

## Art specification

This section is the brief for producing the icons, whether by hand or with an image
generation model. It is written to be handed over as it stands.

### What is needed

**Twenty icons**, one per bag in the table above: Bagception and the nineteen bags
inside it. All twenty source PNGs are present and the icon builder has generated
their game assets. The original nineteen were verified in game; the Quest Satchel
still needs an in-game check. Only icons are needed. Each bag keeps the vanilla 3D
pouch model, which is only seen when an item lies in the world, and none of these
bags can ever be dropped.

### Deliverable format

| | |
|---|---|
| Count | 20 images, one object per image |
| File type | PNG |
| Size | **1024 × 1024** preferred; 512 × 512 minimum. Square, 1:1 |
| Background | **Truly transparent** (a real alpha channel) |
| Colour | 8-bit RGBA, sRGB |
| File names | the in-game name with spaces removed, as listed below |

File names: `Bagception.png`, `WeaponRoll.png`, `ShieldRack.png`, `ArmourTrunk.png`,
`JewelryBox.png`, `Quiver.png`, `ScrollCase.png`, `PotionCase.png`, `ElixirRack.png`,
`CoatingKit.png`, `GrenadeSatchel.png`, `ReagentPouch.png`, `LarderPack.png`,
`BookSatchel.png`, `KeyRing.png`, `ToolRoll.png`, `DyePouch.png`, `QuestSatchel.png`,
`CoinPurse.png`, `OddsSack.png`.
They go in `art/icons/`; see "Where the files go" below.

**Transparency is the most common failure with generation models.** A grey-and-white
checkerboard *drawn into the picture* is not transparency, and neither is a white
background. If the model cannot produce a real alpha channel, ask instead for the object
on a **flat, uniform background of one colour that appears nowhere on the object** (pure
green `#00FF00` or pure magenta `#FF00FF`), with no gradient, vignette, floor or shadow.
The background is then removed during processing. Say which was done.

### Where the files go

All paths are relative to the repository root, `C:\src\Bagception`.

**What you supply:**

```
art/
  icons/
    Bagception.png
    WeaponRoll.png
    ...                 one PNG per bag, named exactly as listed above
    QuestSatchel.png
    CoinPurse.png
    OddsSack.png
    README.md           optional: note anything unusual, such as keyed backgrounds
```

- `art/icons/` holds **final** images only, and it is committed: these PNGs are the
  source the game files are built from. Drafts and rejected variations stay outside the
  repository.
- Names are exact and case-sensitive: `JewelryBox.png`, not `jewelry_box.png` or
  `Jewelry Box.png`. A missing or misnamed file stops the conversion, and the script
  names the file it expected.
- Replacing an icon later means overwriting its PNG under the same name and rebuilding;
  nothing else changes.
- If the images were made on a green or magenta background rather than a transparent
  one, say so in `art/icons/README.md` and name the colour.
- Nothing goes in `src/` by hand. Everything under `src/` is either mod source or the
  Toolkit's copy of it, and the icon files there are generated.

**What the script generates** from them. Listed so it is clear what not to edit by hand;
these are rebuilt from `art/icons/` every time. To rebuild after changing any PNG:

```powershell
.\tools\Install-Texconv.ps1      # once per machine: fetches texconv into tools/external/
python tools/Build-Icons.py
```

The script checks every file is present, square, at least 512 pixels and has an alpha
channel, and stops naming the file if one is not. It is safe to run repeatedly.

| File | Contents |
|---|---|
| `src/Public/Bagception/Assets/Textures/Icons/Bagception_Icons.dds` | the inventory icon sheet: every bag's 64 × 64 cell |
| `src/Public/Bagception/GUI/Bagception_Icons.lsx` | where each bag's cell sits in the sheet, by icon name |
| `src/Public/Bagception/Content/UI/[PAK]_UI/_merged.lsx` | registers the sheet as a texture, under the UUID the index names |
| `src/Public/Game/GUI/Assets/Tooltips/ItemIcons/Bagception_<Name>.DDS` | tooltip icon, 380 × 380 |
| `src/Public/Game/GUI/AssetsLowRes/Tooltips/ItemIcons/Bagception_<Name>.DDS` | tooltip icon, 192 × 192 |
| `src/Public/Game/GUI/Assets/ControllerUIIcons/items_png/Bagception_<Name>.DDS` | controller icon, 144 × 144 |
| `src/Public/Game/GUI/AssetsLowRes/ControllerUIIcons/items_png/Bagception_<Name>.DDS` | controller icon, 72 × 72 |

The last four paths sit in the game's shared `Public/Game` folder, where the game looks
up tooltip and controller icons by name. The `Bagception_` prefix keeps them from
colliding with vanilla or another mod. Whether the Toolkit's Publish step packs a
mod-supplied `Public/Game` folder is not yet confirmed. If it does not, those four sizes
need another route, and only the inventory sheet is certain to ship.

Each bag's root template then gets an `Icon` attribute naming its icon, in
`src/Public/Bagception/RootTemplates/_merged.lsx`.

### What the game does with them

The PNGs are converted by script into five files per bag. The formats match vanilla's:
DXT5 (BC3) for the sheet and tooltip icons, BC7 for controller icons.

| Use | Size | Where the player sees it |
|---|---|---|
| Inventory icon | 64 × 64, one cell of a shared icon sheet | the inventory grid; **by far the most seen** |
| Tooltip icon | 380 × 380 | the large picture in the item tooltip |
| Tooltip icon, low-res | 192 × 192 | the same, at lower UI resolution |
| Controller icon | 144 × 144 | the controller/console-style UI |
| Controller icon, low-res | 72 × 72 | the same, at lower UI resolution |

Everything is downscaled from the one supplied image, so it has to work at 64 pixels.
The game draws its own slot background and rarity frame around the icon; the image must
not include either.

### Style: match the game's own item icons

Vanilla BG3 item icons, checked against the game's own tooltip icons (a leather pouch,
the Alchemy Pouch, a healing potion), share these traits. The set should too.

- **A single object, rendered, not drawn.** Semi-realistic painted 3D, with believable
  materials: worn leather, cloth with visible weave, dull metal, wood. Not cartoon, not
  flat vector, not pixel art, not a photograph.
- **Centred and filling the frame.** The object uses almost the full height, about 90 to
  95 per cent, and is centred horizontally. Leave only a thin margin; vanilla icons
  nearly touch the top and bottom edges.
- **Seen from slightly above and in front**, a gentle three-quarter view, upright. The
  same angle for all twenty.
- **Lit the same way throughout.** Soft key light from the upper left, a faint cool rim
  light around the silhouette, gentle falloff into shadow. No hard cast shadow, no floor,
  no contact shadow.
- **A soft glow at the silhouette is fine.** Vanilla edges fade out over a few pixels
  rather than being cut hard, and magical items (the healing potion) carry a faint
  coloured glow. Keep any glow subtle and tight to the object.
- **Muted, earthy palette** with one strong accent colour per bag (see below). Dark,
  saturated accents read well against the game's dark UI; pale or pastel ones wash out.
- **No text.** No lettering, labels, numbers or legible writing: it cannot be
  translated and is unreadable at 64 pixels. Decorative runes or stitched patterns that
  do not read as letters are fine.
- **Nothing that is not the object.** No background scene, frame, border, badge,
  watermark or signature.

### Readability rules

These icons sit side by side in a grid of nineteen, at 64 pixels. What tells them apart
at that size is silhouette and colour, not detail.

1. **Each bag needs its own silhouette.** A roll, a rack, a box, a tube, a ring, a sack
   and a satchel should be recognisable as outlines alone. Avoid twenty round pouches.
2. **Each bag needs its own dominant colour.** Use the accents below so no two bags
   share one.
3. **Show what it holds.** A hilt, arrow fletching, a scroll end, a potion neck or a key
   bow peeking out tells the player the category faster than the container does.
4. **Big shapes, few of them.** Fine stitching, small buckles and thin straps disappear
   at 64 pixels. Test every icon by shrinking it to 64 × 64 before accepting it.
5. **Must not look like a vanilla bag.** The player also carries vanilla pouches, the
   Alchemy Pouch and the Camp Supply Sack; ours should not be mistaken for them.

### Each icon

| File | Concept | Accent colour | Must be distinct from |
|---|---|---|---|
| `Bagception.png` | A sturdy travelling bag, mouth open, with smaller bags visibly nested inside it: "bags all the way down". The hero icon of the set | deep teal | every other bag; it is the one the player carries. Also **Quest Satchel**, the other important-looking bag |
| `WeaponRoll.png` | A long canvas or leather roll, partly unrolled, sword and dagger hilts in pockets | steel grey on oxblood leather | **Tool Roll**: same roll idea, so different colour and contents |
| `ShieldRack.png` | A small wooden rack or strap-frame holding a round shield face-on | oak brown with iron | Armour Trunk |
| `ArmourTrunk.png` | A compact banded chest with a pauldron or folded cloth spilling over the lid | dark green | Jewelry Box: both are boxes, so this one is larger and plainer |
| `JewelryBox.png` | A small ornate casket, lid open, a ring and an amulet chain visible | royal purple with gold | Odds Sack, which holds loose gems |
| `Quiver.png` | A leather quiver, arrows with bright fletching showing | ochre / tan, bright fletching | Scroll Case: both are tubes, so the arrows must show clearly |
| `ScrollCase.png` | A capped cylindrical case, a rolled scroll end with a wax seal visible | parchment cream and red wax | Quiver |
| `PotionCase.png` | A padded case with round potion flasks, red liquid visible | red | **Elixir Rack.** The pair most easily confused: potions are round-bellied flasks in a soft case |
| `ElixirRack.png` | A small upright rack of tall, slender vials, blue or violet liquid | cobalt blue | **Potion Case**: tall and upright against round and soft |
| `CoatingKit.png` | A small sealed kit with a vial of green oil and a dripping applicator | poison green | Reagent Pouch, Dye Pouch |
| `GrenadeSatchel.png` | A stout satchel with a round fused bomb and a flask peeking out | charcoal with orange | Odds Sack, **Quest Satchel** |
| `ReagentPouch.png` | A pouch of many small compartments, herbs and mushrooms showing | moss green and brown | **vanilla Alchemy Pouch** (purple, starred): must not resemble it |
| `LarderPack.png` | A food pack with a bread loaf and a wine bottle neck showing | wheat gold | **vanilla Camp Supply Sack** |
| `BookSatchel.png` | A flat document satchel, book spines and a folded letter showing | navy blue | Scroll Case, **Quest Satchel**: both are satchels, so this one stays flat and plain |
| `KeyRing.png` | A large iron ring with several keys hanging from it; not a bag at all | iron and brass | nothing: its silhouette is unique |
| `ToolRoll.png` | A tool roll with a hammer, lockpicks and a small shovel, a torch alongside | leather brown with brass | **Weapon Roll** |
| `DyePouch.png` | A pouch of stoppered vials, each a different bright colour | multicolour vials on white cloth | Coating Kit, Elixir Rack, **Coin Purse** |
| `QuestSatchel.png` | A sturdy upright messenger satchel of black leather with silver fittings. Its flap is fastened by a large round silver medallion clasp, embossed with an abstract rune (not a letter). A faintly glowing pale-amber crystal shard and the edge of an old, ornate artefact peek out from under the flap. It should look important, the bag you would never leave behind | black leather, silver, a soft amber glow | **Book Satchel** (flat, navy), **Grenade Satchel** (charcoal, bomb) and **Bagception** (teal, open, bags inside): the medallion clasp and the glow must carry it. Do not reproduce any real BG3 quest item, such as the Astral Prism or a netherstone |
| `CoinPurse.png` | A small, stiff-framed leather purse with a metal clasp top, open, gold coins heaped in its mouth and a few spilling in front of it. Not a drawstring sack | bright gold coins on dark brown leather | **Dye Pouch and Odds Sack**, both drawstring sacks: the rigid clasp frame and the coins must carry it. Also Jewelry Box and Larder Pack, which already use gold: here the gold is the coins themselves, bright and metallic, against dark leather |
| `OddsSack.png` | A lumpy, patched sack, odds and ends spilling out: a gem, a spoon, a candle | faded burlap with one bright gem | Grenade Satchel, **Coin Purse**; it should look humble |

### Things not to do

- Do not trace, copy or closely imitate Larian's own icons. Matching their style is the
  aim; reproducing an existing icon is not.
- Do not add a background, frame, rarity glow or slot square.
- Do not put more than one bag in an image, or show a bag held by a character.
- Do not vary the camera angle, lighting or rendering style between icons; the set
  should look like one artist's work.
- Do not rely on colour alone to tell a pair apart; the silhouette must differ too.

### Other notes

- **Elixirs are separate from potions**, and the pair is the one most easily confused
  in a full bag. It has the strictest brief above for that reason.
- **Every bag is a reskin of one vanilla pouch** (`3e6aac21-…`), so its icon is the only
  thing that tells it apart. The Quest Satchel's new icon still needs an in-game check.
- **The Quest Satchel matches the existing nineteen.** It uses the shared prompt
  recorded in `art/icons/README.md`, with the Quest Satchel's subject and accent
  from the table above.
- **Extracts share the Reagent Pouch with ingredients**, as in vanilla's Alchemy Pouch;
  the icon needs to suggest alchemy in general, not extracts specifically.
