#!/usr/bin/env python3
"""Offline audit for product picture, non-reader cues, data provenance and safe-close wiring.
This test does NOT load a Godot runtime, perform a visual UI playtest, or certify accessibility.
"""
from pathlib import Path
import hashlib,csv,json,re,sys
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SHOP=(ROOT/'scripts/shop.gd').read_text()
META=(ROOT/'project.godot').read_text()
QA=(ROOT/'tests/qa_v0162_picture_catalog_and_safe_close.gd').read_text()
checks={}
media=[p for p in (ROOT/'assets').rglob('*') if p.suffix.lower() in ('.glb','.ogg','.png','.jpg','.jpeg','.webp','.fbx','.wav','.mp3') and p.is_file()]
with (ROOT/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f:
    rows=list(csv.DictReader(f))
paths={r['path']:r for r in rows}
checks['all_115_media_files_registered']=len(media)==len(rows)==115 and len(paths)==len(rows)
checks['all_registered_hashes_match']=all((rel:=p.relative_to(ROOT).as_posix()) in paths and hashlib.sha256(p.read_bytes()).hexdigest()==paths[rel]['sha256'] for p in media)
checks['all_old_85_assets_preserved']=len([r for r in rows if not r['path'].startswith('assets/product_previews_v0162/') and not r['path'].startswith('assets/ui_symbols_v0162/')])==85
checks['27_separate_product_pictures']=all((ROOT/f'assets/product_previews_v0162/product_{i:02d}.png').is_file() for i in range(27))
checks['27_ui_picture_preloads']=SHOP.count('preload("res://assets/product_previews_v0162/product_')==27
checks['picture_and_category_cue_in_each_row']='"picture":product_picture,"icon":category_icon' in SHOP and 'PRODUCT_PICTURE_TEXTURES[i]' in SHOP
checks['buy_stock_bulk_action_icons']=all(f'preload("res://assets/ui_symbols_v0162/{x}.png")' in SHOP for x in ('buy','shelf','bundle'))
checks['pictures_have_readable_content']=all(Image.open(p).size == (112,112) and len(Image.open(p).getcolors(200000) or [])>15 for p in (ROOT/'assets/product_previews_v0162').glob('*.png'))
checks['manual_close_requires_confirmation']='"CLOSE DAY", Vector2(547, 585), Vector2(174, 48), _request_finish_day' in SHOP and 'event.keycode == KEY_N:\n                _request_finish_day()' in SHOP
checks['confirm_can_be_cancelled']=all(f'func {fn}()' in SHOP for fn in ('_request_finish_day','_cancel_finish_day','_confirm_finish_day')) and '"KEEP SHOPPING / ESC"' in SHOP
checks['confirm_stops_game_clock']='customer_bargain_ui.visible or close_day_confirm_ui.visible:\n        return\n    if message_time > 0.0:' in SHOP
checks['camera_speed_is_adjustable']='const LOOK_SPEED_MULTIPLIERS = [0.65, 1.0, 1.25]' in SHOP and 'func _cycle_mouse_speed()' in SHOP
checks['camera_speed_persisted']='"mouse_speed_mode":mouse_speed_mode' in SHOP and 'prefs.get("mouse_speed_mode", 1)' in SHOP
checks['existing_game_content_preserved']=all(x in SHOP for x in ('const PRODUCTS = [','const COMMUNITY_FINALE_SCENES = [','const DAY_EVENT_IDS = [','func _assist_customer() -> void:','func _roll_resident_offer() -> void:','func _save_game() -> bool:'))
checks['no_external_game_sdk_added']=not (ROOT/'addons').exists() and not any(p.name.lower().startswith('firebase') for p in ROOT.rglob('*'))
checks['native_test_integrated']=all('qa_v0162_picture_catalog_and_safe_close' in (ROOT/f'tools/{name}').read_text() for name in ('run_native_acceptance.sh','run_native_acceptance_windows.ps1','selftest_acceptance_runner.py')) and 'QA 0162 PASSED:' in QA
current_match=re.search(r'Internal v(\d+\.\d+\.\d+)', META)
current_version=('v'+current_match.group(1)) if current_match else ''
checks['version_alignment']=bool(current_version) and ('gameplay '+current_version) in SHOP
report={'status':'PASS' if all(checks.values()) else 'FAIL','scope':'STATIC SOURCE/IMAGE/HASH CHECK ONLY; Godot 4 engine runtime NOT executed, accessibility NOT certified','checks':checks,'media_count':len(media),'provenance_count':len(rows),'errors':[k for k,v in checks.items() if not v]}
(ROOT/'documentation/STATIC_AUDIT_v0162.json').write_text(json.dumps(report,indent=2,ensure_ascii=False))
print(json.dumps(report,indent=2,ensure_ascii=False))
sys.exit(0 if all(checks.values()) else 1)
