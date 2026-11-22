# LCG-P05 v0.16.1 — Child privacy, family safety & pictographic UI

**Scope:** Godot desktop-first, single-player offline prototype. This is an engineering design review, NOT a legal opinion, privacy certification or platform age-rating approval.

## What is actually in this game

- 27 product SKUs remain active, with six **visually distinct shapes**, not merely six colors. Small icon art is generated specifically for this project, not downloaded from another artist. Existing English names, prices and category labels stay as optional supplementary text; full independent play for a non-reader remains **unverified and incomplete**.
- Main menu `SAFETY` and pause menu `PRIVACY / SAFETY` open the **optional**, readable privacy and family guide. It does not ask a child for their birthday, email, photo, ID or location. It does not show up compulsorily at every launch.
- `CLEAR PLAY-TIME HISTORY`: resets same-device usage counters but preserves the chosen reminder intervals and shop progress. The module still saves its zeroed/updated local JSON preferences; it is not a remote erasure.
- `DELETE LOCAL SHOP SAVE`: available **from the title only** and requires a separate confirmation. Deletes the local save file and its internal `.bak`. Leaves audio/accessibility preferences and play-time reminder preferences alone; these can be managed separately. It does **not** delete external/cloud backups, downloaded copies, platform-owned player data, or data outside the game's directory.
- No game account or in-game authentication, no chat, multiplayer, public profiles, friends, ad/tracking/analytics SDKs or data-sending code has been added. This is a **current-code observation**, not a promise about future release packages or a security audit of the game engine/platform.
- Local JSON saves are **not encrypted**, and filesystem access can expose or change them. No illusion of cryptographic privacy is provided. Windows store accounts / operating system permissions are not controlled by this game.

## Why no mandatory ID or login?

An offline shop game does not require an additional game account or real-name validation for the core experience. COPPA and other privacy/child regulations may apply to child-directed online services and collection of covered personal information; they do **not** mean the designer should automatically collect identity information from everyone. Any future online platform, cloud sync, shop, ads, payments, user-generated content, accounts, chat or analytics will require a fresh legal and technical review, and some storefronts have distinct age/audience and content requirements.

## Third-party SDK gate: ask *before installing*

Before adding a new SDK, advertiser, cloud login, telemetry/crash service, social sharing, or parental controls provider:

1. Identify the service, version, publisher, endpoints, data it reads/transmits, persistent IDs, device permissions, age/audience expectations, retention and deletion options.
2. Decide whether it is **necessary** for the core offline game. The default is **do not integrate**.
3. Read the platform policies for the intended audience and verify parental consent/age flows if the actual features and region require them. A fake age selector or self-declared 'parent approved' button is not a legal substitute.
4. Complete an accurate, player-friendly privacy policy and storefront disclosures (including third parties), provide a usable contact and response path, secure transmissions if used, and test account/data deletion.
5. If online chat, UGC, multiplayer or public uploads are added, design reporting, blocking, moderation, abuse handling, and guardian controls before enabling these features.

## Accessibility and low-literacy limitations

Xbox Accessibility Guidelines recommend interactive, revisitable tutorials, meaningful icon+text combinations, low reading demand and screen narration support. The new icons aid category recognition but they **do not** make all 27 products distinguishable for a non-reader; buying, pricing and settings are not fully icon-only, and no screen reader or audio narration feature is complete. Avoid textless buttons that force guessing, and test with real players. Similarly, default low motion and no deliberate flashing **do not certify photosensitive safety**; test actual rendered scenes on real hardware before release.

## Official resources reviewed (22 Nov 2026)

- FTC (US), COPPA FAQ and regulation: https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions
- ICO (UK), Children's Code: https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/
- UNICEF, Children's rights and online gaming: https://www.unicef.org/childrightsandbusiness/reports/childrens-rights-and-online-gaming
- Malaysian Personal Data Protection Department, PDPA 2010 + 2024 amendment and 2026 Privacy by Design guidance: https://www.pdp.gov.my/en/akta/pdp-act-2010-en/ and https://www.pdp.gov.my/en/akta/data-protection-by-design-guideline-dpbd/
- Google Play Families Policies (app/mobile only, not a substitute for a Windows desktop review): https://support.google.com/googleplay/android-developer/answer/9893335?hl=en
- Steamworks authentication: https://partner.steamgames.com/doc/features/auth
- Xbox Accessibility Guideline 109 & 114: https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/109 and https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/114

## Release blockers

Godot native import and real screenshot/interaction validation **not run** in this environment; no Windows EXE. Complete runtime smoke tests, corrupt-save QA, real display scaling/input focus, underage/guardian usability, seizure/light-change analysis, actual storefront policy/legal review and audit of every SDK before a public build. Product name/trademark and licenses must also be finally reviewed.
