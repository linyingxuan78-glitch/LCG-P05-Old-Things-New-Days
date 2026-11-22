# v0.16.3 — Safe Local Saves

- Stage complete JSON as `.pending` before replacement; reject invalid writes.
- Back up only previously validated saves, with disk-write checks.
- Attempt Windows-safe rename fallback only when a validated `.bak` exists.
- Recover valid pending files, then primary, then backup.
- Include pending file in intentional local-delete flow and continue-game detection.
- Add isolated Godot QA for interrupted writes and recovery; no real save is touched.
- Still no Godot editor/runtime in this environment.
