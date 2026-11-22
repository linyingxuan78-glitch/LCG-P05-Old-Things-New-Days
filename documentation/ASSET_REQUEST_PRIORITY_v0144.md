# Asset acquisitions — What to download/upload, and only when needed
This is a **targeted list**, not a request for a huge dump. Keep original ZIP + each pack's LICENSE/README inside uploaded archives so we can prove source/terms. Prefer CC0 and one cohesive Kenney low-poly family. The user previously requested ~99% reliance on existing freely commercial-licensed assets where possible; this is a **sourcing preference**, not a mathematical test of asset count.

## Download / upload next (P1)

**1. Kenney Mini Market** (3D shop-specific accessories and goods)
- https://kenney.nl/assets/mini-market
- Download the ORIGINAL whole ZIP including license. We can inspect its exact models first, then choose matching doors, shelves, product/checkout props.
- Reason: current 3D world includes just a few shop-specific meshes and nine product types. This likely adds the largest amount of useful store identity per pack.

**2. Kenney UI Pack** (2D UI elements)
- https://kenney.nl/assets/ui-pack
- Download original ZIP including license. The earlier conversation recorded the pack as audited, but the current delivered Godot ZIP contains NO UI Pack PNG atlas/icon files (only the two studio branding PNGs). Re-upload is necessary if the old archive cannot be retrieved.
- Reason: current screen UI is rendered with stock buttons and labels; a cohesive pack can improve readability and in-game identity, after Godot runtime checks.

## Optional (P2, after engine starts successfully)
**3. Kenney Retro Urban Kit** (outside street/store façade props)
- https://kenney.nl/assets/retro-urban-kit
- Reason: exterior is a basic primitive road + two trees. This improves visible neighborhood without committing to a new game type.

**4. Sound effects**: Need one short **door bell**, **footsteps**, **put item down**, **register/coins**, **subtle retail ambience**. The 4 Kenney UI effects already cover click/sale placeholders. Choose exact CC0 items from one reputable source with their license and original links; do NOT upload random uncredited TikTok/YouTube music.

**No immediate need**: expensive concept artist, game poster, player voice acting, cinematic CG, advanced animation library, DLC, 8K photoreal textures, unrelated fantasy/anime packs.

## Intake safety checklist
- Exact source URL and author; source archive and embedded license; specific CC0/other terms validated for commercial use; avoid NC and uncertain third-party assets.
- Preferred GLB/GLTF (check materials and actual dimensions), PNG with alpha for UI, OGG/WAV for SFX, OFL/cleared font files if needed.
- Verify Godot compatibility, coherent visual scale, texture color palette, performance, no embedded external brand/trademark, and no license limitations on redistributing raw assets by themselves.
- Add used assets to `documentation/ASSET_REGISTER.csv` with SHA-256 and where the model appears; keep originals separately and don't claim exclusive ownership.
