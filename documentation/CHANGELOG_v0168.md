# v0.16.8 — Safe Desktop Exit and First-Frame Brand QA (2026-11-22)

- _ready() calls SceneTree.set_auto_accept_quit(false) to handle window close requests in project code.
- _notification(NOTIFICATION_WM_CLOSE_REQUEST) routes window X / Alt+F4 to the same safety check as Quit Desktop.
- _prepare_desktop_exit() blocks quitting when the shop save fails; only successful saves allow a committed quit.
- _new_game() warns when initial save failed instead of claiming success.
- The 1.8s logo fades are unchanged in design; `_advance_splash` provides deterministic alpha stepping for Godot QA.
- Added `qa_v0168_safe_desktop_exit_and_intro.gd` and wired all 23 suites to both native runners and the mock runner.
- No added media or SDK. All existing CC0 and Godot licensing records retained.
- This work is NOT a Godot native pass: test host lacks Godot and cannot obtain the official editor binary. No EXE built.
