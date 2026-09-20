# Open questions

These need an answer from research, a test, or the user before the work that depends
on them can be trusted. Move each one to the decision log or the handbook once settled.

## Blocking Phase 1

1. Which Script Extender event reliably reports an item entering a specific container,
   and does it distinguish a drag into the Bagception root from a drag into a sub-bag?
   `spec.md` section 9 assumes `TemplateAddedTo`; confirm it against the current
   extender before building the pipeline on it.
2. Can the master bag and the internal containers be built from vanilla container root
   templates, or does each need a hand-authored template with its own icon and visual?

## Blocking Phase 2

3. Does weightless ("extraplanar") storage propagate through a nested container, or
   must every internal container carry the behaviour itself? `spec.md` section 31
   lists this as Strategy A versus Strategy B and expects it to be settled by testing.

## Product decisions not yet made

4. How much classification can be delegated to BG3's native auto-sort tags rather than
   a Lua classifier? `mod-references.md` argues the hybrid is worth investigating
   before writing a large classifier, which would change the shape of Phase 3.
5. Flat or two-level container hierarchy in the UI? `spec.md` section 5 allows either
   and says the classifier must not depend on the choice.
6. Release channel and name confirmation for the Nexus listing, and whether MCM
   configuration is wanted after 1.0.
