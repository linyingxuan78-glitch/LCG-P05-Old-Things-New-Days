#!/usr/bin/env bash
# Official Godot editor executable required. Never treat static checks as native engine tests.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${LCG_QA_LOG_DIR:-$ROOT/documentation/native_run_logs}"
mkdir -p "$LOG_DIR"
ENGINE="${GODOT_BIN:-}"
if [[ -z "$ENGINE" ]]; then
  for candidate in godot4 godot Godot; do
    if command -v "$candidate" >/dev/null 2>&1; then ENGINE="$(command -v "$candidate")"; break; fi
  done
fi
if [[ -z "$ENGINE" ]]; then
  for candidate in "$ROOT/engine/godot" "$HOME/.local/bin/godot" /usr/local/bin/godot /usr/bin/godot; do
    if [[ -x "$candidate" ]]; then ENGINE="$candidate"; break; fi
  done
fi
if [[ -z "$ENGINE" || ! -x "$ENGINE" ]]; then
  cat >"$LOG_DIR/RESULT.txt" <<'END'
BLOCKED_ENGINE_NOT_INSTALLED: Godot 4 executable not available in this runtime.
The Godot project was NOT imported, parsed by Godot, run, or exported.
Use GODOT_BIN=/absolute/path/to/godot to point to an existing official Godot editor binary.
END
  cat "$LOG_DIR/RESULT.txt"
  exit 2
fi
badlog() {
  # Godot may exit zero even if scripts failed to load; check its log too.
  grep -qiE '(^|[[:space:]])(SCRIPT ERROR:|Parse Error:|Parser Error:|ERROR:|FAILED:)' "$1"
}
run_step() {
  local name="$1"; shift
  local file="$LOG_DIR/$name.log"
  if ! timeout 180 "$ENGINE" "$@" >"$file" 2>&1; then
    printf 'FAIL: %s returned nonzero or timed out. See %s\n' "$name" "$file" | tee -a "$LOG_DIR/RESULT.txt"
    return 1
  fi
  if badlog "$file"; then
    printf 'FAIL: %s logged an error. See %s\n' "$name" "$file" | tee -a "$LOG_DIR/RESULT.txt"
    return 1
  fi
  return 0
}
printf 'Engine: %s\n' "$ENGINE" >"$LOG_DIR/RESULT.txt"
if ! "$ENGINE" --version >"$LOG_DIR/engine_version.txt" 2>&1; then
  printf 'FAIL: engine --version\n' | tee -a "$LOG_DIR/RESULT.txt"; exit 1
fi
printf 'Version: %s\n' "$(head -1 "$LOG_DIR/engine_version.txt")" >>"$LOG_DIR/RESULT.txt"
if ! run_step editor_import --headless --path "$ROOT" --editor --import --quit; then exit 1; fi
if ! run_step main_scene_startup --headless --path "$ROOT" --quit-after 15; then exit 1; fi
failures=0
for name in qa_smoke qa_economy qa_customer_flow qa_v012_continuity qa_v013_demand_and_recovery qa_v014_onboarding_and_accessibility qa_v0141_ui_input qa_v0147_assets_and_audio qa_v0152_finale_and_animations qa_v0153_catalog_and_save_migration qa_v0154_supplier_animation_routes qa_v0155_resident_trade_ins qa_v0156_events_and_usability qa_v0157_customer_help qa_v0158_visual_comfort_and_tutorial qa_v0159_world_shelf_wayfinding qa_v0160_healthy_play qa_v0161_privacy_and_pictograms qa_v0162_picture_catalog_and_safe_close qa_v0163_save_recovery qa_v0165_engine_licenses qa_v0167_brand_intro_and_exit qa_v0168_safe_desktop_exit_and_intro; do
  case "$name" in
    qa_smoke) expected='^QA SMOKE PASSED:' ;;
    qa_economy) expected='^QA ECONOMY PASSED:' ;;
    qa_customer_flow) expected='^QA CUSTOMER PASSED:' ;;
    qa_v012_continuity) expected='^v0\.12 CONTINUITY PASS:' ;;
    qa_v013_demand_and_recovery) expected='^v0\.13 QA PASS:' ;;
    qa_v014_onboarding_and_accessibility) expected='^v0\.14 QA PASS:' ;;
    qa_v0141_ui_input) expected='^QA UI INPUT PASSED:' ;;
    qa_v0147_assets_and_audio) expected='^QA ASSETS 0147 PASSED:' ;;
    qa_v0152_finale_and_animations) expected='^QA 0152 PASSED:' ;;
    qa_v0153_catalog_and_save_migration) expected='^QA 0153 PASSED:' ;;
    qa_v0154_supplier_animation_routes) expected='^QA 0154 PASSED:' ;;
    qa_v0156_events_and_usability) expected='^QA 0156 PASSED:' ;;
    qa_v0157_customer_help) expected='^QA CUSTOMER HELP 0157 PASSED:' ;;
    qa_v0158_visual_comfort_and_tutorial) expected='^QA 0158 PASSED:' ;;
    qa_v0160_healthy_play) expected='^QA 0160 PASSED:' ;;
    qa_v0161_privacy_and_pictograms) expected='^QA 0161 PASSED:' ;;
    qa_v0162_picture_catalog_and_safe_close) expected='^QA 0162 PASSED:' ;;
    qa_v0163_save_recovery) expected='^QA 0163 PASSED:' ;;
    qa_v0165_engine_licenses) expected='^QA ENGINE RIGHTS 0165 PASSED:' ;;
    qa_v0167_brand_intro_and_exit) expected='^QA BRAND 0167 PASSED:' ;;
    qa_v0168_safe_desktop_exit_and_intro) expected='^QA 0168 PASSED:' ;;
    qa_v0159_world_shelf_wayfinding) expected='^QA 0159 PASSED:' ;;
    qa_v0155_resident_trade_ins) expected='^QA 0155 PASSED:' ;;
    *) expected='^IMPOSSIBLE_MARKER$' ;;
  esac
  if run_step "$name" --headless --path "$ROOT" --script "res://tests/$name.gd" && grep -qE "$expected" "$LOG_DIR/$name.log"; then
    printf 'PASS: %s\n' "$name" >>"$LOG_DIR/RESULT.txt"
  else
    printf 'FAIL: %s did not show a clean explicit PASS\n' "$name" >>"$LOG_DIR/RESULT.txt"
    failures=$((failures+1))
  fi
done
if (( failures > 0 )); then
  printf 'FAIL: %d tests did not pass\n' "$failures" | tee -a "$LOG_DIR/RESULT.txt"
  exit 1
fi
printf 'PASS: Godot editor import, main-scene startup and 23 headless QA suites\n' >>"$LOG_DIR/RESULT.txt"
printf 'NOT TESTED: Windows EXE export, visual quality or real-device interaction\n' >>"$LOG_DIR/RESULT.txt"
cat "$LOG_DIR/RESULT.txt"
