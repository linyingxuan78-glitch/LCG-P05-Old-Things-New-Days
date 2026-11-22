# Little Cozy Games · LCG-P05 · Agent development guardrails

This is the *internal* Godot 4 project for **Old Things, New Days**. Do not equate source ZIPs or static QA with a playable Windows executable.

## Before any edit

- Treat `project.godot`, `main.tscn`, `scripts/`, `assets/`, `licenses/`, `tests/`, and `export_presets.cfg` as one project. Do not create a new unrelated game.
- Do not overwrite or publish a newer canonical Google Drive file without checking its metadata and contents. Preserve the one-latest-file workflow.
- Do not add undocumented third-party media or SDKs. `licenses/USED_ASSET_PROVENANCE.csv` is the traceability source of truth; any new asset needs author, license, URL, original source, SHA-256 and verification status.
- This remains a private prototype. No public release, storefront upload, or registration/trademark claim without separate approvals.

## Tests and evidence

1. `python tools/check_ci_pipeline.py`
2. `python tools/static_preflight.py`
3. `python tools/sync_release_notices.py` (**without** `--sync`; fail if notice is stale)
4. `python tools/check_creator_provenance_v0166.py`
5. `python tools/selftest_acceptance_runner.py` (**MOCK**, not actual Godot)
6. With Godot 4.4.1 installed, `GODOT_BIN=/path/to/godot bash tools/run_native_acceptance.sh` for import, scene boot and 23 original headless suites.
7. Optional, only after native success: Windows internal export using `tools/build_windows_release.ps1`, with actual engine-component legal snapshot.
8. Then separately test exported EXE on Windows for UI, animation, collisions, audio, accessibility and light sensitivity.

**Test integrity:** Set `qa_mode=true` on scene instances *before* adding them to the scene tree. Keep test save data isolated from real user saves. Confirm each suite's unique PASS marker and absence of `SCRIPT ERROR`/`ERROR` in the engine logs. If Godot is missing or remote CI has not been run, report BLOCKED / NOT TESTED, not PASS.

## UX and accessibility

No forced logo/credits, no rapid flashing or unnecessary camera motion, no mandatory registration, no ad-tracking SDK. Prefer actions in the 3D store with picture cues, non-colour-only signals and brief optional tutorials; preserve optional Healthy Play / Family guidance. Those protections require actual hardware and user testing before a safety claim.

## References

- Local handoff: `documentation/NATIVE_CI_HANDOFF_v0169.md`
- CI workflow: `.github/workflows/godot_native_qa.yml`
- Official engine CLI: https://docs.godotengine.org/en/4.4/tutorials/editor/command_line_tutorial.html
- CI setup action: https://github.com/chickensoft-games/setup-godot
