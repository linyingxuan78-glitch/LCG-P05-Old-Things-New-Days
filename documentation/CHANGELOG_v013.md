# v0.13 · Demand & Recovery Development

**Status:** Godot source modified; static project checks only. Godot engine run not confirmed.

## New gameplay

- Visible daily buying trend: Vintage Tech → Home & Books → Kitchen Finds, repeating. Player sees today's featured goods and tomorrow's forecast before ordering.
- Shopper demand changes with the daily trend. With a 60% chance, the selected candidate pool targets a featured-category product; featured buyers also have a 10% higher **base reference-price multiplier** before the shopper's individual budget variance. This does **not** guarantee a purchase or guarantee profitability.
- Featured-category sales are included in day reports and business ledger.
- Trend is determined from the in-game day and is therefore compatible with existing v0.9–v0.12 saves.

## Save / stability

- On every subsequent save, retain a backup of the last valid JSON save as `user://lcg_p05_shop_v09.json.bak`.
- If the primary save is unreadable or has invalid product array dimensions, fall back to the backup.
- If the previous version saved immediately after closing a day but **before clicking Continue**, detect the matching last ledger date and safely resume at the next day; do not duplicate ledger entries by closing that day twice.
- The original save path is unchanged. No user data is migrated or deleted by a source build alone.

## QA and limitations

- Added `tests/qa_v013_demand_and_recovery.gd` covering category cycling, hot-category sale accounting, ledger, new-day reset and bad JSON handling.
- No Godot binary is installed in this environment; the GDScript tests remain **unexecuted**. Run after asset import and fix any engine-reported errors before release.
- Current economy is simplified. The trend is an internal design feature, not a claim about real demand for game genres.

## Platform

Godot 4 project, not the older browser runtime. No Windows EXE was generated in this build.
