# LCG-P05 W3 rendered frame QA and real UI fixes — 2026-11-23

## Scope and evidence

This is an **automated visual sample**, not a human playtest or production release approval.

- Engine: actual Godot **4.4.1 stable**, GitHub Actions **Windows 2022** runner.
- Renderer: GL Compatibility using **ANGLE / Microsoft Basic Render Driver** (software-based cloud GPU emulation), not a player's graphics card.
- Captures: `menu_1280x720.png`, `shop_1280x720.png`, `shop_1920x1080.png`.
- Diagnostic code: `tools/ci_capture_viewport_v0171.gd`. The script sets `qa_mode=true` before adding the playable scene, so it does not read or write players' saves.
- Workflow: [W3 Windows screenshots](../.github/workflows/windows_visual_capture_v0171.yml).
- [Initial screenshots showing overlapping UI](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45095425107).
- [Corrected icons and 720p/1080p screenshots](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096495513).
- [Latest capture attempt after layout regression updates](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952393).
- [Actual Windows native regression and gated internal build](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952298).

## Verified visual findings and repairs

1. The Windows renderer produced nonblank PNG images with the requested 1280×720 and 1920×1080 dimensions, actual store meshes, shelves, UI, tutorial, and background. These images are *not* generated illustrations.
2. Initial image-based inspection found the top-right pictograms drawn near their native **96×96** source size, overlapping BUY/PLACE/SELL/DAY state captions. Fixed icon slots to **42×42** using `TextureRect.STRETCH_SCALE` and explicit final image sizing, with separate two-line caption cells and space for the day-event caption.
3. The title screen's `QUIT TO DESKTOP` button extended outside the 570px menu panel. Replaced its visible label with **QUIT GAME** and retained a descriptive tooltip.
4. The title screen's stale `prototype v0.16.8` subtitle was replaced with **Little Cozy Games · development preview** (current internal branch is later than that historical version).
5. Reviewed 720p and 1080p post-fix screenshots: right pictogram captions are legible and do not overlap icons, the day-event line is separated below, and the compact menu quit button stays within its modal.

## QA interpretation

- Visual screenshot image generation succeeds and produces actual PNG files; the GitHub Actions visual-capture **job still fails** because the renderer emits **three ERROR lines after the successful capture marker, during process shutdown**: an unfreed GLES3 texture RID and CompressedTexture2D cleanup after RenderingServer destruction. We have **not ignored, hidden, or treated these errors as a clean engine shutdown**.
- The original strict Windows native QA chain is independent of this screenshot harness. The 23 original native gameplay suites were re-run after the visual changes and **all 23 passed**, and the complete Windows export/standalone test concluded **SUCCESS** in run [45096952298](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952298). The new `LCG-P05_INTERNAL_TEST_ONLY.exe` is 107,982,928 bytes; SHA-256 `31a7596d0a1d2fcf01895026871ec68724b72240db2903fda870eba3bf9ab02c`. [New internal EXE artifact](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952298/artifacts/14783588031), expires 2026-11-30 UTC. No playable public release has been created.
- The screenshot harness does not exercise physical keyboard/mouse controls, audio, timed animations beyond the menu transition, save persistence, NPC route/collider behavior or a human screen's color fidelity. W3 human playtests remain **NOT TESTED**.

## Next work

1. **Completed:** Gated Windows internal build and SHA-256 verified, and source-free standalone boot passed. Preserve the internal EXE in long-lived storage before GitHub Actions artifact expiration on 2026-11-30 UTC; long-term Drive backup is not confirmed.
2. Keep the visual-shutdown texture/RID errors open as a distinct developer-tool/runtime issue; investigate ownership without weakening strict Windows gameplay QA.
3. Obtain real Windows mouse/keyboard and audio results plus individual scene/camera shots for shelf interaction, catalog, and character animations.
4. Verify Mini Shop 2.1 original palette against its published original ZIP before any external release.

**Original Google Drive source ZIP untouched. No storefront, GitHub Release, public deployment, or actual player-device acceptance performed.**
