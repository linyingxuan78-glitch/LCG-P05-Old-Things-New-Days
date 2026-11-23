# LCG-P05 — Current release gates (2026-11-23)

**Windows internal EXE: BUILT and source-free smoke-tested. Public release: NOT APPROVED.**

| Gate | Evidence | Latest result |
| --- | --- | --- |
| Godot 4.4.1 Windows editor resource import | Original Windows Godot engine, exit 0, zero engine ERROR | **PASS** |
| Main scene / native gameplay automation | 23/23 actual Godot GDScript suites, correct markers, exit 0 | **PASS** |
| Asset/provenance rights static gate | 132/132 media records, seven FBX-derived PNG exact source-byte matches | **PASS for recorded static checks** |
| Embedded-PCK Windows EXE export | Strict build PowerShell, Windows PE MZ header, 107,982,544-byte EXE | **PASS** |
| EXE independently launching without source directory | Windows CI isolated directory, no loose PCK, `--headless --quit-after 60`, exit 0 and no ERROR | **PASS** |
| Actual Windows 720p/1080p scene visuals and animation | Physical screen and game controls, screenshots needed | **NOT TESTED** |
| Real sound, mouse/keyboard, collisions and player experience | Hardware and people needed | **NOT TESTED** |
| Save persistence and restart on a normal user PC | Manual steps across full sessions | **NOT TESTED** |
| Palette equivalence to Mini Shop 2.1 official source | Exact original archive or visual side-by-side check | **NOT VERIFIED** |
| Four CC0 audio original archives, title/brand, age/privacy and marketplace gates | External source/UX/legal/platform review | **NOT VERIFIED / NOT APPROVED** |
| Public game release | Requires all manual and legal gates above | **BLOCKED — no public publication** |

- [Successful Windows internal test build and QA](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703)
- [Latest Windows EXE artifact](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45088442703/artifacts/14780550862)
- [Full Windows handoff and W3/W4 checklist](WINDOWS_INTERNAL_BUILD_AND_PLAYTEST_HANDOFF_2026-11-23.md)

---

## Historical v0.16.8 audit (superseded by actual 2026-11-23 engine/CI results)

# LCG-P05 v0.16.8 — Release gates and evidence

| Gate | Required evidence | Status |
| --- | --- | --- |
| Resource integrity | Local SHA256 + archive CRC, documented sources; generated optional credits | **PASS offline**, 115 files |
| Godot syntax & import | Official Godot 4.4.1 `--headless --editor --import` log | **BLOCKED** — no engine |
| Native gameplay | `--headless --quit-after` and 23 actual QA scripts, gameplay log | **BLOCKED** — no engine |
| Real interface | Player walkthrough and screenshots of desk / icons at 720p, 1080p | **NOT TESTED** |
| Character animations | Actual frame-by-frame walk/pickup transition, footwear/prop intersections | **NOT TESTED** |
| Keyboard / mouse accessibility | Two independent keyboard navigation checks; mouse sensitivity; ESC escape | **NOT TESTED** |
| Cognitive accessibility | Observe people who cannot read English using the purchase icons and tutorial | **NOT TESTED** |
| Flash / photophobia | Analyze actual recorded gameplay for flashes and excessive brightness; involve suitable expertise if needed | **NOT TESTED** |
| Privacy / minors | Verify local save deletion, no unexpected network traffic, review age/region/platform policies | **NOT TESTED** |
| Windows self-contained delivery | One EXE + embedded resource PCK; clean-device startup / licensed notice | **NOT BUILT** |
| Store submission | Platform guidelines, age rating, rights check, marketing screenshots | **NOT STARTED** |

## What is actually completed in this iteration
- 27 product silhouette cards drawn from previously licensed low-poly models.
- 3 original action icons paired with English labels, not communicated by colour alone.
- Closing-day confirmation to avoid accidental loss of an in-game day.
- Optional cycling of 3 mouse speed profiles in local settings.
- 23rd Godot QA test (exit and studio intro) added to Linux and Windows acceptance runners.
- 115/115 media asset hash/provenance integrity confirmed using Python.

## Required native process
Install official Godot 4.4.x editor and run the **native** engine checks in `tools/`. Do not substitute the four dummy runner simulations. For first release, manual accessibility and photosensitivity evaluation must use real Godot-rendered frames.

Technical references: https://docs.godotengine.org/en/4.4/tutorials/editor/command_line_tutorial.html ; https://gameaccessibilityguidelines.com/basic/ ; https://docs.godotengine.org/en/4.4/classes/class_button.html .

## Additional v0.16.4 requirement

Godot-native QA must verify .pending recovery and primary/backup recovery using **isolated test paths**; test real power-loss scenarios separately on a disposable test machine. Confirm overwrite behavior on Windows NTFS.

## Additional v0.16.4 rights / standalone packaging gate

- Source archive is NOT the game's launcher. No verified Windows .exe exists in this release. The 115 media files are stored under `assets/` and therefore do not depend on archived original ZIPs, but the Godot developer project is required until export.
- Credits regenerate from the provenance CSV via `python tools/sync_release_notices.py --sync`. Engine MIT text and copyright notices are included and displayed on demand. The strict audit refuses unregistered assets, missing authors/licenses, or mismatched SHA256.
- To build a one-file Windows EXE, a Windows developer may run `DEV_BUILD_WINDOWS_RELEASE.cmd` after installing the official Godot 4.4.1 standard editor and matching export templates; the script requires all 20 native Godot QA suites before attempting export.
- **UNRESOLVED:** no Godot executable here; Godot third-party bundled dependency `COPYRIGHT.txt` for the final export version not yet packed; IP/trademark review for studio mark and third-party source verification for entries with incomplete original archive members remains outstanding. No signed Windows build or clean PC validation.

## v0.16.5 rights settlement (22 November 2026)

- 69 exact third-party archive-member file hashes independently matched against originals supplied in this project context; 26 PNG product previews connected to their verified Kenney model origins. See `ORIGINAL_SOURCE_EVIDENCE_v0165.json`.
- 14 original Kenney `License.txt` copies preserved in `licenses/original_archive_snapshots/` for the used archive set. Music source page (hernandack CC0) independently checked, but original exact audio ZIP/bytes not matched.
- 2 internal logo images require artwork/mark review. Removed their visual loading in `scripts/shop.gd` and added `assets/branding/*` to export exclusion.
- Godot 4.4's supported `Engine.get_license_info()`/`get_copyright_info()` now provide engine-binary-specific licence text in optional Credits; exact-version snapshot generation is wired into `tools/build_windows_release.ps1`. It remains unexecuted until actual engine is available.
- Public release must pass `python tools/check_public_release_gate_v0165.py`; it **currently fails on purpose**, and this is not a legal clearance tool. Internal developer export is explicitly named `INTERNAL_TEST_ONLY` and retains usual runtime QA requirements.
- Original IP review from 16 November 2026 referred to a separate older **standalone HTML prototype**, not proof that current Godot code has passed native tests.

## v0.16.8 new Windows quit gate
On a physical Windows machine: create an internal test save, run the game, close with the window X and Alt+F4, then reopen and verify the same cash/stock/day; simulate unwritable save storage and confirm the application remains open with a clear warning. Also view the 1.8-second splash at 720p/1080p and check reduced-motion skip. Not executed here.
