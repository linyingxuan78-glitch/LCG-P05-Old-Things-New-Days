# LCG-P05 · Picture-first real-world thrift events (single canonical game)

**2026-11-23 · implementation audit · NOT yet public-release clearance**

## What is actually implemented

A single reusable optional `scripts/secondhand_events.gd` UI module, integrated into the existing 27-product, nine-shelf first-person store. **Seven situations** were adapted from common secondhand-retail work processes, with **two clickable outcomes each** and one follow-up backroom clearing mode.

| Situation shown in-game | Picture-first choices | Actual game consequence |
|---|---|---|
| Excess clothes when recycling collection is not available | Hanger/free rack vs storage box | Up to two boxes are put in the back room. On a free-rack choice, **0–2 boxes** may be taken depending on deterministic day/progress; no guarantee all donated clothing finds a home. |
| Used electrical item needs checking | Inspection symbol vs storage | A small inspection fee; only a tested, passing item can be displayed, otherwise remains off the shelf. |
| A private keepsake accidentally included with donations | Return arrow vs safe box | Return through a private procedure, or secure it off sale. No exposing a real person's private data. |
| Missing item price label | Magnifier/check vs holding box | Check the label before selling, or take item off sale; neither option invents a sale. |
| Mixed-condition donated batch | Sorting boxes vs decline | Pay a small sorting fee and display a usable clothes bundle only if the shared shelf has room, or decline. |
| A blocked shopping aisle | Clearing broom vs leave for later | Small handling cost and goodwill benefit, or reduced goodwill. |
| Secondhand chair needing repairs | Repair symbol vs reuse parts | Small paid repair may create one sellable chair only when there is shelf room; otherwise process parts, never falsely present damaged goods as repaired. |

The scenarios are **original educational adaptations**, not verbatim scripts or biographies of real people. Shop stock never exceeds the existing six-unit-per-shelf capacity; cash never goes below zero for purchase choices. First two days remain a calm tutorial. A new optional incident can appear **only every third business day**, and the player must voluntarily open it through the `SORT` button on the existing shop desk. No compulsory story pop-ups or flashing visual effects.

## Low-literacy and accessibility design

- **Ten original SVG pictograms** (shirt/free rack, box, check/inspection, return arrow, repair, sorting bins, broom/clear path, care/heart, money, speaker). Sourced within this project, all registered with individual SHA-256 in `licenses/USED_ASSET_PROVENANCE.csv`.
- One **large familiar item picture** from the existing 27 product preview textures per incident.
- Two **large icon-first decision buttons**, each with 1–2 brief words plus an optional longer hover explanation; no multi-page reading requirement for the decision menu.
- **Immediate visible currency / backroom / neighbour-goodwill counters**, each alongside a distinct symbol (not communicated only through colour). The outcome remains visible until the player selects CONTINUE.
- Tab / Shift+Tab keyboard control and an explicit initial focus are handled using the same previously tested menu system. ESC returns to the shop desk. No active audio or mouse precision is needed to make a choice.
- **Known limit:** Icons and short labels are a meaningful improvement but NOT a fully non-reading playable game. Full voice narration or accessible voice alternatives, recognition testing with non-readers and low-age players, full key remapping and complete 200% adaptable text are not yet implemented or certified. Avoid marketing claims of complete accessibility.

## Source-linked real-world context

- [ABC News, 22 July 2024, Becc Bird and Sam Bradbrook](https://www.abc.net.au/news/2024-07-22/pressure-on-fabric-recycling-system-and-local-op-shops/104103836): Anglican Belltower Op Shop volunteer Trudy-Anne Doyle said that when the clothing recycler stopped accepting goods, the store unpacked clothing and placed it on a **free rack**, while she expressed doubt that free pricing would ensure people wanted the remaining clothing. **ABC did not prove how many items people ultimately took.** That uncertainty is central to the event's outcome.
- [Game Accessibility Guidelines: Do not convey essentials by text alone](https://gameaccessibilityguidelines.com/ensure-no-essential-information-especially-instructions-is-conveyed-by-text-alone-reinforce-with-visuals-and-or-speech/): reinforce instructions through visuals and/or audio; a low-reading or non-reading player may find paragraphs inaccessible.
- [Godot 4.4 keyboard/controller navigation and focus](https://docs.godotengine.org/en/4.4/tutorials/ui/gui_navigation.html): explicit keyboard initial focus and clear focus neighbours.
- [Xbox Accessibility Guideline 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103): use more than one way to communicate state, and avoid colour-only cues.

## Save, balance and release rules

- `_save_game` keeps its existing crash-safe `user://lcg_p05_shop_v09.json` and adds one optional `secondhand_events` dictionary: active incident, handled flag, stored box count (0–8), goodwill (0–12), result summary. Older saves without that key load through a safe default.
- A **single choice cannot be claimed twice on the same modal**, including when the choice opens a new cleanup opportunity. End-of-day/new-day cycle preserves this.
- Inspect/reuse decisions have small predictable capped costs; existing clothing and furniture models are reused. No new 3D models, paid assets, online accounts, tracking, subscriptions, advertising or payment flows.
- This is the same **one-time-purchase/offline** game. The user's bigger library of dozens of real-life anecdotes remains research material, not dozens of mandatory cutscenes or a new shop game series.
- The original strict **23 Godot QA script count is preserved**; new regression checks are in `tests/qa_v0156_events_and_usability.gd`. The last clean Windows run must be checked before replacing the single canonical Drive source and internal EXE.
- Not a distribution-ready release: real hardware control, readable visual checks with non-readers, original licensed music comparison and business/storefront compliance remain open release gates.

## Accessible result and optional device speech update

The seven event types and 23-suite game-test structure are unchanged. The event screen now separates the three pictogram-aligned counters (money, storage and goodwill) and presents its completed action as a **large symbol with a large number**, with short optional explanatory text below. A speaker-icon button requests the installed **English operating-system text-to-speech voice** through Godot 4.4, without any external API, account or paid service. If an English system voice is unavailable, the speaker is disabled and all picture-led controls still work. This does not provide whole-game audio, multilingual narration or certified non-reading support; playback on physical hardware needs testing.

Official device-TTS reference: https://docs.godotengine.org/en/4.4/tutorials/audio/text_to_speech.html
