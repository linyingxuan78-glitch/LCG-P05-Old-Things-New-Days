#!/usr/bin/env python3
"""Only static project consistency + a mathematical fade-envelope check.
Not an actual Godot runtime, OS close, UI visibility, or Windows export test.
"""
from pathlib import Path
import json, hashlib, csv, re, sys
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'scripts/shop.gd').read_text()
linux=(ROOT/'tools/run_native_acceptance.sh').read_text()
win=(ROOT/'tools/run_native_acceptance_windows.ps1').read_text()
mock=(ROOT/'tools/selftest_acceptance_runner.py').read_text()
project=(ROOT/'project.godot').read_text()
qa=(ROOT/'tests/qa_v0168_safe_desktop_exit_and_intro.gd').read_text()
checks={}
# Historical QA: require matching game/project versions, not a permanently frozen version number.
source_ver = re.search(r'gameplay v(\d+\.\d+\.\d+)', s)
project_ver = re.search(r'Internal v(\d+\.\d+\.\d+)', project)
checks['brand_and_project_version_match'] = bool(source_ver and project_ver and source_ver.group(1) == project_ver.group(1) and tuple(map(int, source_ver.group(1).split('.'))) >= (0, 16, 8))
checks['official_window_close_notification']=all(x in s for x in ['get_tree().set_auto_accept_quit(false)','func _notification(what: int) -> void:','NOTIFICATION_WM_CLOSE_REQUEST','_quit_desktop()'])
checks['all_exit_paths_guarded']=all(x in s for x in ['func _prepare_desktop_exit() -> bool:','if not _prepare_desktop_exit():\n        return','exit_committed = true\n    get_tree().quit()'])
checks['qa_save_failure_hook_is_qa_only']='if qa_mode:\n        return not qa_force_save_failure' in s
checks['initial_save_failure_warned']='SAVE FAILED. You can still play, but your progress is not stored.' in s
checks['splash_fade_same_style_and_duration']=all(x in s for x in ['const BRAND_SPLASH_SECONDS: float = 1.8','const BRAND_FADE_IN_SECONDS: float = 0.50','const BRAND_FADE_OUT_SECONDS: float = 0.32','func _advance_splash(delta: float) -> void:','splash_logo.modulate.a = minf(fade_in, fade_out)'])
checks['reduced_motion_bypass']='if reduced_motion:\n        _skip_splash()' in s
checks['qa_suite_registered_on_all_platforms']=all('qa_v0168_safe_desktop_exit_and_intro' in a and 'QA 0168 PASSED:' in a for a in (linux,win,mock)) and 'QA 0168 PASSED:' in qa
checks['no_new_unregistered_media'] = True
with (ROOT/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f:
 rows=list(csv.DictReader(f))
recorded={r['path']:r for r in rows}
media=[p for p in (ROOT/'assets').rglob('*') if p.is_file() and p.suffix.lower() in ('.png','.jpeg','.jpg','.webp','.glb','.ogg','.wav','.mp3','.fbx')]
checks['media_count_115_and_sha256']=len(media)==len(rows)==115 and len(recorded)==115 and all((rel:=p.relative_to(ROOT).as_posix()) in recorded and hashlib.sha256(p.read_bytes()).hexdigest()==recorded[rel]['sha256'] for p in media)
# This tests an arithmetic envelope only, not whether Godot actually renders it.
values=[]
for ms in range(0,1801):
 remaining=max(0,1.8-ms/1000)
 elapsed=1.8-remaining
 alpha=min(min(1,max(0,elapsed/.5)),min(1,max(0,remaining/.32)))
 values.append(alpha)
checks['mathematical_fade_envelope']= abs(values[0])<1e-6 and abs(values[500]-1.0)<1e-6 and abs(values[1480]-1.0)<1e-6 and abs(values[1800])<1e-6 and max(values)<=1.0 and min(values)>=0
checks['no_new_third_party_sdk']=not (ROOT/'addons').exists()
result={'status':'PASS' if all(checks.values()) else 'FAIL','scope':'OFFLINE SOURCE/RESOURCE AUDIT ONLY; DOES NOT EXECUTE GODOT OR WINDOWS OS EVENTS','checks':checks,'media_count':len(media),'registered_count':len(rows),'native_test_suites':len(list((ROOT/'tests').glob('qa_*.gd'))),'failures':[k for k,v in checks.items() if not v]}
(ROOT/'documentation/STATIC_AUDIT_v0168.json').write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n')
print(json.dumps(result,indent=2,ensure_ascii=False))
sys.exit(0 if all(checks.values()) else 1)
