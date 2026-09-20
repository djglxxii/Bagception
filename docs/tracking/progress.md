# Progress

## Phase 0 — Scaffold

- [x] Create the repository layout, modelled on the sibling BG3 mod projects in `C:\src`.
- [x] Author module identity with a freshly generated UUID at version 1.0.0.0.
- [x] Add the Script Extender manifest and a server bootstrap load probe.
- [x] Add build, package, deploy, and validation tooling under `tools/`.
- [x] Verify the toolchain: paths validate, Lua compiles, `Build-Pak.ps1` produces a package with the expected contents.
- [ ] Deploy the scaffold once and confirm the extender prints the load line in game.

## Phase 1 — Proof of concept

- [ ] Confirm which Script Extender event reliably reports an item entering a specific container.
- [ ] Author the master bag and three container root templates.
- [ ] Author the `BAGCEPTION_MASTER` and `BAGCEPTION_INTERNAL` tags.
- [ ] Implement ingress handling, classification, routing, and the re-entrancy guard.
- [ ] Verify longsword, potion, and unknown item routing in game.

Later phases are listed in [`../implementation-plan.md`](../implementation-plan.md).
Acceptance criteria AC-01 through AC-24 from `spec.md` section 43 become a checklist
here once Phase 1 lands.
