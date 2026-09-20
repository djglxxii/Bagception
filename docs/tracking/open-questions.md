# Open questions

These need an answer from research, a test, or the user before the work that depends
on them can be trusted. Move each one to the decision log or the handbook once settled.

## Blocking Phase 2, and possibly the product definition

1. **Can the native system make Bagception's contents weightless?** Spec section 2.3
   makes it a core goal and AC-11 tests it, but section 31's strategies were both
   Script Extender techniques. Investigate, in order:
   - container root-template properties, for any weight-suppressing flag;
   - `CarryCapacity` / `CarryCapacityMultiplier` boosts granted by a passive or status
     while carrying Bagception, as an approximation;
   - whether Osiris can read an item's weight or a container's total, which decides
     whether any approximation can scale with contents;
   - how existing data-only bag mods handle weight, which may be "not at all".

   The outcome is one of: a native mechanism, an approximation, or dropping the goal
   and describing Bagception as an organizer rather than a Bag of Holding.

## Blocking Phase 1

2. **Which Osiris event reports an item entering a specific container, and does it
   distinguish the Bagception root from a sub-bag?** Spec section 9 assumes
   `TemplateAddedTo`, which appears to be an Osiris event. To be answered by the probe
   build, not by assumption. Spec sections 26 and 27 both depend on the distinction.
3. **How much does vanilla auto-collect handle unaided?** The native-first classifier
   assumes it handles most categories. The probe measures this directly: potion,
   elixir, coating, modded weapon. The answer sizes Phase 3.

## Later

4. **Can Osiris enforce the container-protection invariant** in spec sections 15 to
   17, detecting an internal container leaving Bagception and restoring it? Phase 4.
5. **Player-facing configuration**, if ever wanted, has no MCM route under the
   native-only constraint. Spec section 36's settings would need an in-game mechanism
   or optional add-on paks. Not needed for 1.0.
