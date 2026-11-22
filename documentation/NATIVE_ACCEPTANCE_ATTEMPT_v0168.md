# Native Godot 4.4.1 acceptance — attempted 2026-11-22

Command: `bash tools/run_native_acceptance.sh`

Exit code: `2`

```
BLOCKED_ENGINE_NOT_INSTALLED: Godot 4 executable not available in this runtime.
The Godot project was NOT imported, parsed by Godot, run, or exported.
Use GODOT_BIN=/absolute/path/to/godot to point to an existing official Godot editor binary.
```

The official 4.4.1 binary download was also attempted from this environment, but network/DNS or download service restrictions prevented obtaining a verified editor executable. None of the 23 Godot QA scripts or the actual scene were executed under Godot. No Windows EXE was built. Offline Python audits and 4-mode fake test-runner verification are **not** Godot execution.

Actual next gate: load this source in Godot 4.4.1 editor on Windows, run `run_check_windows.cmd`, inspect `documentation/native_run_logs/RESULT_windows.txt`, then do visual/keyboard/mouse/window-X/Alt+F4 and safe-save-failure tests.
