# LCG-P05 — Asset / Visual / Functional Audit v0.14.4
Date: 2026-11-20 | Basis: delivered Godot ZIP v0.14.3 + prior conversation PDF

Legend: **PRESENT** = bytes or code exists; **PARTIAL** = implementation exists but content/finish incomplete; **MISSING** = no matching asset or completed feature found; **UNVERIFIED** = Godot runtime/Windows QA unavailable. The list is not a claim of tested gameplay.

| Asset class | Current evidence in ZIP | Important gap / action | Priority |
| --- | --- | --- | --- |
| 🏛 Scene/environment | First-person 3D room created from primitive meshes, windows, floor planks, exterior sidewalk/road; existing furniture props | Room identity, richer storefront, storage/receiving area, believable signage and navigation polish; test collision / lighting | P1 |
| 👤 Characters | 3 Kenney mini-characters in GLB; v0.14.4 randomly uses 3 for shoppers | No verified skeletal walking, distinct idle/browse/pay animations, facial/wardrobe variety or crowd behavior | P1–P2 |
| 🪑 Items/product assets | 9 saleable object types, 20 GLB files total, 9 shelves; existing props re-used further in v0.14.4 | Only 9 product types, repetitive layout, no detailed used-item condition indicators/individual variation | P1 |
| 🎨 Textures/materials | StandardMaterial3D procedural flat colors + embedded GLB materials | No dedicated packaged PBR texture or decal library; need compatible wood/paper/glass variation, not necessarily photo-realistic | P2 |
| 🎬 Animations | Customer bob via script; logo fade/shift via script | No confirmed imported character rigs or walk/checkout/door/stock animation clips | P1 |
| 🔊 Sounds | 4 Kenney UI OGG sound files, 2 loaded for click/sale | Store door bell, footsteps, putting object on shelf, register, packaging and ambience missing | P1 |
| 🎵 Music | 4 CC0 background tracks in ZIP; only `Swinging Sweet.ogg` loaded by code | Additional tracks are unconnected; no tested day/ambience mixing rules, transition logic | P2 |
| 🎙 Voice | No voice recordings/voice scripts | Not necessary for initial management prototype; avoid before dialogue scope is established | P3 / optional |
| 📱 UI | Programmatic Godot Panel/Button/Label menus, HUD, help/settings, tutorial and ledger | No bundled UI atlas/icon set in this ZIP; layout mostly absolute pixels; responsive scale / controller focus / contrast need native QA | P1 |
| ✨ Effects | Basic light + material choices; limited camera/character movement | No transaction feedback VFX, dust/light accents, item pick/placement polish; avoid visual overload | P2 |
| 📜 Story/content | Transaction instructions and short contextual messages | No original NPC stories, customer events or branching script; not required yet to test core loop | P3 |
| 🔤 Fonts | Godot engine default font; no separate font files | No approved packaged font family or multilingual glyph QA; assess actual market languages | P1–P2 |
| 🖼 Studio branding | 2 Little Cozy Games PNGs | No cleared public game title, approved key art/capsule or actual game screenshot package | P2, before launch |
| ⚙ Gameplay | Purchase, stocking, pricing, customer browse/check-out, daily demand, ledger, consignment, pause, tutorial, save logic in 1,758-line script | Code ≠ gameplay verification; no native engine acceptance; no actual Windows executable; limited long-term goal/content breadth | P0 |

## Most urgent blockers
1. **P0 Godot 4 editor/CLI real import and seven QA scripts**: first fix parser/runtime errors, input blockers and save hazards. Static/runner mock tests aren't gameplay tests.
2. **P1 Visual vertical slice**: one storefront entry → desk restock → stock a shelf → customer walk/browse/pay → ledger, with consistent art and sound cues. Verify in-game screenshots before expanding content.
3. **P1 UI font/layout**: small laptop/desktop windows, large text accessibility and high contrast, disabled/enabled states, no clipped price/stock numbers.
4. **P1 Asset consistency**: prefer compatible same-family 3D models and icons over dozens of mixed styles.
5. **P2 depth**: new product categories, shelf condition/rarity, inventory variation, richer audio/environment, only if playtest supports them.

## Important boundary
The previous PDF mentions uploaded competitor video MP4s, one art-direction Markdown and a JPG output, but the actual video/image/document bytes are **not** present in this deliverable. No statement here claims their frames were analyzed or that we reproduced prior visual selections exactly. If available later, compare screenshots before changing this art direction.
