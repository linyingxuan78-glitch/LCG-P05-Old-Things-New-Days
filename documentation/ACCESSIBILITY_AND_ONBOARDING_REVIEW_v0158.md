# LCG-P05 v0.15.8 — Accessibility, onboarding, visual comfort (design + source audit)

**Status: DEVELOPMENT CODE ONLY.** The editor/runtime is unavailable in the current environment. All findings below distinguish changed GDScript from actual on-screen testing. None of these additions certify that the game is seizure-safe or accessible to every player.

## 1. What was already there in v0.15.7

- An event-driven 5-step tutorial (desk → buy → stock → price → first sale), replayable via Help and skippable.
- Four static process pictograms, larger-text toggle, contrast toggle, reduced-motion toggle, compact HUD, F1 help, visible keyboard focus borders.
- Six 3D customer models (no separate 2D portrait system), 27 sellable SKUs, optional Credits, a community-day optional ending.
- Limitations: tutorial was still text-heavy and in English; panel overlapped the pictogram area; help text was longer than its fixed container; old reduced-motion setting defaulted to OFF; no in-game spoken narration, multilingual UI or independent photosensitivity testing.

## 2. This version's actual changes

- **Picture-led onboarding:** 5 steps each show a static pictogram, a short action/key label, and a simple one-sentence instruction. Still driven by real actions, not a mandatory video. Existing skip/replay and save data retained. The tutorial appears *below* the separate four-picture guide instead of covering it.
- **No color-only status:** each pictogram now adds `OK`/`WAIT` text as a second differentiator alongside brightness. This is not a validated full color-vision accessibility solution.
- **Readable help:** controls guide is scrollable, so its text is not limited by a fixed-height label.
- **Comfort options before play:** the existing Settings entry on the title menu adds `GENTLE CAMERA` and `SOFT LIGHTING`. When on, FOV is 70 vs 74, horizontal/vertical mouse look sensitivity is 78% of normal, directional light energy is 0.72 vs 0.95, and ambient energy is 0.74 vs 0.82.
- **Default comfort:** fresh settings default to reduced motion ON, gentle camera ON, and soft lighting ON. Reduced motion already skips the animated logo intro and prevents cosmetic customer bobbing where applicable; player-controlled movement and essential animation remain.
- Preferences persist in the **separate settings JSON**. Existing saves and economy behavior are not changed. Players can turn options off.
- First-session accessibility text explicitly says there are no intentionally designed strobe effects, **but photosensitivity testing is pending**.

## 3. Accessibility scope, and what is NOT complete

| Group or need | Implemented in source | Outstanding before promising support |
|---|---|---|
| New players / onboarding | Optional event-driven 5 steps, pictures + keycaps, replay/skip | Native tutorial walkthrough with beginners, placement and legibility checks |
| Color vision differences | Icons have shapes and textual OK/WAIT; contrast setting | All UI states and in-world signs in simulated color-vision conditions; independent usability feedback |
| Non-readers / young children | Four pictograms, icon per tutorial step, direct spatial E interaction | Full menu and 27-product catalog still rely on English; narrated/audio/haptic instructions and icon-only pathways absent |
| Low literacy / language differences | Shorter prompts, static pictograms | Actual localization, readable symbols for all menus, non-text tutorials, native language playtesting |
| Photosensitive seizures | No intentional strobes or flashing objective markers; reduced intro motion on by default | Dedicated captured-gameplay testing for luminance/red flashes, scene/camera effects and hardware rendering; no safety guarantee |
| Glare / visual comfort | Soft static lighting toggle, high contrast, gentle camera; no added glow | Physical monitor/brightness assessment and comfort feedback; possible additional brightness slider |
| Motion sensitivity | Reduced motion on by default and optional slower look | View bob/FOV/turning/animation observation during real play, sensitivity preferences and further controls |
| Vision impairment | Text scaling and keyboard focus indicators | Screen reader support is not implemented; voice and contrast verification outstanding |

## 4. External expert guidance used as a DESIGN GUIDE, not a certification

- **W3C WCAG 2.2, Understanding 2.3.1** (flashes): https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold.html . Its flash-limit model is written for web content; we choose to avoid intentional strobing in the game instead of treating the numeric threshold as a safety certificate.
- **Microsoft Xbox Accessibility Guideline 103**: https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103 . Game-critical cues should not be differentiated by color alone.
- **Microsoft Xbox Accessibility Guideline 118**: https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118 . All games should undergo photosensitive seizure trigger testing even without intentional flashes.
- **Microsoft XAG 101**: https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/101 . Text legibility needs actual measurement and testing.
- **IGDA Game Accessibility SIG**: https://igda-gasig.org/get-involved/sig-initiatives/resources-for-game-developers/sig-guidelines/ . Tutorials, immediate feedback, and replayable help benefit new players.
- **Epilepsy Foundation**: https://www.epilepsy.com/what-is-epilepsy/seizure-triggers/photosensitivity . Reactions depend on multiple visual factors; no developer should promise risk-free play.

## 5. Native and pre-release QA checkpoints (not yet executed)

1. Import/start the Godot 4.4 project and run all **15** `qa_*.gd` scripts, especially `qa_v0158_visual_comfort_and_tutorial.gd`.
2. Review live UI at 1280×720, 1920×1080, and smaller supported resolutions; inspect 5-step tutorial, no overlaps and scrollable help.
3. Confirm all `OK`/`WAIT` statuses remain clear without color, validate color-vision simulation and contrast/text scaling with actual captured renders.
4. Record gameplay across full day and ending, examine for flashes/strong pattern changes (including rapid scene changes, stuttering light and alpha changes). Obtain appropriate qualified accessibility review if feasible.
5. Walk through the entire loop with a new player who reads little English. Do not claim “non-readers can complete the game” until verified in playtesting.
6. Test camera discomfort and glare with default and alternative settings on real monitors. Verify settings persist across restarts and do not affect shop cash, goods or saves.
7. Confirm normal shutdown and eventual Windows EXE export; complete final licence notices in the actual player release.

**Current acceptance:** Source changes, 79 media checks and test-runner control simulations can be checked offline; no Godot-native runtime or epilepsy-risk certification has taken place.
