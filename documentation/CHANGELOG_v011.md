# LCG-P05 Godot native v0.11 | 2026-11-16

**Branch:** Godot 4; continues v0.10. Previous v0.9/0.10 `user://lcg_p05_shop_v09.json` saves retained.

## Implemented

- A customer walks through the shop's central aisle to their chosen display shelf and then browses.
- If stock is present and the price is acceptable, the customer walks to the physical cashier counter, waits briefly, pays, then exits.
- If merchandise is unavailable or too expensive, the customer leaves without a sale. Purchases are rechecked at the register to avoid paying for removed/repriced stock.
- A small procedural walk-bob visually distinguishes movement from browsing.
- Closing the shop clears any active visitor and counts them separately as `day_unserved_at_close` in daily settlement; no phantom cross-day transaction.
- Added explicit route/state QA scenarios in `tests/qa_customer_flow.gd`.
- Existing inventory, 3-pack purchase, display upgrades, nine SKUs, separate audio settings and 3D Kenney assets retained.

## Tests and limitations

Source/file-level checks are performed. Godot runtime could **not be installed in the current execution environment**, so `qa_smoke.gd`, `qa_economy.gd` and `qa_customer_flow.gd` are included but **not reported as passed**. Opening the project in Godot 4 is required to verify script compilation, visual correctness, and full QA. No Windows EXE has been built; commercial release is not approved. Internal name LCG-P05 is not legally cleared for branding.

## Run tests after importing the project once

```sh
godot --headless --path . --script res://tests/qa_smoke.gd
godot --headless --path . --script res://tests/qa_economy.gd
godot --headless --path . --script res://tests/qa_customer_flow.gd
```
