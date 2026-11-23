# Old Things, New Days — LCG-P05

A Godot **4.4.1** first-person secondhand shop-management prototype. Players manage 27 products across six categories and nine shared shelf spaces. This remains a **work in progress**, not a public or commercial game release.

## Latest verified milestone — 2026-11-23

**Windows INTERNAL TEST ONLY EXE is built and tested in CI.** The engine imported all resources on Windows without Godot ERROR lines, the main scene started, and **all 23 original native gameplay QA suites passed**. The strict export succeeded, 132 media files have registered provenance, and the resulting single-file EXE started from a source-free temporary Windows directory with exit 0 and no runtime ERROR.

- [Successful Windows GitHub Actions run](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952298)
- [Download internal Windows test artifact](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45096952298/artifacts/14783588031)
- EXE: `LCG-P05_INTERNAL_TEST_ONLY.exe` (**107,982,928 bytes**, SHA-256 `31a7596d0a1d2fcf01895026871ec68724b72240db2903fda870eba3bf9ab02c`)
- [Evidence and next human playtest steps](documentation/WINDOWS_INTERNAL_BUILD_AND_PLAYTEST_HANDOFF_2026-11-23.md) · [Current milestone checklist](documentation/WINDOWS_INTERNAL_VALIDATION_BACKLOG_2026-11-23.md)

**New W3 visual milestone:** Real Godot 4.4.1 Windows software-rendered **720p/1080p screenshots** exposed overlapping top-right icons and an overflowing menu button; both have been fixed and visually rechecked. The [W3 visual audit](documentation/W3_AUTOMATED_VISUAL_AUDIT_2026-11-23.md) explains the remaining screenshot-harness **renderer-shutdown errors**. The independent strict Windows import/23-suite/build/standalone chain above **passed**.

**Important limitations:** Cloud screenshots and headless standalone startup are **not a human-controlled physical Windows playtest**. Real user-device graphics/color fidelity, character animations, audio playback, collisions, keyboard/mouse control, save persistence, and accessibility are **NOT YET ACCEPTED**. This build is not an authorized public or commercial release. Linux Xvfb importer reports separate Vulkan initialization errors; all such evidence remains visible.

## Source and licensing

- The original Google Drive `LCG_P05_LATEST_Godot_Project.zip` v0.16.9 archive is unchanged (SHA-256 `c4ebf7a05b1e573b6e4af981c0b914ffb27272207f46811211e301c746752d07`). Current GitHub code includes later repairs and QA tooling.
- **132 media files** are recorded in `licenses/USED_ASSET_PROVENANCE.csv`, including restored Kenney CC0 GLB external textures and seven byte-matched FBX-embedded PNG derivatives.
- Media rights and creator-source static checks passed, but an original-source / visual comparison for Mini Shop 2.1 palettes, additional original music archive checks, trademark/title checks and actual player UX review remain open.
- Do not commit sensitive data, private saves, tokens, or unknown-license media to this public repository.

For historical design notes and v0.16.9 descriptions, see [README_中文.md](README_中文.md). For the earlier diagnostic chronology, see [Native QA and texture recovery report](documentation/NATIVE_QA_TEXTURE_RECOVERY_AND_23_SUITES_2026-11-22.md).
