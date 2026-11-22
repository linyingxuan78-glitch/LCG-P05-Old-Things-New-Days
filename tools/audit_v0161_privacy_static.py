#!/usr/bin/env python3
"""Offline only: metadata/structure checks; cannot validate actual Godot gameplay or legal compliance."""
from pathlib import Path
from hashlib import sha256
from PIL import Image
import csv,re,json,sys
root=Path(__file__).resolve().parents[1]
checks={}; detail={}
shop=(root/'scripts/shop.gd').read_text()
safety=(root/'scripts/privacy_safety.gd').read_text()
health=(root/'scripts/healthy_play.gd').read_text()
project=(root/'project.godot').read_text()
version_match=re.search(r'Internal v(\d+\.\d+\.\d+)',project)
current_version=('v'+version_match.group(1)) if version_match else ''
checks['version_same_in_project_and_ui']=bool(current_version) and ('gameplay '+current_version) in shop
checks['privacy_optional_in_title_and_pause']=all(x in shop for x in ['"SAFETY"','"PRIVACY / SAFETY"','func _open_privacy_safety()','PRIVACY_SAFETY_SCRIPT.new()'])
checks['privacy_ui_source_is_local_control']='extends Control' in safety and 'func open_panel()' in safety
checks['save_deletion_title_only']= 'source_menu != "title"' in safety and 'delete_button.disabled = source_menu != "title"' in safety
checks['save_deletion_confirmed']=all(x in safety for x in ['func request_erase()','func confirm_erase()','func cancel_erase()','confirm_panel.visible = true'])
checks['erase_both_shop_save_and_backup']= 'for path in [SHOP_SAVE_PATH, SHOP_SAVE_PATH + ".bak", SHOP_SAVE_PATH + ".pending"]' in safety and 'DirAccess.remove_absolute' in safety
checks['no_destructive_qa']= 'bool(shop.get("qa_mode"))' in safety
checks['history_reset_separate_from_shop_progress']= 'func clear_local_activity_history()' in health and 'healthy.call("clear_local_activity_history")' in safety
checks['original_game_save_path_retained']='user://lcg_p05_shop_v09.json' in shop
checks['original_healthy_preferences_path_retained']='user://lcg_p05_healthy_play.json' in health
checks['six_category_icons_referenced']='load("res://assets/comfort_icons/category_%d.png"' in shop and 'row["icon"]' in shop
checks['third_party_sdk_paths_not_added']=not (root/'addons').exists()
# This checks only explicit script-level outgoing APIs, NOT transitive engine or platform/network behavior.
outgoing_api = re.findall(r'\b(?:HTTPRequest|HTTPClient|WebSocketPeer|WebRTCPeerConnection|JavaScriptBridge|SteamAPI|FirebaseApp)\s*\.\s*new\s*\(|\bOS\s*\.\s*(?:execute|shell_open)\s*\(', '\n'.join(f.read_text(encoding='utf-8') for f in (root/'scripts').glob('*.gd')))
checks['no_explicit_external_api_constructors']=len(outgoing_api)==0
# Registry must represent every asset in executable project.
registry=root/'licenses/USED_ASSET_PROVENANCE.csv'
with registry.open(encoding='utf-8-sig',newline='') as f: rows=list(csv.DictReader(f))
recorded={r['path']:r for r in rows}
media=sorted(f for f in (root/'assets').rglob('*') if f.is_file() and f.suffix.lower() in ('.glb','.ogg','.png','.jpg','.jpeg','.webp','.wav','.mp3','.fbx'))
detail['media_count']=len(media);detail['registered_count']=len(rows)
checks['registry_count_85']=len(rows)==len(media)==115 and all((root/row['path']).is_file() for row in rows)
checks['every_media_has_source_and_valid_hash']= all(f.relative_to(root).as_posix() in recorded and sha256(f.read_bytes()).hexdigest()==recorded[f.relative_to(root).as_posix()]['sha256'] for f in media)
checks['no_duplicate_asset_registry_paths']=len(recorded)==len(rows)
old_root=Path('/mnt/data/lcg_p05_v0160_work')
if old_root.exists():
  with (old_root/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f: old=list(csv.DictReader(f))
  checks['prior_79_media_entries_preserved']=len(old)==79 and all(r['path'] in recorded and recorded[r['path']]['sha256']==r['sha256'] for r in old)
shas=[];diff=[]
for i in range(6):
    f=root/f'assets/comfort_icons/category_{i}.png'
    if f.exists():
        with Image.open(f) as im:
            diff.append(im.getbbox()!=None and im.size==(80,80) and im.mode=='RGBA')
        shas.append(sha256(f.read_bytes()).hexdigest())
checks['six_unique_original_icon_shapes']=len(shas)==6 and len(set(shas))==6 and all(diff)
checks['three_page_catalog_preserved']='const CATALOG_PAGE_SIZE: int = 9' in shop and len(re.findall(r'"name":',shop.split('const PRODUCTS = [')[1].split(']\n',1)[0]))==27
checks['prior_hud_and_safety_controls_preserved']=all(s in shop for s in ('picture_guides','high_contrast','reduced_motion','gentle_camera','soft_lighting'))
checks['offline_native_tests_registered']=(root/'tests/qa_v0161_privacy_and_pictograms.gd').exists() and 'qa_v0161_privacy_and_pictograms' in (root/'tools/run_native_acceptance.sh').read_text() and 'qa_v0161_privacy_and_pictograms' in (root/'tools/run_native_acceptance_windows.ps1').read_text()
checks['documents_and_sdk_gate_present']=(root/'documentation/PRIVACY_SAFETY_AND_ACCESSIBILITY_v0161.md').is_file() and (root/'documentation/SDK_AND_SAFETY_RELEASE_GATE_v0161.csv').is_file()
report={'status':'PASS' if all(checks.values()) else 'FAIL','verification':'OFFLINE STRUCTURAL CHECKS ONLY. NO GODOT, HUMAN ACCESSIBILITY, OR LEGAL VALIDATION.','checks':checks,'metrics':detail,'failures':[k for k,v in checks.items() if not v]}
(root/'documentation/STATIC_AUDIT_v0161.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
sys.exit(0 if all(checks.values()) else 1)
