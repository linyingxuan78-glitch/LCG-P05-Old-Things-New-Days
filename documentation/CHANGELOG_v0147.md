# LCG-P05 — v0.14.7 development delivery (2026-11-20)

**STATUS: GODOT SOURCE UPDATE / STATIC CHECKED; NOT NATIVE ENGINE VALIDATED. NOT A WINDOWS EXE.**

- Continued exclusively from Godot v0.14.6, no HTML branch, no new game type.
- Reviewed ten newly uploaded archives and preserved their original license files. `kenney_mini-shop_2.1.zip` and `kenney_furniture-kit.zip` both explicitly claim Kenney CC0; `kenney_impact-sounds.zip` includes CC0. Other packs are retained in a separately archived original upload vault, not merged without gameplay need.
- Staged six GLB props with shop-specific roles: clothing rack, mannequin, shopping basket, accessories shelf, hand truck, coat stand. Models remain non-colliding; inspect overlap and scale in Godot.
- Added two alternating wooden footsteps triggered by real first-person floor movement, shop entry bell when a visitor spawns, and stocking sound when placing an item. All respect pre-existing SFX and master volumes. The nine-product economics and existing player save file path were not changed.
- Added `tests/qa_v0147_assets_and_audio.gd` to Linux and Windows acceptance runners. Updated Windows optional engine download from the previously unsupported `4.7.1` reference to the known Godot `4.4.1` stable editor branch. Engine download itself remains untested in this container.
- New paths, hashes and source archives are in `documentation/NEW_ASSETS_v0147.csv`.
- The `pixel-pack`, `mini-dungeon`, `retro`, `space UI`, `toon characters` and flag resources intentionally do not contaminate the unified 3D Cozy Cartoon art direction.
- No claim of live, visual, interactive, Windows or Godot runtime acceptance. Real testing remains a release gate.
