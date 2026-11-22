# v0.14.1 Godot acceptance / 2026-11-16

The executable is NOT installed in the current model environment. `curl` could not resolve the official download host; the mediated download channel also could not retrieve the Linux archive. Therefore the engine could not be started here.

## Verification performed

- Existing v0.14 project/source was inspected (not a fabricated project).
- Corrected mouse event interception risk for the fullscreen UI root, HUD layer, and HUD-only background panels, based on Godot Control.mouse_filter documentation.
- Added native `qa_v0141_ui_input.gd` to check that menu buttons remain clickable and the HUD does not consume camera mouse events.
- Added `tools/run_native_acceptance.sh`, which imports assets and runs seven Godot tests if an engine is present, and otherwise exits code 2 with a BLOCKED log.
- Existing static preflight executes without an engine, but this IS NOT a Godot engine parse/runtime validation.

## Not yet verified

- Opening/importing the project in Godot 4 with no GDScript errors
- Main scene rendering, controls, audio and save data on an actual PC
- Windows EXE build and launch

## Native run entrypoint

Set `GODOT_BIN` to an installed Godot 4 binary if it is not on PATH, then execute `bash tools/run_native_acceptance.sh`. Exit 0 means all headless checks passed, exit 1 means failure, exit 2 means no engine. The command retains logs under `documentation/native_run_logs`.
