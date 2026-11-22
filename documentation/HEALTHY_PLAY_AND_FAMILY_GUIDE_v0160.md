# LCG-P05 v0.16.0 — Healthy play & family guidance

**Status:** Implemented in Godot source; Godot-native tests, UI screenshots and real-player testing remain pending. This document is design guidance, **not medical advice or certification**.

## Research consulted (public official / professional sources, 2026-11-22)

- American Academy of Pediatrics (HealthyChildren.org), *How to Make a Family Media Plan*, https://www.healthychildren.org/English/family-life/Media/Pages/How-to-Make-a-Family-Media-Use-Plan.aspx — families decide when, where and how screens fit with sleep, meals, school and other activities; parental/platform controls can help. No universal minutes-per-child threshold was inferred.
- AAP, *Helping Kids Thrive in a Digital World: AAP Policy Explained* (2026), https://www.healthychildren.org/english/family-life/Media/Pages/helping-kids-thrive-in-a-digital-world-AAP-policy-explained.aspx — considers digital design, content and context, not only duration.
- UNICEF, *RITEC Design Toolbox*, https://www.unicef.org/childrightsandbusiness/workstreams/responsible-technology/online-gaming/ritec-design-toolbox — child well-being as a design criterion.
- UNICEF, *Recommendations for creating digital environments in children's best interests* (2026), https://www.unicef.org/malaysia/media/7001/file/UNICEF-Innocenti-Children%27s-Best-Interests-Digital-Policy-Practice-report-2026.pdf — age-appropriate, clear, accessible information including visual explanations and privacy-by-design.
- Microsoft Xbox, *XAG 118 — Photosensitivity*, https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118 — avoid flashes as a primary risk control; warnings alone are not a substitute for testing.

## Implemented (source-level)

- `scripts/healthy_play.gd` is a self-contained, local-only preference and active-time module, accessible from title screen `PLAY TIME` and pause screen `HEALTHY PLAY / FAMILY`.
- Rest/hydration cues configurable **15/25/40 minutes or OFF**; **25 minutes default is a design preference**, not a medical recommendation.
- Daily family-plan cue configurable **60/90/120 minutes or OFF**; **90 minutes default is not an authoritative child screen-time limit**. It fires only once per local date, and the setting is an **advisory reminder**, never a lock, punishment or account-based parental control.
- Short non-flashing, non-forced toast includes plain words `REST / WATER` and a short pause message. It is not a timed challenge, reward or engagement mechanic.
- Local preferences and play duration stored in `user://lcg_p05_healthy_play.json`. No player name, birthday, identity, account or Internet upload. Last exit time enables an optional *one-time* gentle reminder for quick re-entry after a previous five-minute session; do not pressure a player to stay.
- Counting is for active foreground gameplay: exclude title screen, paused game, focus loss and health menu; per-frame delta capped to prevent inflated time after app suspension. The time is approximate and depends on the device clock and local storage.
- Existing shop save `user://lcg_p05_shop_v09.json`, audio/accessibility settings and assets remain unchanged. Five-step onboarding, reduced-motion, high-contrast, and soft lighting are preserved.

## Not implemented / limitations

- **No legal age verification, secured parental PIN, enforceable family limit, external caregiver dashboards, cross-device aggregation, or online account tracking.** This game cannot enforce guardian decisions. Device/platform parental controls must be used for that purpose.
- Not a medical intervention or diagnosis for gaming disorder, eye conditions, ADHD or seizures.
- The reminder remains text-led. **No complete picture-only / non-reader mode, multi-language localization, text-to-speech or screen-reader certification yet.** Additional language and usability design and testing are required.
- **No real-device flash/contrast/motion assessment, accessibility user trials, native Godot import/runtime pass or Windows exported EXE.** Static source inspection cannot certify comfort or safety.

## QA / review checklist

1. Start a game and observe the foreground play timer (menus may remain open but the play clock must stop when paused or unfocused).
2. In `PAUSE > HEALTHY PLAY / FAMILY` change break interval and daily reminder (including OFF). Resume without losing stock/cash.
3. Play until configured interval; confirm one **non-flashing**, dismissing toast without forcing cursor release or game over.
4. Let a daily reminder show once, return to title, reopen and confirm local daily total persists; check midnight rollover.
5. Close and reopen within ten minutes after >5 minutes active play; confirm at most one gentle return note.
6. Verify controller/keyboard focus, small screens, text wrapping, high contrast, color-vision simulation, photosensitivity risk and language comprehension with real target users.
7. Run real Godot headless QA including `qa_v0160_healthy_play.gd`, and separately perform hands-on test on Windows. Do not infer efficacy from static checks.
