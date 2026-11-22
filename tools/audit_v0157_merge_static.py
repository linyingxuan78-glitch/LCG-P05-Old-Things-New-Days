#!/usr/bin/env python3
"""Check cloud feature preservation and new spatial UX wiring. NOT a Godot engine test."""
from pathlib import Path
import csv, hashlib, json, re
r=Path(__file__).resolve().parents[1]
s=(r/'scripts/shop.gd').read_text()
checks={
 'twenty-seven goods': s.count('{"name":') == 27,
 'daily random events retained': all(k in s for k in ['DAY_EVENT_IDS = ["rain"','DAILY_EVENT_CHANCE: float = 0.30','EVENT_MIN_GAP_DAYS: int = 3','func _roll_day_event()']),
 'negotiations retained': all(k in s for k in ['func _open_customer_bargain()','func _accept_customer_bargain()','"negotiating":','customer_agreed_price']),
 'readable picture guides retained': all(k in s for k in ['func _create_picture_guides(','picture_guides: bool = true','compact_hud: bool = false']),
 'six characters anti-repeat': 'last_customer_appearance' in s and 'appearance_pool.size() - 1 if last_customer_appearance < 0' in s,
 'physical cashier counter E': all(k in s for k in ['checkout_counter.set_meta("kind", "desk")','func _looking_at_counter()','if _looking_at_counter():','_toggle_desk()']),
 'head-placed feedback markers': all(k in s for k in ['shopper_reaction = Label3D.new()','shopper_reaction.billboard = true','shopper_reaction.text = "E ?"','shopper_reaction.text = "+"']),
 'alternative help requires real stock': all(k in s for k in ['func _find_customer_alternative()', 'stock[i] > 0 and prices[i] <= customer_budget', 'func _player_can_assist_customer()', 'customer_phase == "needs_help"']),
 'help no forced transaction': 'func _assist_customer()' in s and 'customer_phase = "enter"' in s and 'if customer_phase != "needs_help"' in s,
 'bargains and help both available': 'elif _can_offer_bargain() and rng.randf() < 0.45:' in s and 'if _find_customer_alternative() >= 0 and rng.randf() < 0.28:' in s,
 'help timeout stays at checkout': 'if stock[customer_target] > 0 and prices[customer_target] <= customer_budget:' in s and 'customer_phase = "pickup"' in s,
 'save compatibility': all(k in s for k in ['"version":','"day_assisted_shoppers"','"total_assisted_shoppers"','data.get("day_assisted_shoppers",0)']),
 'customer feedback retained': 'day_feedback = {"pleased":0,"missing":0,"expensive":0}' in s,
 'shop credit optional': 'func _show_credits()' in s,
 'community finale retained': 'func _community_finale_unlocked()' in s,
 '14 QA scripts and preserved v0156 QA': (len(list((r/'tests').glob('qa_*.gd'))) >= 14 and (r/'tests/qa_v0156_events_and_usability.gd').is_file() and (r/'tests/qa_v0157_customer_help.gd').is_file()),
 'no remote runtime game assets': 'http_request' not in s.lower(),
}
with (r/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f:
 rows=list(csv.DictReader(f))
checks['all media bytes have original hashes']= all((r/row['path']).exists() and hashlib.sha256((r/row['path']).read_bytes()).hexdigest().lower() == row['sha256'].lower() for row in rows)
checks['all 79 media declarations retained']=len(rows)>=79
report={'verification':'STATIC ONLY, NOT GODOT ENGINE','passed':sum(checks.values()),'total':len(checks),'checks':checks,'audited_media_count':len(rows)}
(r/'documentation/AUDIT_v0157.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
for k,v in checks.items():print(('PASS' if v else 'FAIL'),k)
print(f'RESULT: {report["passed"]}/{report["total"]} source & file checks')
raise SystemExit(0 if all(checks.values()) else 1)
