# v0.12 · Stability, Cash Rescue & Management Tools

- Migrated directly from the Godot v0.11 project; preserved shop, assets and legacy save path.
- Added supplier-funded one-unit consignment only for genuinely stranded players with no owned inventory and insufficient cash to buy an unlocked product. Supplier $5 due only upon sale; prevent consignment below-cost pricing.
- Added supply ownership tracking and supplier settlement counters in day costs, all-time spend and save data.
- Added pause/save/audio/menu flow, with proper return to the pause screen from audio settings; gameplay timers and movement halt during pause.
- Added 14-day capped business ledger with revenue, supplier outlays, owned stock cost and daily cash changes.
- Added a short, no-GIF in-engine fade/slide effect to the existing Little Cozy Games splash logo.
- Added backward-compatible defaults for v0.9–v0.11 saves missing new fields.
- Added Godot-native QA script for insolvency recovery, settlements, ledger idempotence and pause UI behavior.

**Acceptance status:** Source, resource and archive checks performed. Godot CLI runtime unavailable; engine execution and Windows export not yet verified.
