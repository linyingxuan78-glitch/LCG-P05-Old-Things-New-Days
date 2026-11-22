# Godot native QA — first real run (2026-11-22)

Project: LCG-P05 / **Old Things, New Days**, original source archive v0.16.9.
Engine actually installed and invoked: **Godot 4.4.1.stable.official.49a5bc7b6** on GitHub Actions Ubuntu 24.04.

## Verified successes

- Source ZIP successfully reconstructed from 24 staged Git objects and hash-checked against SHA-256 `c4ebf7a05b1e573b6e4af981c0b914ffb27272207f46811211e301c746752d07`, then committed to `main`.
- Five Python offline preflight/provenance/CI-runner checks passed.
- Native Godot 4.4.1 was installed and ran the **editor import** command.
- First native import exposed two real parse errors: `scripts/shop.gd` lines 613 and 2912 assigned `true` to `Label3D.billboard`, which expects a `BaseMaterial3D.BillboardMode`. Both were fixed to `BaseMaterial3D.BILLBOARD_ENABLED` in commit `d960e629af491c4b415cb64515645036c8e8b841`. These parse errors were absent from the second import log.

## Current blockers (second native run)

- **Import failed**: `editor_import.log` contains 75 logged Godot `ERROR:` lines.
- Of these, **18** are missing external PNG file accesses across **10 unique resource paths**.
- The remaining **57** are `Parameter "t" is null` from Godot's headless dummy texture storage during 3D scene import. Do not assume they all share the same underlying cause as the missing PNGs.

The ten unique missing texture paths:

1. `res://assets/third_party_kenney/building/Textures/colormap.png`
2. `res://assets/third_party_kenney/city_suburban/Textures/colormap.png`
3. `res://assets/third_party_kenney/factory/Textures/colormap.png`
4. `res://assets/third_party_kenney/mini_arcade/Textures/colormap.png`
5. `res://assets/third_party_kenney/prototype/Textures/colormap.png`
6. `res://assets/expanded_v0153/Textures/colormap.png`
7. `res://assets/curated_v0147/mini_shop/Textures/colormap.png`
8. `res://assets/models/Textures/colormap.png`
9. `res://assets/selected_v015/characters/Textures/colormap.png`
10. `res://assets/selected_v015/urban/Textures/roof.png`

## Meaning of the results

- Five offline checks: **PASS**.
- Godot 4.4.1 installation/version check: **PASS**.
- Godot editor resource import: **FAIL**.
- Main scene startup: **NOT REACHED**.
- 23 Godot native QA scripts: **NOT RUN**.
- Windows EXE export, visual/playability testing: **NOT RUN**.
- The project is **not yet validated as a playable game**.

## Evidence

- Initial native run: https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45033930020
- Second native run: https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45034069148
- Both runs provide downloadable `lcg-p05-native-qa-logs` artifacts including `native_run_logs/editor_import.log` and `native_run_logs/RESULT.txt`.

## Correct next actions

1. Restore or repair original **licensed source textures**, ideally from the original asset archives. Recheck each linked GLB and any relative URI; update `licenses/USED_ASSET_PROVENANCE.csv` if adding new shipped media.
2. Re-run the exact native CI. Distinguish missing-image errors from limitations of the headless dummy renderer; do **not** simply suppress ERROR lines to obtain a false PASS.
3. Only after a clean editor import, run the main scene and all 23 native QA scripts. Fix actual failures based on logs, then consider a gated internal Windows export.

The original Google Drive source ZIP was not modified by this GitHub work.
