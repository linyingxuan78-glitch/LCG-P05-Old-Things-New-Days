# Project 05 / Godot v0.10 — Change log and QA boundaries

Changes: 9 shop product shelves each hold 0–6, stock placards, supplier 3-pack purchase with 10% discount unlocked after 3 lifetime sales, shopper demand preferentially samples stocked categories, different customer budgets, no-stock and price-rejection daily counts, daily sales targets with once-only cash bonuses, daily conversion report, audio settings persisted separately from gameplay save, quit-to-desktop button and stale customer cleanup on resume.

QA scripts: `tests/qa_smoke.gd`, `tests/qa_economy.gd`.

Static file integrity and source checks were performed in the authoring environment. Engine compilation/GLB import/3D rendering/UI integration is **NOT** verified because Godot is not installed and outbound downloads are blocked by DNS. Neither the included automated Godot tests nor any Windows EXE have been run or produced.

Important limitations: long-run balance, user testing, native performance and accessibility remain outstanding; game name and logo trademark clearance remains outstanding. This is an internal project, not a commercial release.
