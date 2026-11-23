# LCG-P05 — Real Windows Player Acceptance Form (unverified until filled)
Date prepared: 2026-11-23. For the current **INTERNAL TEST ONLY** ZIP. This is **not** a retail release authorization.

## Build identity and evidence
- Tested ZIP filename:
- Download origin / link:
- SHA-256 of ZIP (optional but recommended):
- Actual Windows version:
- CPU / GPU / RAM:
- Display size and Windows scaling:
- Tester/date:
- Test evidence folder (screenshots / 1–3 short recordings):
- Did Windows Defender or antivirus warn? Describe exactly:
- Crash/error log path and contents if any:

**How to complete:** Download the current Windows internal-test ZIP from the existing Google Drive LATEST link or the successful GitHub Windows validation artifact. Extract it to an ordinary local folder, not inside a source-code directory. Do not use important existing saves. Enter PASS, FAIL or NOT TESTED for every row; only PASS if physically observed. Never mark PASS on the basis of CI or AI text alone.

| ID | Real actions / objective acceptance | Result (PASS/FAIL/NOT TESTED) | Screenshot or notes |
|---|---|---|---|
| W01 | Start the EXE by double-clicking after extracting; menu and 3D room appear with no crash | NOT TESTED | |
| W02 | At 1280x720 and 1920x1080 inspect menus, events, labels and shelves; no clipped essential UI; note FPS and GPU used | NOT TESTED | |
| W03 | Walk, turn camera, interact and close/open UI with keyboard and mouse; test Esc, Tab, Shift+Tab and F1 | NOT TESTED | |
| W04 | Complete sourcing, shelving, pricing and sale; interact with all nine display sections; verify economy values respond | NOT TESTED | |
| W05 | Observe customer navigation and idle/walk/reach/reject animations; record any stuck NPC, clipping or invisible item | NOT TESTED | |
| W06 | Listen through headphones or speakers to music, steps, clicks and trade sound; adjust music/effects/master volume, mute/unmute | NOT TESTED | |
| W07 | With Windows English speech voice available, activate optional event read-aloud and assess intelligibility; then test voice unavailable case without blocking play | NOT TESTED | |
| W08 | Make a test save, fully exit, reopen and compare day/cash/stock/prices/event outcome; test normal X and Alt+F4 exit | NOT TESTED | |
| W09 | Try the seven optional event types when naturally available; inspect image-first understanding and confirm choices cannot be repeatedly rewarded | NOT TESTED | |
| W10 | Complete a longer normal session and restart; record stuttering, crash, lost progress, camera nausea or disruptive flashing | NOT TESTED | |
| W11 | Ask a voluntary tester with limited reading fluency to try the pictogram-driven event with appropriate supervision when needed; no claim of universal accessibility | NOT TESTED | |
| W12 | Confirm visual art, credits, third-party notices, studio name and final store screenshots match actual game and approved asset ledger | NOT TESTED | |

## Defect recording
For any FAIL record: test ID; steps to reproduce; expected result; actual result; frequency; screenshot/video; severity; machine specs. Severity **BLOCKER** = cannot start, play or reliably save; **HIGH** = severe control, audio, display or progression problem; **MEDIUM/LOW** = manageable visual/usability issue. Retest the exact fix and rerun automated regression before changing status.

## Commercial release gates (separate from local testing)
- [ ] W01–W10 and W12 complete without unresolved BLOCKER/HIGH defects; W11 has appropriate evidence before claiming low-literacy accessibility.
- [ ] Performance and minimum specs supported by real GPU measurements, not Basic Render Driver CI numbers.
- [ ] Rights ledger covers every shipped asset; final title and studio name cleared for target markets (manual/legal verification).
- [ ] Publisher account, age/guardian consent where required, payment provider, identity and tax requirements met.
- [ ] Accurate store page, price, refund/support contact, content/age disclosure, and optional accessibility labels reviewed.
- [ ] Final retail ZIP built from the **same reviewed commit**; no INTERNAL TEST ONLY markers; hash and smoke-check retail upload.
- [ ] Release owner gives explicit approval before any paid listing or public publishing.

## Current sign-off
Real Windows test: **NOT TESTED**. Rights/name/store eligibility: **NOT COMPLETE**. Release ready: **NO**.
Latest source commit observed at preparation: `8ce982c1207dd4585ccf62e3620d55db0b01fbf7`.
Windows validation workflow 45153165346: successful. Separately, native QA workflow 45153075961 failed on an earlier commit: do not misrepresent all historical workflows as PASS. These results are CI only, not real-player sign-off.
