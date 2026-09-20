# Decision log

## 2026-09-20: Repository setup

- Model this repository on the sibling BG3 mod projects in `C:\src`, using
  `MoreHirelings` for the documentation and tracking layout and the Script Extender
  projects (`RandomizedDisguiseSelf`, `PlanarEmissary`) for the source layout and
  tooling.
- Hand-author the source tree and package with Norbyte's LSLib Divine rather than
  using Larian's Toolkit. `spec.md` requires the Script Extender, so the Toolkit and
  mod.io publishing path that `MoreHirelings` uses does not apply here. The intended
  release channel is Nexus Mods.
- Generate a fresh module UUID `f2470481-03f2-4439-83d5-68f2e26ae076` and start at
  version 1.0.0.0.
- Put server Lua under `Lua/Server/` per house convention rather than the flat
  `Lua/Bagception/` sketch in spec section 37. The module names in that sketch
  (Constants, Containers, Classifier, Sorter, WeightManager, IntegrityManager,
  Recovery, Logging) are kept.
- Declare `RequiredVersion: 31` in the Script Extender config, matching the extender
  majors installed locally. Revisit before release if only older APIs are used.
- Compile localization to `.loca` during packaging instead of committing a compiled
  artifact, and ship both the `.xml` and the `.loca` in the package.
- Copy the existing LSLib ExportTool from `C:\src\RandomizedDisguiseSelf` into ignored
  `tools/external/` rather than re-downloading it.
- Keep `spec.md` and `mod-references.md` at the repository root, matching how the
  sibling projects keep their design documents.
