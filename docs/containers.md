# Container types

The full set of containers that will exist inside Bagception, as a reference for
producing visual assets. Names are from [`../spec.md`](../spec.md) section 6; the
working names below are what the art should read as, and can change if a better one
comes up while drawing.

Bagception itself is the outermost bag and needs its own art. Everything else lives
inside it and can never be removed from it.

## The set

| # | Container | Holds | Working name | Status |
|---|-----------|-------|--------------|--------|
| — | **Bagception** | everything; the bag the player carries | Bagception | built |
| 1 | Weapons | swords, axes, bows, crossbows, staves — melee and ranged alike, any rarity | Weapon Roll | not built |
| 2 | Shields | all equipable shields | Shield Rack | built |
| 3 | Armour & Clothing | helmets, chest, cloaks, boots, gloves, clothing | Armour Trunk | not built |
| 4 | Jewelry | rings and amulets | Jewel Box | not built |
| 5 | Arrows | special, magical, elemental and utility ammunition | Quiver | not built |
| 6 | Scrolls | all spell scrolls | Scroll Case | not built |
| 7 | Potions | healing and other drinkable potions | Potion Case | built |
| 8 | Elixirs | elixirs, distinct from potions | Elixir Rack | not built |
| 9 | Coatings & Poisons | weapon coatings, oils, poisons | Coating Kit | not built |
| 10 | Throwables | grenades, bombs, explosive flasks | Grenade Satchel | not built |
| 11 | Alchemy | ingredients, extracts, salts, reagents | Reagent Pouch | not built |
| 12 | Camp Supplies | food, drink, camp-supply packs | Larder Sack | not built |
| 13 | Books & Notes | books, letters, notes, journals | Book Satchel | not built |
| 14 | Keys | ordinary game keys | Key Ring | not built |
| 15 | Tools & Utility | thieves' tools, trap kits, shovels and similar | Tool Roll | not built |
| 16 | Dyes | all dye items | Dye Pouch | not built |
| 17 | Valuables | gems, ingots, items whose purpose is sale | Valuables Purse | not built |
| 18 | Miscellaneous | recognised, safe, but matching nothing above | Odds Sack | not built |

Nineteen pieces of art in total: eighteen internal containers plus Bagception itself.

## Not containers

Three things in the spec are policy rather than storage, and need no art:

- **Currency.** Gold stays with BG3's own handling. A Coin Purse is possible later
  but is explicitly not in the default set.
- **Arbitrary containers.** A bag or pouch from vanilla or another mod that is placed
  into Bagception stays at the top level and is never sorted into, to avoid recursive
  nesting and to leave another mod's organisation alone.
- **Protected items.** Quest items and anything with suspicious story properties stay
  at Bagception's top level rather than being filed.

## Notes that may matter for the art

- **Shields have no vanilla tag and no equipment slot of their own.** They share the
  off-hand slot with weapons and are told apart by not being a weapon. Nothing about
  this affects the picture, but it is why Shields is an early build rather than a late
  one.
- **Extracts need no handling.** A player never picks one up: reagents are what is
  found in the world, and extracts are produced from them through the in-game
  extraction option, which deposits the result directly. Only reagents can be dragged
  into Bagception, so `ALCH_INGREDIENT` covers the Reagent Pouch on its own.
- **Keys may not need a container at all.** The spec allows using BG3's native key
  handling instead if that proves safer in testing. Treat this one as provisional.
- **Elixirs are separate from Potions** and the two want to be distinguishable at a
  glance, since they are the pair most easily confused in a full bag.
- **Every container is currently a reskin of one vanilla pouch template**
  (`3e6aac21-…`), so they are visually identical in game today. Distinct art is what
  makes the set usable, and is Phase 8 of the implementation plan.
- Containers are seen small, in an inventory grid, usually alongside sixteen siblings.
  Silhouette and colour will carry more than detail.
