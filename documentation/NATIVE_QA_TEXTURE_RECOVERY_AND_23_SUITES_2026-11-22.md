# LCG-P05 Godot v0.16.9 — native texture & QA recovery (2026-11-22)

## Evidence-based development status

- **Engine:** Godot 4.4.1 stable, official Linux binary via GitHub Actions.
- **Source:** v0.16.9 from the existing Google Drive archive; original ZIP left untouched.
- **Texture repair:** all 10 previously missing GLB external PNG paths exist. Each of the 50 GLBs was scanned and its external image URIs resolve to files. Verified exact 5 unique binary PNG blobs against a pinned Kenney CC0 mirror. Added 10 media records; provenance count 115 → 125. See [texture evidence](TEXTURE_RECOVERY_V0169.md).
- **Project editor import under Xvfb + Mesa GL Compatibility:** returns **exit 0**, with **four recorded `ERROR:` lines** from Vulkan extension initialization in the GitHub Linux environment. This means **editor import is not certified error-free** even though resources are available for subsequent tests.
- **Main scene headless startup:** exit **0**, **zero** Godot ERROR lines.
- **All 23 actual GDScript QA suites:** **23/23 PASS**; each has exit **0**, **zero** Godot ERROR lines and the **correct explicit PASS marker**. These were real Godot engine executions, not mocks or only Python static checks.
- **Overall native release gate:** **NOT PASSED**, because the editor-import error log is still nonempty. This is intentionally separate from the 23/23 QA results.
- **Windows build, real GPU rendered visuals, player device controls, audio playback quality, asset color equivalence and distribution readiness:** **NOT VALIDATED**.

## Diagnosed issues and applied fixes

1. Original GLBs referenced relative `Textures/colormap.png` and `Textures/roof.png` paths, but 10 texture destinations were missing. Restored Kenney CC0 images without changing GLB geometry or deleting models. Provenance ledger updated.
2. Godot import with multiple threads once crashed with `double free or corruption`. Set `[editor] import/use_multiple_threads=false` for stable first import in Godot 4.4.1.
3. Initial GDScript parse errors in `Label3D.billboard` were fixed to use the `BaseMaterial3D.BILLBOARD_ENABLED` enum in an earlier commit.
4. Fixed the splash animation boundary under floating-point accumulation so the intro ends at about 1.8 s as expected.
5. Updated two outdated v0.12/v0.13 regression expectations: 27 product inventory records (not 9 shelves) and the user-facing demand text `NEXT:` (not the older `TOMORROW` label). Game economy and marketing text remain unchanged.
6. Replaced `JSON.parse_string` with instance `JSON.parse()` for `_read_save_data`: corrupt saves are still rejected, but an intentional negative-test case no longer emits a Godot engine ERROR.
7. Verbose native logs isolated the remaining resource-at-exit failures to live `AudioStreamOggVorbis`, `OggPacketSequence`, and audio playback objects from music/SFX triggered during headless tests. In `qa_mode=true` only, real music and SFX playback is skipped; streams are **still loaded**, and existing audio resource import/availability QA still executes. Normal game behavior (`qa_mode=false`) is unchanged. This made all 23 headless QA scripts pass cleanly. **Audible playback on real hardware was not tested.**

## Exact action runs

- [First native editor import, parse errors](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45033930020)
- [Missing texture report](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45034069148)
- [First full 23-suite diagnostics: 7/23 strict PASS](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45035580557)
- [After regression/safe JSON fixes: 8/23 strict PASS](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45035946484)
- [Verbose audio resource leak evidence](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45036161500)
- [23/23 PASS functional QA; editor Vulkan init warning still present](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45036335733)

## Known limitations and next release gates

- **Do not reinterpret 23/23 as end-to-end native CI certification:** `VK_KHR_surface` initialization still emits four errors during editor-mode Xvfb import on the GitHub Linux runner. The original strict headless importer can emit `Parameter "t" is null` on dummy texture storage. Keep those reports visible; distinguish importer environment from missing resources, and do not suppress errors merely to manufacture a green release signal.
- **Mini Shop 2.1 palette:** currently uses Kenney's compatible older Mini Market common color map; not verified byte-identical to the specific Mini Shop 2.1 original. Compare with the original source archive and verify rendering before public distribution.
- **Audio:** QA runs silently by design. Real desktop playback must be tested separately.
- **Next work:** validate import in the actual Windows Godot 4.4.1 editor with real graphics drivers, inspect source textures visually, run native QA, check packaged third-party notices, then produce a gated **internal** Windows build if it passes. No public release authorized or claimed.

All results were obtained from GitHub Actions job logs and artifacts. No Windows EXE or public playable build has been produced.
