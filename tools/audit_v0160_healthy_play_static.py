#!/usr/bin/env python3
"""v0.16.0 offline wiring/license and privacy audit; NOT real gameplay validation."""
from pathlib import Path
import json, csv, hashlib, re
root=Path(__file__).resolve().parent.parent
shop=(root/'scripts/shop.gd').read_text(encoding='utf-8')
well=(root/'scripts/healthy_play.gd').read_text(encoding='utf-8')
linux=(root/'tools/run_native_acceptance.sh').read_text(encoding='utf-8')
win=(root/'tools/run_native_acceptance_windows.ps1').read_text(encoding='utf-8')
checks={
 'health module loaded in one Godot shop project': 'HEALTHY_PLAY_SCRIPT.new()' in shop and 'ui_root.add_child(healthy_play)' in shop,
 'title health menu': '"PLAY TIME"' in shop and 'func _open_healthy_play' in shop,
 'pause family-health menu': '"HEALTHY PLAY / FAMILY"' in shop,
 'pause+escape modal does not leak movement': 'healthy_play.call("is_open")' in shop and 'healthy_play.call("close_panel")' in shop,
 'break choices are adjustable, off included': 'const BREAK_OPTIONS: Array[int] = [15, 25, 40, 0]' in well,
 'daily choices are adjustable, off included': 'const DAILY_OPTIONS: Array[int] = [60, 90, 120, 0]' in well,
 'hydration cue implemented without flashing or forced game exit': 'REST / WATER BREAK' in well and 'toast_seconds = 9.0' in well and 'get_tree().quit' not in well,
 'daily cue fires once until day rollover': 'not daily_notice_seen' in well and 'daily_notice_seen = true' in well and 'daily_notice_seen = false' in well,
 'foreground focus counted and suspended delta capped': 'DisplayServer.window_is_focused()' in well and 'clampf(delta, 0.0, 0.25)' in well,
 'shop economy also stops on window focus loss': 'if not playing or not DisplayServer.window_is_focused() or report_ui.visible' in shop,
 'no age identity or account required': 'PREFERENCES_PATH' in well and not any(x in well for x in ['HTTPClient','HTTPRequest','get_http_client','user_email','account_id','birth_date','phone_number']),
 'local health prefs distinct from gameplay save': 'user://lcg_p05_healthy_play.json' in well and 'user://lcg_p05_shop_v09.json' in shop,
 'exit/return reminder does not reward engagement': 'RECENT_RESTART_SECONDS' in well and 'pending_return_notice' in well and 'WELCOME BACK  /  REST' in well,
 'guardian limitation disclosed': 'not a password-protected lock' in well and 'For enforceable limits' in well,
 'new native QA wired both OS runners': 'qa_v0160_healthy_play' in linux and 'qa_v0160_healthy_play' in win and (root/'tests/qa_v0160_healthy_play.gd').exists(),
 'previous 16 QA suites retained': len(list((root/'tests').glob('qa_*.gd'))) >=17,
 'base 27 products unaffected': shop.count('{"name":')==27,
 'MVP community finale retained': 'COMMUNITY_FINALE_SCENES' in shop and 'community_finale_seen' in shop,
 'save path remains the v09 path for compatibility': 'const SAVE_PATH: String = "user://lcg_p05_shop_v09.json"' in shop,
 'source research and safety caveats documented': (root/'documentation/HEALTHY_PLAY_AND_FAMILY_GUIDE_v0160.md').exists(),
}
with (root/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f:
    rows=list(csv.DictReader(f))
checks['all 79 media files retained with matching provenance']=(len(rows)>=79 and all((root/row['path']).is_file() and hashlib.sha256((root/row['path']).read_bytes()).hexdigest().lower()==row['sha256'].lower() for row in rows))
report={'scope':'STATIC-ONLY: not a Godot run, child-wellbeing outcome trial, photosensitivity test, or certification',
        'passed':sum(checks.values()), 'total':len(checks),'checks':checks}
(root/'documentation/STATIC_AUDIT_v0160.json').write_text(json.dumps(report,indent=2)+'\n')
for key,val in checks.items():print(('PASS' if val else 'FAIL'),key)
print(f"RESULT {report['passed']}/{report['total']} static checks")
raise SystemExit(0 if all(checks.values()) else 1)
