#!/usr/bin/env python3
"""Offline source/data provenance and QA wiring checks. NEVER a native Godot game test."""
import csv,hashlib,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
shop=(ROOT/'scripts/shop.gd').read_text(encoding='utf8')
privacy=(ROOT/'scripts/privacy_safety.gd').read_text(encoding='utf8')
test=(ROOT/'tests/qa_v0163_save_recovery.gd').read_text(encoding='utf8')
linux=(ROOT/'tools/run_native_acceptance.sh').read_text(encoding='utf8')
windows=(ROOT/'tools/run_native_acceptance_windows.ps1').read_text(encoding='utf8')
mock=(ROOT/'tools/selftest_acceptance_runner.py').read_text(encoding='utf8')
checks={
 'same_save_path': 'const SAVE_PATH: String = "user://lcg_p05_shop_v09.json"' in shop,
 'staged_write_exists': 'func _write_save_safely(path: String, data: Dictionary) -> bool:' in shop and 'pending.store_string(JSON.stringify(data))' in shop,
 'no_main_truncate_before_verification': shop.find('var pending: FileAccess = FileAccess.open(pending_path, FileAccess.WRITE)') < shop.find('if not _read_save_data(path).is_empty():') < shop.find('DirAccess.rename_absolute(source_abs, target_abs)'),
 'checks_staged_json_validity': 'pending_error != OK or _read_save_data(pending_path).is_empty()' in shop,
 'backup_only_from_valid_primary': 'if not _read_save_data(path).is_empty():' in shop and 'backup_error != OK or _read_save_data(path + ".bak").is_empty()' in shop,
 'windows_replacement_only_after_backup_check': 'if _read_save_data(path + ".bak").is_empty():' in shop and 'DirAccess.remove_absolute(target_abs)' in shop,
 'resume_pending_primary_backup': all(x in shop for x in ['func _select_valid_save_data(path: String) -> Dictionary:', '_read_save_data(path + SAVE_PENDING_SUFFIX)', '_read_save_data(path)', '_read_save_data(path + ".bak")']),
 'main_menu_knows_pending': 'title_continue.disabled = not FileAccess.file_exists(SAVE_PATH) and not FileAccess.file_exists(SAVE_PATH + ".bak") and not FileAccess.file_exists(SAVE_PATH + SAVE_PENDING_SUFFIX)' in shop,
 'manual_save_failure_explained': 'if _save_game():\n        _message("Shop saved locally.")' in shop and 'SAVE FAILED.' in shop,
 'qa_guard_main_save_path': 'if qa_mode and path == SAVE_PATH:' in shop,
 'delete_all_local_saves': 'for path in [SHOP_SAVE_PATH, SHOP_SAVE_PATH + ".bak", SHOP_SAVE_PATH + ".pending"]:' in privacy,
 'isolated_qa_does_not_use_real_save': 'const TEMP_PATH: String = "user://lcg_p05_qa_v0163_isolated_save.json"' in test and '"user://lcg_p05_shop_v09.json", first' in test,
 'isolated_qa_cleans_up': 'func _clean() -> void:' in test and '_clean()\n    _expect(not FileAccess.file_exists(TEMP_PATH)' in test,
 'native_qa_marker_registered': all('qa_v0163_save_recovery' in x for x in [linux,windows,mock]) and 'QA 0163 PASSED:' in test,
 'all_previous_19_qa_suites_retained': len(list((ROOT/'tests').glob('qa_*.gd')))>=20,
 'version_consistent': bool(re.search(r'Internal v(\d+\.\d+\.\d+)',(ROOT/'project.godot').read_text())) and all('v'+re.search(r'Internal v(\d+\.\d+\.\d+)',(ROOT/'project.godot').read_text()).group(1) in p.read_text(encoding='utf8') for p in [ROOT/'scripts/shop.gd',ROOT/'README_中文.md']),
 'source_game_still_has_27_goods': len(re.findall(r'\{"name":', shop.split('const PRODUCTS = [',1)[1].split(']\nconst DISPLAY_LEVEL_PRICES',1)[0]))==27,
 'privacy_and_healthy_play_still_present': all((ROOT/'scripts'/f).is_file() for f in ['healthy_play.gd','privacy_safety.gd']),
}
with (ROOT/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f: rows=list(csv.DictReader(f))
medias=[p for p in (ROOT/'assets').rglob('*') if p.is_file() and p.suffix.lower() in ['.png','.jpg','.jpeg','.glb','.fbx','.ogg','.wav','.mp3','.webp']]
registered={row['path']:row for row in rows}
checks['115_asset_records_still_untouched']=(len(rows)==len(medias)==len(registered)==115 and all(p.relative_to(ROOT).as_posix() in registered and hashlib.sha256(p.read_bytes()).hexdigest()==registered[p.relative_to(ROOT).as_posix()]['sha256'] for p in medias))
res={'status':'PASS' if all(checks.values()) else 'FAIL','scope':'STATIC ONLY; no Godot engine test or power-loss QA executed','checks':checks,'media_count':len(medias),'registered_count':len(rows),'native_suite_files':len(list((ROOT/'tests').glob('qa_*.gd'))),'failures':[k for k,v in checks.items() if not v]}
(ROOT/'documentation/STATIC_AUDIT_v0163.json').write_text(json.dumps(res,indent=2,ensure_ascii=False)+'\n')
print(json.dumps(res,indent=2,ensure_ascii=False))
sys.exit(0 if all(checks.values()) else 1)
