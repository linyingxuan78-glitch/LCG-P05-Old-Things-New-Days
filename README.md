> **Release acceptance update, 2026-11-23:** The current Windows Godot 4.4.1 [full 23/23 suites, internal EXE and source-free startup passed](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45153165346). [Ten genuine Windows render captures and GLES3 cleanup passed](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45132214612). [Separate-process game save/restore, eight audio stream imports, installed English OS voice check and four virtual display sizes passed as *diagnostics*](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45152027895). The 1080p cloud Microsoft Basic Render Driver was slow; **not representative of actual graphics hardware**. [All four original hernandack CC0 OGGs exactly match OpenGameArt SHA-256](documentation/MUSIC_ORIGINAL_BYTES_VERIFIED_2026-11-23.md). Not yet approved for sale: real player input, physical audio/voice, real GPU performance, name clearance and publisher eligibility are outstanding. Read the [current release sign-off](documentation/RELEASE_CANDIDATE_SIGNOFF_CURRENT.md) and [unpublished store copy](documentation/STORE_PAGE_DRAFT_UNPUBLISHED.md). Older build links below are historical and should not be confused with the current Google Drive LATEST source and internal-test EXE.

# Old Things, New Days — LCG-P05

A Godot **4.4.1** first-person secondhand shop-management game with a planned **one-time-purchase, offline, no-ads/no-IAP** distribution model. Players manage 27 products across six categories and nine shared shelf spaces. This remains a **work in progress**, not a public or commercial game release.

## Latest verified milestone — 2026-11-23

**Windows INTERNAL TEST ONLY EXE is built and tested in CI.** The engine imported all resources on Windows without Godot ERROR lines, the main scene started, and **all 23 original native gameplay QA suites passed**. The strict export succeeded, 132 media files have registered provenance, and the resulting single-file EXE started from a source-free temporary Windows directory with exit 0 and no runtime ERROR.

- [Successful Windows GitHub Actions run](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45105698738)
- [Download internal Windows test artifact](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45105698738/artifacts/14787137883)
- EXE: `LCG-P05_INTERNAL_TEST_ONLY.exe` (**107,985,824 bytes**, SHA-256 `2a5846dc4f0458c902fae0e22a8d5bf72c8a674aea7cf0260f6a96fa6d73993e`)
- [Evidence and next human playtest steps](documentation/WINDOWS_INTERNAL_BUILD_AND_PLAYTEST_HANDOFF_2026-11-23.md) · [Current milestone checklist](documentation/WINDOWS_INTERNAL_VALIDATION_BACKLOG_2026-11-23.md)

**Accessibility continuation:** Historical accessibility, safety, tutorial, camera and privacy requirements were cross-checked against the original v0.16.9 project. Keyboard focus and Tab order, reversible high-contrast button themes, and a clipped scrollable 720p family guidance page were added and the **Windows 23/23 native suite, internal EXE and standalone boot passed**. See the [original-plan and official accessibility guideline audit](documentation/ACCESSIBILITY_ORIGINAL_PLAN_COMPARISON_OFFICIAL_GUIDELINES_2026-11-23.md). Real screen-reader, 200% text scalability, rebindable all-key input, and physical user testing remain open, not certified.

**New W3 visual milestone:** Real Godot 4.4.1 Windows software-rendered **720p/1080p screenshots** exposed overlapping top-right icons and an overflowing menu button; both have been fixed and visually rechecked. The [W3 visual audit](documentation/W3_AUTOMATED_VISUAL_AUDIT_2026-11-23.md) explains the remaining screenshot-harness **renderer-shutdown errors**. The independent strict Windows import/23-suite/build/standalone chain above **passed**.

**Important limitations:** Cloud screenshots and headless standalone startup are **not a human-controlled physical Windows playtest**. Real user-device graphics/color fidelity, character animations, audio playback, collisions, keyboard/mouse control, save persistence, and accessibility are **NOT YET ACCEPTED**. This build is not an authorized public or commercial release. Linux Xvfb importer reports separate Vulkan initialization errors; all such evidence remains visible.

**Scope freeze:** Retain the existing 27-item / nine-shelf / single-player game rather than endlessly growing version numbers. See [buy-once release sign-off and zero-upfront-cost plan](documentation/ONE_TIME_PURCHASE_RELEASE_FREEZE_AND_SIGNOFF_2026-11-23.md). The remaining release blockers are human-controlled device acceptance, exact media provenance and store/account compliance, not another version label.

## Source and licensing

- **One canonical updated Google Drive source ZIP:** [LCG_P05_LATEST_Godot_Project.zip](https://drive.google.com/file/d/1OVX5BUi6OOUwlErkhS0mMToqOYBfgJUE/view), built from GitHub tracked files, with a per-file SHA-256 manifest. The 2026-11-22 source has been separately retained as `LCG_P05_SOURCE_BACKUP_2026-11-22.zip` and must not be mistaken for the current work. The corresponding [single-file INTERNAL Windows test ZIP](https://drive.google.com/file/d/1DU1toHcscDcYNDzj4szfH8afHkTuE1I8/view) is also in Drive.
- **132 media files** are recorded in `licenses/USED_ASSET_PROVENANCE.csv`, including restored Kenney CC0 GLB external textures and seven byte-matched FBX-embedded PNG derivatives.
- Media rights and creator-source static checks passed, but an original-source / visual comparison for Mini Shop 2.1 palettes, additional original music archive checks, trademark/title checks and actual player UX review remain open.
- Do not commit sensitive data, private saves, tokens, or unknown-license media to this public repository.

For historical design notes and v0.16.9 descriptions, see [README_中文.md](README_中文.md). For the earlier diagnostic chronology, see [Native QA and texture recovery report](documentation/NATIVE_QA_TEXTURE_RECOVERY_AND_23_SUITES_2026-11-22.md).
