#!/usr/bin/env python3
"""Test acceptance runner logic without pretending to run Godot."""
import os, subprocess, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RUNNER = ROOT / "tools" / "run_native_acceptance.sh"
MARKERS = {
    "qa_smoke": "QA SMOKE PASSED: simulated",
    "qa_economy": "QA ECONOMY PASSED: simulated",
    "qa_customer_flow": "QA CUSTOMER PASSED: simulated",
    "qa_v012_continuity": "v0.12 CONTINUITY PASS: simulated",
    "qa_v013_demand_and_recovery": "v0.13 QA PASS: simulated",
    "qa_v014_onboarding_and_accessibility": "v0.14 QA PASS: simulated",
    "qa_v0141_ui_input": "QA UI INPUT PASSED: simulated",
    "qa_v0147_assets_and_audio": "QA ASSETS 0147 PASSED: simulated",
    "qa_v0152_finale_and_animations": "QA 0152 PASSED: simulated",
    "qa_v0153_catalog_and_save_migration": "QA 0153 PASSED: simulated",
    "qa_v0154_supplier_animation_routes": "QA 0154 PASSED: simulated",
    "qa_v0155_resident_trade_ins": "QA 0155 PASSED: simulated",
    "qa_v0156_events_and_usability": "QA 0156 PASSED: simulated",
    "qa_v0157_customer_help": "QA CUSTOMER HELP 0157 PASSED: simulated",
    "qa_v0158_visual_comfort_and_tutorial": "QA 0158 PASSED: simulated",
    "qa_v0159_world_shelf_wayfinding": "QA 0159 PASSED: simulated",
    "qa_v0160_healthy_play": "QA 0160 PASSED: simulated",
    "qa_v0161_privacy_and_pictograms": "QA 0161 PASSED: simulated",
    "qa_v0162_picture_catalog_and_safe_close": "QA 0162 PASSED: simulated",
    "qa_v0163_save_recovery": "QA 0163 PASSED: simulated",
    "qa_v0165_engine_licenses": "QA ENGINE RIGHTS 0165 PASSED: simulated",
    "qa_v0167_brand_intro_and_exit": "QA BRAND 0167 PASSED: simulated",
    "qa_v0168_safe_desktop_exit_and_intro": "QA 0168 PASSED: simulated",
}
MOCK = r'''#!/usr/bin/env bash
# Test harness: this script is a stub, never Godot.
if [[ " $* " == *" --version "* ]]; then echo '4.4.mock'; exit 0; fi
if [[ " $* " != *" --script "* ]]; then echo 'Simulated startup'; exit 0; fi
name="${@: -1}"
name="${name##*/}"
name="${name%.gd}"
case "$name" in
    qa_smoke) marker='QA SMOKE PASSED: simulated';;
    qa_economy) marker='QA ECONOMY PASSED: simulated';;
    qa_customer_flow) marker='QA CUSTOMER PASSED: simulated';;
    qa_v012_continuity) marker='v0.12 CONTINUITY PASS: simulated';;
    qa_v013_demand_and_recovery) marker='v0.13 QA PASS: simulated';;
    qa_v014_onboarding_and_accessibility) marker='v0.14 QA PASS: simulated';;
    qa_v0141_ui_input) marker='QA UI INPUT PASSED: simulated';;
    qa_v0147_assets_and_audio) marker='QA ASSETS 0147 PASSED: simulated';;
    qa_v0152_finale_and_animations) marker='QA 0152 PASSED: simulated';;
    qa_v0153_catalog_and_save_migration) marker='QA 0153 PASSED: simulated';;
    qa_v0154_supplier_animation_routes) marker='QA 0154 PASSED: simulated';;
    qa_v0155_resident_trade_ins) marker='QA 0155 PASSED: simulated';;
    qa_v0156_events_and_usability) marker='QA 0156 PASSED: simulated';;
    qa_v0157_customer_help) marker='QA CUSTOMER HELP 0157 PASSED: simulated';;
    qa_v0158_visual_comfort_and_tutorial) marker='QA 0158 PASSED: simulated';;
    qa_v0159_world_shelf_wayfinding) marker='QA 0159 PASSED: simulated';;
    qa_v0160_healthy_play) marker='QA 0160 PASSED: simulated';;
    qa_v0161_privacy_and_pictograms) marker='QA 0161 PASSED: simulated';;
    qa_v0162_picture_catalog_and_safe_close) marker='QA 0162 PASSED: simulated';;
    qa_v0163_save_recovery) marker='QA 0163 PASSED: simulated';;
    qa_v0165_engine_licenses) marker='QA ENGINE RIGHTS 0165 PASSED: simulated';;
    qa_v0167_brand_intro_and_exit) marker='QA BRAND 0167 PASSED: simulated';;
    qa_v0168_safe_desktop_exit_and_intro) marker='QA 0168 PASSED: simulated';;
    *) marker='unknown';;
esac
case "${MOCK_QA_MODE:-pass}" in
  error) echo 'ERROR: simulated engine failure'; exit 0;;
  wrong_marker) echo 'QA SMOKE PASSED: unrelated, no correct suite marker'; exit 0;;
  nonzero) echo "$marker"; exit 1;;
  *) echo "$marker"; exit 0;;
esac
'''

def main():
    with tempfile.TemporaryDirectory(prefix='lcg_runner_test_') as temp:
        temp = Path(temp)
        engine = temp / 'mock_godot'
        engine.write_text(MOCK)
        engine.chmod(0o755)
        outcomes = {'pass': 0, 'wrong_marker': 1, 'error': 1, 'nonzero': 1}
        for mode, expected in outcomes.items():
            logdir = temp / mode
            env = {**os.environ, 'GODOT_BIN': str(engine), 'LCG_QA_LOG_DIR': str(logdir), 'MOCK_QA_MODE': mode}
            result = subprocess.run(['bash', str(RUNNER)], cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
            if result.returncode != expected:
                raise AssertionError(f'{mode}: expected {expected}, got {result.returncode}\n{result.stdout}\n{result.stderr}')
            print(f'PASS runner simulation: {mode}, exit={result.returncode}')
        print('PASS: all four runner-control simulations. No native Godot tests were run.')

if __name__ == '__main__':
    main()
