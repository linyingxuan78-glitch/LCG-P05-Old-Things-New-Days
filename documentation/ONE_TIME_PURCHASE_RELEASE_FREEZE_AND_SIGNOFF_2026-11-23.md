# LCG-P05 — one-time-purchase release freeze and sign-off
2026-11-23 · **DEVELOPMENT FREEZE / NOT YET APPROVED FOR PUBLIC SALE**

## The original product, kept intact
- A **single-player, offline, buy-once Windows game**. No in-game ads, rewarded videos, paywalls, subscriptions, DLC assumptions, account/login, social chat, or telemetry added by this project.
- Player purchases the full game **once from the distribution platform**, not from an in-game checkout. No platform/payment plugin is necessary inside the Godot executable for a simple DRM-free downloadable build.
- Current gameplay scope is frozen: first-person resale store, 27 products in six categories, nine physical shelves, supply and pricing, six customer appearances/animations, bargaining/trade-ins, daily reports, saves and recovery, optional community finale, adjustable audio and accessibility settings.
- **Avoid further version numbers for cosmetic updates.** This is one canonical game; fix only proven P0/P1 defects. Existing history remains archived. Git commit + CI and evidence replace arbitrary version jumps.
- Do not ship the developer SOURCE archive to paying players. Player distribution would contain a final reviewed executable and required third-party notices; exclude diagnostic and test files.

## Which files are actually current (not an invented release)
- Canonical Google Drive source file: `LCG_P05_LATEST_Godot_Project.zip`, linked from the current Drive folder; **357 Git-tracked files, 132 media assets, 23 native QA suites**, with `SOURCE_INTEGRITY_MANIFEST.json` and SHA-256 for every file. Git HEAD when source snapshot was created: `259790a64b0a5ae5056858bfdee4f78186e66b9f`. Subsequent documentation-only edits can be resynced without changing gameplay binary.
- A distinct **older** 2026-11-22 source archive remains in Drive as a backup; never overwrite the backup for cosmetic churn.
- The latest Windows **INTERNAL TEST ONLY** build passed true Windows Godot 4.4.1 native import, **23/23 QA**, internal EXE export and **source-free headless startup** in [run 45105698738](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45105698738). Internal EXE length `107985824` bytes and SHA-256 `2a5846dc4f0458c902fae0e22a8d5bf72c8a674aea7cf0260f6a96fa6d73993e`. This is **not** a player-hardware test or retailer-approved build.
- Last consistent visual evidence: Windows software-rendered 720p/1080p title, controls, accessibility, healthy-play, privacy, and shop. The **visual harness reports a GLES3 cleanup error on shutdown despite saving all screenshots**; keep this issue open only as a dev-tool problem until reproduced in normal gameplay.

## ZERO-UPFRONT-COST development plan
| Priority | Gate | Acceptance evidence | Status |
| --- | --- | --- | --- |
| Done | Keep repaired game features in same complete ZIP, verify raw Drive bytes | Source ZIP + manifest + post-upload download SHA-256 | **PASS** |
| Done | Import assets, execute 23/23 Godot 4.4.1 native suites | Windows CI successful 45105698738 | **PASS** |
| Done | One-file internal EXE, headless smoke in a clean source-free folder | CI export and startup logs | **PASS** |
| P0 | Human-controlled Windows keyboard/mouse path: New Game → supply → stock → price → customer transaction → close day → save → quit → reopen | Recorded test results, real screen captures, UI/audible issues documented | **NOT TESTED** |
| P0 | Verify camera, six NPC animation appearances and no shelf collisions | Real Windows screen captures with steps/device GPU noted | **NOT TESTED** |
| P0 | Hear all four music tracks and SFX and test volume/mute | Physical Windows audio device/listener log | **NOT TESTED** |
| P0 | Save durability: reopen on another day; forced-close, corrupt save/backup with disposable test data only; successful restore without misreporting | A non-sensitive dummy Windows user profile with logs | **NOT TESTED** |
| P0 | Final content rights: Kenney palette source, raw four OGG upstream byte matching, studio/title rights, per-distribution-territory notices | Save official source screenshots, hashes and review outcome | **NOT CLEARED** |
| P0 | User-facing language, return focus, legible settings, contrast and break hints at typical Windows resolution | A human keyboard-only walkthrough and screenshot comparison | **NOT TESTED** |
| P0 | Legitimate seller account, tax/payments/onboarding and the actual marketplace's release policy | Confirm seller eligibility and current official terms, do not bypass any age/identity requirement | **NOT STARTED** |
| P0 | Final Windows product package and public store review | Re-run strict source/asset QA after approved last fixes; real target-PC sign-off; final release candidate created *only then* | **BLOCKED** |
| P1 | Full 200% adaptive font scaling, universal key rebinding, screen-reader/other language support | Scope after actual feedback; **do not advertise what isn't present** | **NOT IMPLEMENTED** |
| P1 | Extra content, extra items, new levels, additional branding variants | Only add on clear player demand and evidence | **FROZEN** |

### Manual player walkthrough to collect once (no paid test service required)
1. On a regular Windows 10/11 computer, start the **INTERNAL TEST ONLY** ZIP from a local folder. Record Windows version, GPU, resolution, whether sound is working and the EXE hash. Never post personal saved-game paths or private IDs to the public repo.
2. Main menu: tab/shift-tab and Enter/Space without mouse. Enter Settings, turn on high contrast and larger text; verify the family page scrolls and Back returns to the correct control.
3. Start fresh on a disposable save; buy one SKU, place it on a real shelf with E, change price, allow a customer to pay, close the day. Capture any texture/model/animation collision errors.
4. Save, exit normally, restart executable, confirm cash/stock/day. Repeat on a separate disposable save for failure and backup tests; don't sabotage a real save.
5. Listen to BGM and effects, change volume to zero and back. Note freeze, crash, flash, font clipping or camera discomfort if any. One reproducible issue means **FAIL**, not “probably okay.”
6. Repeat at both 1280×720 and 1920×1080 and at one typical small laptop display. Photosensitivity, motion comfort and keyboard-only usability need human acceptance.

### Budget-aware paid storefront decision (do not pay yet)
- **itch.io**: its official creator docs support a minimum price and Open Revenue Sharing, with payment processing and taxes potentially deducted. Useful to evaluate for a small buy-once launch after final sign-off, not automatically free of all transaction costs. https://itch.io/docs/creators/pricing ; https://itch.io/docs/creators/payments
- **Steam**: official Steam Direct fee **US$100 for each new app** (recoupable after `US$1,000 Adjusted Gross Revenue`, not free upfront). Steam also has onboarding and store review/coming-soon timing requirements. **Do not spend this fee before the game has passed human device tests and there is a feasible sales plan.** https://partner.steamgames.com/doc/gettingstarted/appfee ; https://partner.steamgames.com/steamdirect
- Applicable seller age/account eligibility, payment identity verification, national and platform tax responsibilities must be satisfied legitimately. This checklist does not suggest bypassing any requirements. Any registered-company or copyright-registration question needs jurisdiction-specific guidance; absence of registration does not by itself make the game free of copyright.
- No store page published, no sales collection attempted, no paid fees incurred by this project work.

## Release gate decision
**NOT READY TO SELL (P0 human hardware, exact licensed bytes/title review, marketplace/account readiness outstanding).**
**READY FOR FINAL HUMAN INTERNAL PLAYTEST** as of successful Windows native run `45105698738`.
Never mark “complete”, “accessible to every player”, “rights-cleared”, “photosensitivity safe”, or “commercial release approved” without evidence.

Game owner should not have to pay for redundant re-builds: retain the verified primary Drive source and one internal Windows EXE; label earlier content historical, and repackage only after a proven defect is fixed.

## Gameplay enrichment and accessibility follow-up (2026-11-23)

The player requested realistic second-hand shop situations without requiring literacy, and approved implementing as many as can safely fit existing mechanics. We integrated **one optional, reusable picture-first sorting/event station**, not dozens of expensive bespoke stories or 3D packs. Seven types now cover clothing recycling uncertainty (ABC's Anglican Belltower Op Shop free rack), appliance testing, private keepsakes, missing price labels, sorting mixed donations, clearing walking access and furniture repair. The existing 27 products, 9 shelves, save system and buy-once offline business model remain in place.

There are **ten original vector symbols**, two large choice buttons, independently aligned pictogram/currency/storage/goodwill values, a large icon+number result, explicit keyboard focus, and a speaker button using the device's built-in English OS text-to-speech where available. No paid voice API or external service was added. Not all players have OS voices; the rest of the game is still partly text-led, so do **not** claim complete non-reading or universal child accessibility. No guaranteed full warehouse clearing is awarded simply because clothing was placed out for free.

The exact implementation notes, real-world evidence, accessible UI details and caveats are in [PICTURE_FIRST_REAL_WORLD_THRIFT_EVENTS_2026-11-23.md](PICTURE_FIRST_REAL_WORLD_THRIFT_EVENTS_2026-11-23.md). This update uses existing art and is part of the **same** canonical game rather than a new versioned title.

Strict Windows Godot 4.4.1 source/asset import, 23/23 native gameplay suites, embedded internal EXE export and source-free smoke test completed successfully in [run 45126152356](https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45126152356). Interactive physical-device audio/TTS, customer routes and user accessibility still require genuine player testing.
