# LCG-P05 — Windows internal build and playtest handoff (2026-11-23)

**Status: Windows INTERNAL TEST ONLY executable BUILT and smoke-validated. NOT a public/commercial release.**

## Verified artifacts

- GitHub Actions completed successfully: https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703
- Windows EXE artifact (GitHub Actions, expires 2026-11-30 UTC): https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703/artifacts/14780550862
- Standalone startup test evidence: https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703/artifacts/14780631469
- File inside ZIP: `LCG-P05_INTERNAL_TEST_ONLY.exe` (107,982,544 bytes, Windows PE MZ header, embedded project pack).
- **EXE SHA-256**: `cf2a15095d11cc7475a38f57c9d34ecf282f16db5c610fa322edefa2b21c0a8c`
- Artifact ZIP SHA-256: `dd4b7fb73551495287855d3aef866227f74ea6bcd6d3b104aef6791805ef0301`
- Build generated with **Godot 4.4.1.stable.official.49a5bc7b6** on GitHub Actions Windows 2022 runner.

## Completed stages

| Gate | Actual evidence | Result |
| --- | --- | --- |
| Godot editor first import (Windows) | Native Godot command exits 0, 0 engine error lines | PASS |
| Main scene startup | Godot command exits 0, 0 engine error lines | PASS |
| All 23 native GDScript QA suites | 23/23 explicit correct PASS markers, exit 0, 0 errors each | PASS |
| Source/creator-rights static checks | 132 media matched 132 provenance rows; CC0 sources and 4 OGG music tracks listed | PASS for existing static gates, not legal release clearance |
| FBX derived textures | 7 PNG bytes match precisely their parent source FBX embedded PNGs; provenance trace present | PASS |
| Export preset parser | Godot `ConfigFile` reads `preset.0` / `preset.0.options` with the Windows Desktop platform | PASS |
| Windows internal export | `tools/build_windows_release.ps1` completes; output is a single embedded-PCK Windows PE executable | PASS |
| Source-free standalone startup | EXE copied into a separate directory with no source/models/loose PCK; `--headless --audio-driver Dummy --quit-after 60`, exit 0, no runtime ERROR lines | PASS |
| Windows audio and onscreen interactive GUI | **Not tested** in native human-controlled session | NOT TESTED |
| Public/commercial copyright, UX and brand review | Final release gates outstanding | NOT APPROVED |

The existing Linux headless Xvfb editor import still emits 4 Vulkan initialization errors in that environment, **but the independent Windows import above passed cleanly**. Do not erase or misrepresent the Linux diagnostic logs; platform-specific conditions differ.

## How to try the internal Windows EXE

1. Download `LCG-P05_INTERNAL_TEST_ONLY` artifact from the successful run and extract the ZIP.
2. On a Windows PC, start `LCG-P05_INTERNAL_TEST_ONLY.exe`; no Godot editor should be needed.
3. This file is an **unsigned internal test build**. Do not distribute to a public storefront, advertise as released, or bypass OS security warnings. If Windows displays a warning, review the file origin and checksum rather than turning off protection.
4. Record whether a visible window appears, whether 3D meshes/texture colors look correct and whether keyboard/mouse, audio and saving behave correctly. Automated headless startup is not a graphical test.

## Next milestone W3: real, interactive Windows acceptance

All entries below are **NOT TESTED** until someone actually runs the EXE with screen/audio/input and reports observable results:

- [ ] Run on a Windows laptop/desktop; test 1280×720 and 1920×1080. Capture main-menu and gameplay screenshots.
- [ ] Verify intro logo timing (1.8 s), reduce-motion option, and return/exit actions.
- [ ] Inspect six customer 3D designs and animations (idle / walking / interaction) and check clipping/collision at doors, desk, shelves and other props.
- [ ] Inspect all 27 product thumbnails, 6 product categories and 9 shelves; specifically compare the Mini Shop 2.1 colormap against the original official source palette (current one is a Kenney compatible substitute).
- [ ] Walk with keyboard and mouse; test three mouse sensitivity levels, ESC and menu focus / keyboard-only navigation.
- [ ] Hear audio on actual hardware: BGM, clicks, stocking, sales, footsteps; check volume controls. Silent CI test does not validate audio playback.
- [ ] Test sales, purchases, bargaining, day-close confirmation and clear pricing feedback.
- [ ] Create and reopen normal saves; test old-save migration, valid `.pending` / `.bak` recovery, invalid save rejection, and Alt+F4 shutdown without false success messages.
- [ ] Test close/reopen on a normal user account and repeat in a fresh account or secondary Windows machine where possible.
- [ ] Verify readability, contrast, icon comprehension, non-flashing visual comfort, and actual usability with age-appropriate testers.

Record each as **PASS / FAIL / NOT TESTED** with Windows version, hardware, test date, reproducible steps, screenshot/clip or log path, and version/executable SHA. Do not infer PASS from the automated suite.

## Next milestone W4: public release gates (still outstanding)

- Original archive / byte-level and **visual** confirmation for Mini Shop 2.1 source palette; current compatibility palette is not verified equivalent.
- Original-source evidence for the 4 hernandack CC0 audio clips; existing static paperwork does not prove original WAV/OGG archive byte equivalence.
- Manual visual and accessibility review; appropriate age-rating, privacy and game-store compliance checks, final legal third-party credits and trademark/title checks.
- Windows and packaged-executable UX verification **in real interactive use** before considering any release.

**No GitHub Release, itch.io upload, storefront listing, account registration, or public distribution action was performed.** Original Google Drive `LCG_P05_LATEST_Godot_Project.zip` v0.16.9 remains unchanged.
