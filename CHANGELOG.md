# Changelog

All notable changes to Bagception are recorded here. Versions follow the
`major.minor.revision.build` form used by `meta.lsx`.

## [Unreleased]

### Added

- **Weightless contents.** Everything inside Bagception and its bags weighs nothing.
  An item gets its weight back when it is taken out. Items already in Bagception
  become weightless the next time the save is loaded.

### Removed

- **The doubled carrying capacity.** Weightless contents replace it. Anything carried
  outside Bagception counts against the normal limit again.

### Known limitations

- A container from the base game or another mod placed in Bagception weighs nothing,
  but its own contents keep their weight.

## [1.0.0.4] - 2026-09-23

First release. Development builds 1.0.0.0 to 1.0.0.3 were never published.

### Added

- **Bagception**, one bag per party member, given on joining the party and to every
  existing party member when the mod is added to a save in progress. Carrying it
  doubles the carrier's carrying capacity.
- **Nineteen bags inside it**, each with its own icon: Weapon Roll, Shield Rack,
  Armour Trunk, Jewelry Box, Quiver, Scroll Case, Potion Case, Elixir Rack, Coating
  Kit, Grenade Satchel, Reagent Pouch, Larder Pack, Book Satchel, Key Ring, Tool Roll,
  Dye Pouch, Quest Satchel, Coin Purse and Odds Sack.
- **Sorting.** An item dragged onto Bagception is moved into the bag that holds its
  kind. Anything no bag claims goes to the Odds Sack about a second later.
- **Quest items** go to the Quest Satchel ahead of every other bag. Keys are the
  exception and stay on the Key Ring.
- **Collecting on pickup.** Alchemy ingredients, camp supplies, keys and gold picked
  up in the world go straight into the Reagent Pouch, Larder Pack, Key Ring and Coin
  Purse, as vanilla's Alchemy Pouch, Camp Supply Sack and Keychain do.
- **Filtered bags.** Twelve bags refuse anything that does not belong when an item is
  dragged straight onto them.
- **Updates reach saves in progress.** A bag added in a later version is added to
  existing Bagceptions when the save is loaded.

### Known limitations

- Bagception and its bags cannot be dropped, sent to camp, given away or put in a
  chest. The same protection hides Bagception from the trade window: take an item out
  of Bagception before selling it.
- The item count shown on Bagception includes its own bags.
- A bag added during play may look empty until the save is reloaded once.
- Seven bags (Weapon Roll, Shield Rack, Armour Trunk, Jewelry Box, Tool Roll, Quest
  Satchel and Odds Sack) accept anything dragged straight onto them. Items dropped
  onto Bagception itself always sort correctly.
- Only items put into Bagception are sorted. Items already in a character's own
  inventory are never gathered.

### Requirements

- None beyond the game. Bagception uses Larian's native mod system and Osiris only,
  with no Script Extender and no other mod required.
