# Asset Intake & Godot Staging v0.14.5 — 2026-11-20

## Scope and result
- Nine third-party user-uploaded asset archives were reviewed. Across them: **352 `.fbx` model files** (34 of the card meshes also appear in glTF/OBJ formats; these are NOT additional independent models).
- One 672×464 pixel-art collage has unverified provenance and is not cleared for release. Keep it outside the runtime assets.
- The full originals + prior PDF + source project are preserved in separate `LCG_P05_Asset_Vault_2026-11-20.zip`, not duplicated wholesale into the Godot project.
- Seven FBX files from three suitable CC0 packs were staged and used as optional visual dressings in `_create_world()` with a guarded import helper. They have **not** been tested by running Godot; position, scale, normals, embedded materials, missing textures and collisions may all need adjustment after native engine review.

## Staged visual assets
1. Homely House Set: Bench A, Doormat, Mailbox, Package
2. Pretty park set: Bush, Flower A
3. Restaurant Bits: Crate

No change to items for sale, prices, customer algorithms, day cycle, save file path, controls or other economic behavior. All previous GLB, audio and tests are retained.

## Intentionally NOT in the live scene
- Baked Goods: food does not yet belong in the second-hand shop's item economy; possible future neighboring cafe.
- City Builder Bits: potential future city expansion; shop's exterior is too small to justify full modular road assets now.
- Halloween Bits: event-only decoration not part of the everyday interior.
- Space Bits, 3D Card Kit: mismatched to the current cozy resale-shop theme.
- Low Poly Characters Bundle: not compatible with the chosen customer look and existing character animations; do not mix styles without an art review.
- artdump.png: 2D pixel collage lacks verified license and is incompatible with current 3D visuals.

## Native acceptance gate before ship
1. Open project in Godot 4.4+ editor and wait for all FBX imports to finish.
2. Inspect output log for parse/material warnings.
3. Confirm the 7 props render with correct color/orientation/scale and no occlusion of the shop entrance.
4. Walk from spawning point to all shelves and cashier; verify no forced collision / clipping.
5. Run `run_check_windows.cmd` on Windows or `tools/run_native_acceptance.sh` on compatible systems.
6. Test save load, first purchase, stock placement, price adjustment, customer purchase, day wrap, settings and return to menu.
7. Capture Godot screenshots before approving visual quality. If any FBX import fails, prefer the author's GLTF pack instead of claiming an FBX render is correct.

## Tool scope
Blender was not installed in the build environment. No Blender conversion or rendering was performed; do not claim otherwise.
