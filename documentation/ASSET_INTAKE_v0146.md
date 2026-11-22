# v0.14.6 — Second batch asset intake (2026-11-20)

## Provenance / safety
- User uploaded ten additional archives. Nine are Kenney packs with their original `License.txt` explicitly granting **CC0**. The `art.zip` contains images/audio/font but **no license file** and is quarantined **outside** the Godot runtime. Do not use its assets until provenance and commercial rights have been verified.
- Exact archive SHA-256, file format breakdown and sizes appear in `NEW_UPLOADS_v0146.csv`.
- Six curated files from five Kenney packages were imported into `assets/third_party_kenney`: 5 valid glTF 2.0 `.glb` models and one PNG cursor. The six source file hashes appear in `NEW_ASSETS_v0146.csv`.
- Original license files are preserved in `licenses/Kenney_*_CC0.txt` for each of the nine new Kenney packages.

## Changes included
- Visual-only cash register on the existing cashier counter; two sidewalk planters; boxes and a crate near the shop's rear wall; decorative storefront columns. These have no interaction, cost, collision or sale mechanics.
- Sets a cartoon mouse cursor for menus when mouse is not captured. Existing input and keyboard shortcuts remain unchanged.
- Nine product definitions, costs, supply, demand, sales logic, customer purchase logic and save path were not deliberately altered.
- Do not import incompatible 2D pixel assets from RPG Urban Pack or unlicensed art.zip into the 3D scene; all omitted models remain in the separate raw backup.

## Unverified until native Godot import and game QA
- **Godot 4.4+ native engine has NOT been executed here.** Resource existence, GLB/PNG signature, ZIP CRC and code-level static checks do not prove successful import, correct appearance, collision behavior, UI click handling or performance.
- Inspect cursor hotspot and ensure no custom cursor is shown while player camera is captured; verify alternative cursor with system high-DPI settings.
- Inspect GLB scale and transparency, entrance width and customer path after rendering. Remove any decoration causing clipping or misleading non-interactable shop objects.
- Run every `tests/qa_*.gd` through the included acceptance script in the real Godot editor; verify first purchase, placement, price, sale, persistence, new game and complete day cycle.
- Until the checks pass: **INTERNAL PROTOTYPE — NOT RELEASE-READY.**
