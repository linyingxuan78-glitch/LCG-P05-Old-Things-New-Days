# v0.14.3 — Acceptance Reliability Patch (2026-11-20)

This revision does **not** claim engine-run success or introduce untested gameplay.

- Linux acceptance now requires the specific success text emitted by each of the seven suites. A generic `PASS` in unrelated output is insufficient.
- Windows acceptance uses the same per-suite strict marker table (PowerShell execution not verified here).
- Added `tools/selftest_acceptance_runner.py`, which checks the Linux acceptance controller with a fake engine using clean success, unrelated success text, error output and nonzero exit scenarios.
- Previous game mechanics, save path and content are unchanged.

**Verification tiers:** static project inspection and mock-runner control checks are separate from native Godot gameplay and interactive Windows tests. Neither mock output nor static checks certify the game.
