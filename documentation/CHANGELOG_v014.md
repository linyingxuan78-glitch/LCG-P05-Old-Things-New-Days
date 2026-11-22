# LCG-P05 · Godot v0.14 — Onboarding, Accessibility & Safeguards

**Status:** implementation in source files, *static QA only*. Godot editor import, compile, runtime, screen layout, gamepad, keyboard, real device and Windows export tests have **not** been completed.

## New / changed

1. Five-action interactive onboarding attached to actual game events: opening Store Desk → buying → placing inventory → changing a price → selling at checkout. Progress is recorded in `user://lcg_p05_shop_v09.json` (same old save path, new fields with backward-compatible defaults).
2. Optional Skip Tutorial, replay from Help, and How To Play accessible from title, store desk, and pause. Help view stops simulated business time and closes on Esc. Existing saved games without the new keys do **not** force a new tutorial.
3. Accessibility section alongside Master/Music/SFX: Larger UI Text (112%), High Contrast Panels, Reduced Motion (skips studio splash and eliminates customer bob). Preferences save in existing `user://lcg_p05_audio_settings.json`. These are useful preliminary controls, **not** certification of complete accessibility.
4. New Game displays an overwrite confirmation if a save or backup is present. Cancel leaves the existing save intact.
5. QA script `tests/qa_v014_onboarding_and_accessibility.gd` added, static preflight updated to test new source invariants. The QA script is **not executed** without Godot.

## Deliberate limits

- Five steps teach actions instead of requiring the user to read a long manual. The tutorial does not artificially reward the player or bypass their real cash balance.
- The UI continues to use fixed 1280×720 pixel positions: text scaling may need further layout refinement; do not mark all screen sizes as approved.
- No screen reader or speech synthesis is claimed. No customizable key bindings yet. High contrast addresses some interfaces only, not all 3D colors.
- No legal/official "all ages" rating is claimed. Content classification must be checked with the final game and release platform.
- Third-party Kenney and OpenGameArt materials remain under the asset-specific documented CC0 statements. Product title and studio trademark are not officially cleared.
- Commercial-release approval remains withheld; this is a source development revision, not an EXE.

## Manual QA after installing Godot 4.x

1. Import `project.godot` in Godot 4.4 or compatible; allow assets to import.
2. Run all existing QA scripts plus `qa_v014_onboarding_and_accessibility.gd` in headless mode (see README).
3. Confirm first New Game tutorial advances only on genuine actions and checkout, can be skipped and replayed.
4. Confirm old save continues without forced onboarding; new game asks permission to replace it.
5. Change accessibility settings, quit editor/game and re-open; confirm each setting persists.
6. Inspect UI at 1280×720 and alternate display sizes for clipping, especially store desk 9-row list and enlarged fonts.
7. Test reduced motion and contrast visually; check keyboard and mouse focus from help / desk / pause.
8. Check that old daily demand, sales, end-of-day ledger and consignment systems still work.
