# LCG-P05 v0.15.9 — Context-First Store Operation

## Design goal
Support people unfamiliar with PC games, readers with limited English, and players who struggle to aim with a first-person crosshair. Keep every action optional, non-flashing, and fully within the existing world simulation.

## Delivered in Godot source
- A **single world-space Label3D** shows a still downward arrow and `E PLACE` above the correct shelf only while holding goods and with PICTURE GUIDE enabled. Reusing a single node avoids changing geometry or rendering one marker at every shelf.
- A **context card with an existing pictogram** appears near the lower center: counter → open desk; carried item → find marked shelf; near matched shelf → E place; assistance case → E help; viewing stocked shelf → plus/minus price. Only the relevant action is shown.
- **Proximity placement**: E places the item only when the player is within 2.25 ground-plane units of its correct shelf. An explicit counter interaction takes precedence. The existing raycast path and desk STOCK button remain valid. Cash, carried item, stock limits and save logic are unchanged; shared shelf capacity is still enforced inside `_stock_from_desk`.
- All new prompts can be hidden with the existing PICTURE GUIDE setting. No new save keys; existing saved settings and purchases remain compatible.

## Known gaps, not yet certified
- Godot 4 native engine was not available for this build: 3D occlusion, collision, camera legibility, font fallback for the down-arrow and actual user experience have **not** been observed.
- Still uses English in stock catalogs, subtitles and pricing; this is not a full no-reading / multilingual interface.
- No real-user accessible playtesting, photosensitivity analysis or epilepsy risk certification. Visual cues were intentionally made static and non-pulsating.
- Users on a small display might still find the large 27-item catalog too dense; the guide is an incremental aid, not a full UI redesign.

## Release criteria
1. Import and run in Godot 4.4+ editor; execute QA 0159 and all earlier suites.
2. In a 3D scene, verify target sign can be seen without going through walls, doesn't hide products or signage, and doesn't obstruct the player's view.
3. Verify from several orientations that E stocking requires proximity to the matching shelf; E at the desk still opens the desk.
4. Test non-English readers, color-vision differences, keyboard navigation and readable UI at 720p/1080p; avoid relying only on color.
5. Perform frame-based photosensitivity review on actual video output and visual comfort testing. This code alone makes no medical safety claim.
