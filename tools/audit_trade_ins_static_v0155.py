#!/usr/bin/env python3
"""Structural checks for v0.15.5, not a Godot native test."""
from pathlib import Path
import re,sys
root=Path(__file__).resolve().parent.parent
src=(root/'scripts/shop.gd').read_text(encoding='utf-8')
checks={
  'single offer decision fields': all(x in src for x in ['resident_offer_index: int = -1','resident_offer_cost: int = 0','resident_offer_decided: bool = false']),
  'offer based on unlocked merchandise': 'total_sales >= int(PRODUCTS[i]["unlock"])' in src and 'candidates.append(i)' in src,
  'cash and carrying validations': all(x in src for x in ['if not _resident_offer_available() or carrying != -1:','if cash < resident_offer_cost:','_shelf_inventory_count(_product_shelf(index)) >= SHELF_CAPACITY']),
  'accounts for spending': all(x in src for x in ['cash -= paid','day_cost += paid','total_wholesale += paid','resident_purchase_spending += paid']),
  'does not bypass stocking': 'carrying = index' in src and 'stock[index] += 1' not in src.split('func _accept_resident_offer()',1)[1].split('func _decline_resident_offer()',1)[0],
  'offer persists across saves': all(f'"{k}":' in src for k in ['resident_offer_index','resident_offer_cost','resident_offer_decided','resident_purchases_total','resident_purchase_spending']),
  'old saves receive a new offer': 'else:\n        _roll_resident_offer()' in src,
  'fresh offer each new day': '_advance_day() -> void:' in src and '_roll_resident_offer()' in src.split('func _advance_day()',1)[1].split('func _close_report()',1)[0],
  'modal pauses gameplay clock and animation': 'community_finale_ui.visible or resident_offer_ui.visible' in src,
  'headless QA defined': (root/'tests/qa_v0155_resident_trade_ins.gd').is_file(),
  'no new third-party media imported': (root/'licenses/USED_ASSET_PROVENANCE.csv').is_file()
}
for key,success in checks.items(): print(('PASS' if success else 'FAIL')+' '+key)
print(f'{sum(checks.values())}/{len(checks)} source checks passed; native Godot not run')
sys.exit(0 if all(checks.values()) else 1)
