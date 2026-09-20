# Open questions

These need an answer from research, a test, or the user before the work that depends
on them can be trusted. Move each one to the decision log or the handbook once settled.

## Blocking Phase 1

1. **Does `TemplateAddedTo`'s `_InventoryHolder` report the container an item was
   dropped into, or the owning character?** The event is confirmed to exist in the
   Osiris API. This one detail decides whether the root-versus-sub-bag distinction in
   spec sections 26 and 27 is expressible at all. First thing the probe answers.
2. **Does `ContainerAutoAddOnPickup` fire for a container nested inside another
   container, and on a manual drag rather than only on world pickup?** The native
   auto-collect mechanism is confirmed and its filter language is understood, but the
   attribute name suggests pickup only. The whole native-first classifier rests on
   this. `mod-references.md` reports Bag of Holding Reforged keeps nested auto-filter
   bags working, so it is likely possible.
3. **Which Osiris predicates can classify the six categories with no vanilla tag?**
   Weapons, armour, shields, jewelry, dyes, and valuables have no tag to filter on.
   Osiris offers `IsEquipable` and `IsEquipmentWithProficiency` but no direct "is a
   weapon" query. Sizes Phase 3.

## Later

4. **Can Osiris enforce the container-protection invariant** in spec sections 15 to
   17, detecting an internal container leaving Bagception and restoring it? Phase 4.
5. **Player-facing configuration**, if ever wanted, has no MCM route under the
   native-only constraint. Spec section 36's settings would need an in-game mechanism
   or optional add-on paks. Not needed for 1.0.
6. **A Script Extender companion adding weightless storage** is under consideration as
   a separate future package. Its shape, and the questions it raises, are recorded in
   [`../script-extender-edition.md`](../script-extender-edition.md). Nothing is
   decided; revisit after 1.0.
