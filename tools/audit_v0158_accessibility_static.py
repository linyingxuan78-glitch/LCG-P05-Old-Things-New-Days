#!/usr/bin/env python3
"""Source-only guardrails for v0.15.8; never claim native, medical, or visual certification."""
from pathlib import Path
import json, csv, hashlib, re
root=Path(__file__).resolve().parent.parent
src=(root/'scripts/shop.gd').read_text(encoding='utf-8')
checks={
  'five player-action tutorial steps': all(x in src for x in ['"open_desk", "buy", "stock", "price", "sale"','func _tutorial_event(action: String)']),
  'short picture-led step prompts': all(x in src for x in ['const TUTORIAL_PICTURE_IDS','const TUTORIAL_KEYCAPS','tutorial_icon.texture = load(', 'tutorial_keycap.text =']),
  'tutorial below static guide': 'tutorial_panel.offset_top = 158.0' in src and 'pictogram_panel.offset_bottom = 146' in src,
  'pictogram shape and text states': 'pictogram_labels[index].text = action + (" OK" if enabled[index] else " WAIT")' in src,
  'help has scroll control': 'var guide_scroll := ScrollContainer.new()' in src,
  'seven persisted accessibility toggles': 'accessibility_buttons.size() != 7' in src and '"gentle_camera":gentle_camera' in src and '"soft_lighting":soft_lighting' in src,
  'default reduced motion': 'var reduced_motion: bool = true' in src,
  'user toggles soft lights and camera': 'func _apply_visual_comfort()' in src and 'sunlight_light.light_energy = 0.72 if soft_lighting else 0.95' in src and 'camera.fov = 70.0 if gentle_camera else 74.0' in src,
  'no changes to save location': 'const SAVE_PATH: String = "user://lcg_p05_shop_v09.json"' in src,
  '27 items still in shop catalog': src.count('{"name":')==27,
  'source disclosures and disclaimer': 'Flashing avoided; photosensitivity testing is still required.' in src and 'credits_ui' in src,
  'new genuine Godot script registered': (root/'tests/qa_v0158_visual_comfort_and_tutorial.gd').exists() and 'qa_v0158_visual_comfort_and_tutorial' in (root/'tools/run_native_acceptance.sh').read_text(),
  'fifteen original native QA suites still included': len(list((root/'tests').glob('qa_*.gd')))>=15,
}
with (root/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f:
  rows=list(csv.DictReader(f))
checks['79 media bytes and hashes unchanged']=len(rows)>=79 and all((root/row['path']).exists() and hashlib.sha256((root/row['path']).read_bytes()).hexdigest().lower()==row['sha256'].lower() for row in rows)
report={'scope':'STATIC SOURCE AND ASSET AUDIT ONLY; NO GODOT NATIVE EXECUTION OR PHOTOSENSITIVITY CERTIFICATION','checks':checks,'passed':sum(checks.values()),'total':len(checks)}
(root/'documentation/AUDIT_v0158.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
for k,v in checks.items(): print(('PASS' if v else 'FAIL'),k)
print(f'RESULT {report["passed"]}/{report["total"]} static checks')
raise SystemExit(0 if all(checks.values()) else 1)
