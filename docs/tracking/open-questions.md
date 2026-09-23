# Open questions

These need an answer from research, a test, or the user before the work that depends
on them can be trusted. Move each one to the decision log or the handbook once settled.

## Answered

1. **`TemplateAddedTo`'s `_InventoryHolder` is the destination container.**
   Answered 2026-09-21 from the Osiris runtime log. A gem into the master bag
   reported the bag; out of it, the character. Root-versus-sub-bag is expressible.
2. **Native auto-collect does not collect into a nested container.** Answered,
   negatively. Potions dropped into the master bag with the Potion Case nested inside
   stayed put. Osiris must route everything; the ten "free" categories are not free.
2b. **Magic pockets do see nested items.** Answered, positively.
   `MagicPocketsMoveToByTag` is viable as a bulk sorter.

All three are written up in the decision log with the evidence.

## Blocking Phase 1

2c. **Weight: answered.** `Weight()` reaches items, is additive, **clamps at zero**,
   and `RemoveStatus` restores the original weight. Native weightless storage is
   therefore achievable: one boost larger than any item's weight zeroes anything.
   Recorded in the decision log. What remains is not capability but safety, below.
   A container-level shortcut was also tested and does not exist: the master bag at
   `Weight -100000` read 0 empty and 20 with two 10 kg gems, because the clamp is
   per entity and contents sum on top of it.

2d. **If weightlessness is ever built, what happens on uninstall?** The status sits
   on items the mod does not own and outlives it. Does the boost stop applying once
   its stats entry is gone, or does the item stay weightless forever? Untested, and
   it decides whether the feature is shippable at all.

2e. **Does a master-bag-to-sub-bag move strip a status that was just applied?**
   `RemovedFrom` and `TemplateAddedTo` both fire and their order is unknown.
   Deliberately not measured yet; the probe was driven in and out of the bag only.

3. **Classifying the six untagged categories: answered.** `IsWeapon`,
   `GetEquipmentSlotForItem`, `ItemGetGoldValue`, and `GetStatString` with
   `Substring` for prefix matching cover all six. The earlier claim that Osiris had
   no "is this a weapon" query was wrong. Details and the `EQUIPMENTSLOT` enum are
   in the handbook. Phase 3 is not blocked. The shield discriminator is confirmed in
   game; weapons, armour, jewelry and tools are built on the same queries (untested at
   the time of writing). Still to settle: the gold threshold for valuables.

## Later

8. **A container created at runtime shows no content count until the save is
   reloaded.** Cosmetic; contents are present and usable throughout. Not caused by
   the Osiris insertion — a treasure table on the template produced the same
   symptom. Suspected client-side inventory refresh. See the handbook.

7. **What happens to a companion's Bagception when they leave the party?** They walk
   off with the bag and its contents. Vanilla sidesteps this by giving the camp pack
   once, to the avatar. Options: leave it, move the contents to the host, or block
   the grant for characters who can depart. Raised by the one-bag-per-character
   decision of 2026-09-21; not blocking Phase 1.

4. **Can Osiris enforce the container-protection invariant** in spec sections 15 to
   17, detecting an internal container leaving Bagception and restoring it? Phase 4.
5. **Player-facing configuration**, if ever wanted, has no MCM route under the
   native-only constraint. Spec section 36's settings would need an in-game mechanism
   or optional add-on paks. Not needed for 1.0.
6. **A Script Extender companion adding weightless storage** is under consideration as
   a separate future package. Its shape, and the questions it raises, are recorded in
   [`../script-extender-edition.md`](../script-extender-edition.md). Nothing is
   decided; revisit after 1.0.

9. **The untagged containers accept anything placed by hand.** Their categories
   cannot be written as a tag expression, and `ContainerContentFilterCondition` only
   understands `Tagged()`, `IsSupply()` and boolean operators, so no filter can be
   written for them. Vanilla shields carry no tags at all. Auto-routing is unaffected;
   this is only about deliberate manual placement, and it applies equally to
   weapons, armour, jewelry, tools and valuables. Dyes turned out to be tagged and
   have a filter.

   The fix is an eject rule: catch `TemplateAddedTo` where the holder is an internal
   container, decide the item does not belong, and return it to the master bag via
   `GetDirectInventoryOwner`. Roughly one rule per container. Deferred by agreement as
   low priority — do it if it stays cheap. The risk to weigh is that a misfiring eject
   fights the player, which the present gap does not.
