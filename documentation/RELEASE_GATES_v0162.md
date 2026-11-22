# LCG-P05 v0.16.2 — Release gates and evidence

| Gate | Required evidence | Status |
| --- | --- | --- |
| Resource integrity | Local SHA256 + archive CRC, documented sources | **PASS offline**, 115 files |
| Godot syntax & import | Official Godot 4.4.1 `--headless --editor --import` log | **BLOCKED** — no engine |
| Native gameplay | `--headless --quit-after` and 19 actual QA scripts, gameplay log | **BLOCKED** — no engine |
| Real interface | Player walkthrough and screenshots of desk / icons at 720p, 1080p | **NOT TESTED** |
| Character animations | Actual frame-by-frame walk/pickup transition, footwear/prop intersections | **NOT TESTED** |
| Keyboard / mouse accessibility | Two independent keyboard navigation checks; mouse sensitivity; ESC escape | **NOT TESTED** |
| Cognitive accessibility | Observe people who cannot read English using the purchase icons and tutorial | **NOT TESTED** |
| Flash / photophobia | Analyze actual recorded gameplay for flashes and excessive brightness; involve suitable expertise if needed | **NOT TESTED** |
| Privacy / minors | Verify local save deletion, no unexpected network traffic, review age/region/platform policies | **NOT TESTED** |
| Windows self-contained delivery | One EXE + embedded resource PCK; clean-device startup / licensed notice | **NOT BUILT** |
| Store submission | Platform guidelines, age rating, rights check, marketing screenshots | **NOT STARTED** |

## What is actually completed in this iteration
- 27 product silhouette cards drawn from previously licensed low-poly models.
- 3 original action icons paired with English labels, not communicated by colour alone.
- Closing-day confirmation to avoid accidental loss of an in-game day.
- Optional cycling of 3 mouse speed profiles in local settings.
- 19th Godot QA test added to Linux and Windows acceptance runners.
- 115/115 media asset hash/provenance integrity confirmed using Python.

## Required native process
Install official Godot 4.4.x editor and run the **native** engine checks in `tools/`. Do not substitute the four dummy runner simulations. For first release, manual accessibility and photosensitivity evaluation must use real Godot-rendered frames.

Technical references: https://docs.godotengine.org/en/4.4/tutorials/editor/command_line_tutorial.html ; https://gameaccessibilityguidelines.com/basic/ ; https://docs.godotengine.org/en/4.4/classes/class_button.html .
