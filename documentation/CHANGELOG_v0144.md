# v0.14.4 — Visual Asset Audit / Scoped Art Integration
Date: 2026-11-20

## Changed in source
1. Reuses previously bundled Kenney CC0 props `bookcaseOpen`, `cardboardBoxClosed`, `desk` and `plantSmall1` in unobtrusive edge/corner shop dressings. No new licenses or files added.
2. Uses all three previously bundled mini-character models as possible customers (instead of two), with the existing movement/behavior preserved. These are only visual variants, not new character animations or NPC AI.
3. Updates development build label to v0.14.4. Leaves save paths and economy logic alone.
4. Separates music attribution from UI-audio attribution, and Furniture Kit from Mini Characters, in `ASSET_REGISTER.csv`. SHA-256s unchanged; previous mixed source strings were too imprecise.
5. Includes art direction, a factual asset/function gap audit, and prioritized downloadable asset list.

## Not verified
Godot engine import/launch, visual placement, collisions/characters at runtime, Windows export, responsive UI, true performance and platform/legal release clearance. Prior strict acceptance scripts remain in the package.

This is a **source integration and art-production management update**, not a validated gameplay release.
