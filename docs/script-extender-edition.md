# Script Extender edition (future, under consideration)

The base mod is native-only and will stay that way. Separately, the user wants to keep
open the option of a **Script Extender companion that adds weightless storage** — the
feature dropped from 1.0 because the native system cannot do it.

This document records the intent and, more importantly, the constraints it places on
the base mod now. Nothing here is committed work.

## Why it is a separate package

- mod.io and the in-game mod manager are the base mod's release channel, and they do
  not carry Script Extender mods. The companion would ship on Nexus.
- The base mod must never require it, detect-or-fail on it, or degrade without it.
- Keeping them separate is what lets the base stay a standard Larian mod.

## Two possible shapes

**A. Add-on that depends on the base.** A small Script Extender pak containing no
content of its own. It finds Bagception's containers at runtime and applies the
extraplanar weight behaviour to them.

- No content duplication, one source of truth for templates and categories.
- Requires the base mod's templates and tags to be a stable public contract: renaming
  a tag or reissuing a template UUID silently breaks the companion.
- Load order matters; the companion must tolerate the base being absent or older.

**B. Standalone Script Extender edition.** A separate mod duplicating the base content
plus the weight behaviour.

- No cross-mod contract, no load-order concern.
- Two copies of every template and category to keep in sync, two mod identities, and
  players must not install both. Worse over time.

Preference is **A**, unless the runtime work proves it needs to own the templates.

## Constraints this places on 1.0

These are cheap now and are the whole reason to record this before Phase 1:

- **Tag every container, master and internal, with stable mod-owned tags.** This is
  already the plan for the sorter, which locates containers via
  `GetItemByTagInInventory` rather than tracked UUIDs. Treat those tag names as a
  published contract once released, not an internal detail.
- **Never reissue a container template UUID** after release.
- **Do not bake weight assumptions anywhere**, in either direction. The base must not
  assume contents are heavy, and must not leave half-built weight logic lying around.
- **Keep the container set data-driven**, so a companion can enumerate it rather than
  hard-coding seventeen names.

## Open questions, for if and when this is picked up

- What is the actual extraplanar technique? `mod-references.md` attributes it to
  Containers Extended, which is public on GitHub. Study it; do not copy it.
- Does the weight behaviour need to be applied to the master bag only, or to every
  internal container? This is the old spec section 31 Strategy A versus B question,
  which survives into the companion unchanged.
- How does the companion discover Bagception's containers across saves, and what
  happens to a save where the companion is later removed?
- Does adding the Nexus release path for one package pull the whole project's release
  tooling back toward the sibling Script Extender projects, or can it stay a small
  separate concern?

## Status

Under consideration. Not scheduled, not scoped, no identity reserved. Revisit after
1.0 ships.
