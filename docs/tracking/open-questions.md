# Open questions

These need an answer from research, a test, or the user before the work that depends
on them can be trusted. Move each one to the decision log or the handbook once settled.

## Answered 2026-09-20 — needs a product decision

1. **Can the native system make Bagception's contents weightless?** **No.** Confirmed
   three ways in [`../research/native-capabilities.md`](../research/native-capabilities.md):
   no root-template attribute, no `Object.txt` field, no Osiris function. Making items
   "weigh very little" does not substitute, because weight belongs to each item's own
   stats entry and arbitrary loot keeps its own.

   The one native approximation is `StatusInInventory` on Bagception granting a
   `CarryCapacityMultiplier` boost while it is carried. Both halves are vanilla-proven.
   It raises the encumbrance threshold rather than zeroing weight, cannot scale with
   contents, and leaves the weight visible on the character sheet.

   **Decision needed from the user:** ship the carrying-capacity approximation and
   describe Bagception as a bottomless pack, or drop the weight goal entirely and ship
   it as an organizer. Spec section 2.3 and AC-11 change either way.

## Blocking Phase 1

2. **Does `TemplateAddedTo`'s `_InventoryHolder` report the container an item was
   dropped into, or the owning character?** The event is confirmed to exist in the
   Osiris API. This one detail decides whether the root-versus-sub-bag distinction in
   spec sections 26 and 27 is expressible at all. First thing the probe answers.
3. **Does `ContainerAutoAddOnPickup` fire for a container nested inside another
   container, and on a manual drag rather than only on world pickup?** The native
   auto-collect mechanism is confirmed and its filter language is understood, but the
   attribute name suggests pickup only. The whole native-first classifier rests on
   this. `mod-references.md` reports Bag of Holding Reforged keeps nested auto-filter
   bags working, so it is likely possible.
4. **Which Osiris predicates can classify the six categories with no vanilla tag?**
   Weapons, armour, shields, jewelry, dyes, and valuables have no tag to filter on.
   Osiris offers `IsEquipable` and `IsEquipmentWithProficiency` but no direct "is a
   weapon" query. Sizes Phase 3.

## Later

5. **Can Osiris enforce the container-protection invariant** in spec sections 15 to
   17, detecting an internal container leaving Bagception and restoring it? Phase 4.
6. **Player-facing configuration**, if ever wanted, has no MCM route under the
   native-only constraint. Spec section 36's settings would need an in-game mechanism
   or optional add-on paks. Not needed for 1.0.
