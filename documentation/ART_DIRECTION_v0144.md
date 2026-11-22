# LCG-P05 · Visual Art Direction v0.14.4
Date: 2026-11-20 | Internal prototype decision | Not commercial artwork approval

## Evidence / origin
- The supplied conversation PDF preserves the user's request to compare many styles and competitor recordings, and names an earlier `LCG_P05_Visual_Art_Direction_2026-11-16.md`. However, **that earlier document's body and the original MP4 recordings are not embedded in the currently accessible PDF/ZIP**; this file must **not** be represented as an exact reconstruction of the earlier art director's findings.
- What *can* be inspected: 1,758 lines of current game script, 20 bundled GLB assets, 8 OGG files, 2 studio branding PNG files, copyright records and test source.
- This is a **new provisional art direction**, selected to fit the first-person 3D camera, established cozy-color scene and Kenney CC0 asset family. Change only after verified playtest/business evidence or real footage review.

## Game Art Style: Stylized Cozy 3D (soft low-poly)
- Genre/experience: small second-hand/resale store management with everyday vintage treasures.
- 3D perspective: **first-person**, not 2.5D isometric. Maintain readable spatial aisles and product displays; don't remodel the controls into isometric perspective without formal approval.
- Silhouettes: rounded/simple low-poly primitives, recognizable objects, light material variation, no photorealistic PBR target.
- Character vocabulary: Kenney Mini Characters, simple and friendly shapes; less facial detail, more readable poses.
- Environment: sage-green fixtures, walnut plank floor, warm ivory walls, muted brass details, soft daylight and warm interior fills.
- UI: flat modern utility panels, clear hierarchy, readable typographic scale, no decorative lettering obscuring financial values. Reuse one button/icon family.
- Lighting: soft, warm, preserve price-tag legibility and avoid blown highlights. Confirm in engine before approving any final color/contrast claims.

## Palette (existing source code colors)
| Role | Hex | In source |
| --- | --- | --- |
| Display niche / fixture | `#82917B` | GreenInset and ShelfFrame |
| Wood floor | `#A57754` | Floor |
| Wall / warm ivory | `#EFE8DC` | LeftWall etc. |
| Brass / shelf trim | `#BEA16E` | ShelfBoard and Counter accents |
| Deep green | `#25302C` | BackFeature and ShelfTop |
| Window tint | `#AFD5D5` | Window (transparent material used) |
| Off-white lettering | `#F4EEE1` | Menu title |

## Concept Art / Key Art distinction
1. Concept art is for controlling decisions on room zones, shopper silhouette, goods, retail mood and UI hierarchy. Detailed paid key art is **not required** to reach a playable internal prototype.
2. In-game art is a consistent series of actual engine-rendered meshes, materials, effects and interface components, not a standalone poster.
3. Key art is cover/capsule/promotional illustration **after** game identity/title, real gameplay value proposition and display composition are verified. `LCG-P05 SHOP LAB` is an internal label only; retired `Second Chance Shop` is not a release name.

## Style exclusions and rationale
- No full photorealism or cinematic hyperrealism: asset cost, lighting/performance and coherence risk are disproportionate at this phase.
- No 2.5D isometric camera: would change first-person game interactions significantly.
- No manga portraits, watercolor background, pixel furniture mixed with low-poly props: inconsistent game-world visual language.
- These choices are development constraints, **not** proven claims about commercial demand.

## In-engine art quality gate
- Verify true Godot import, 1280x720 and other common window sizes, text fit/overflow, visual scale, scene navigation, path clearance, lighting, frame pacing and materials.
- Capture real screenshots labeled “in-game” **only after** Godot has actually run; concept drawings are always labeled “concept”.
- Maintain an asset provenance register and separate allowed commercial use from ownership. Preserve CC0 sources and avoid misleading exclusive-original claims.
