# Little Cozy Games — Studio Logo, Opening, Ending and Credits Standard

**Decision:** 22 Nov 2026. **Applies:** LCG-P05 Old Things, New Days internal Godot prototype, and as a reusable baseline for Little Cozy Games. **Status:** development decision, not a claimed historical verbatim agreement or commercial legal clearance.

## Historical evidence, not reconstructed fiction
- An archived prior chat PDF, `游戏开发与AI评估.pdf`, page 72, records the owner delegating the splash screen, title screen and game icon decisions, and the assistant confirming the Drive folder with green/gold studio mark.
- The archived chat collapses the earlier exact assistant opening decision after `显示更多`. Exact prior animation timing, entry and exit poses were **not recoverable** and must not be invented as old agreements.
- The source of truth is the user's real Google Drive `Little Cozy Games — Game Files / 游戏LOGO / icon` folder, including `Little_Cozy_Games_Logo_Full.png` and `Little_Cozy_Games_Logo_Icon_1024.png`. The internal Godot project carries the corresponding original PNGs, not a new substitute.
- The owner confirms the Little Cozy Games brand and mark were designed with ChatGPT assistance and the existing Little Cozy Games itch.io profile belongs to the owner. This evidence does NOT establish registered trademark protection or universal freedom from conflicting marks.

## The design decision — one quiet studio ident
- The Godot application icon is configured as `res://assets/branding/lcg_icon.png` (static PNG); verify the *Windows executable embedded icon* separately when export becomes possible.
- Actual source art: static transparent/raster PNG with dark forest green, gold stars and Little Cozy Games wording; do not pretend it is a 3D mesh, video or separately animated source file.
- Presentation: centered, fixed 2D logo. Soft opacity fade only. **No spinning, floating, camera zoom, particle bursts, blinking or pulsing lights.** No mandatory logo sting audio.
- Time: total 1.8 seconds: fade in 0.50 s, steady about 0.98 s, fade out 0.32 s.
- One-tap / one-key skip from the first frame: Skip button, Enter, Space, Escape, mouse click or touch. The input is consumed and opens title menu; it must not accidentally press New Game underneath.
- Reduce Motion: bypass logo animation entirely and open the title menu immediately. Changing app focus should not drain the splash timer in background.
- Display at application startup only. Never replay before New Game, Continue, returning from pause, or after a completed day.

## Game opening and exit
1. Start app -> one brief, skippable studio ident (or skip entirely) -> interactive title/main menu.
2. Title menu: New Game, Continue, Credits/Licences, Accessiblity/Audio, Controls, Privacy/Safety, Healthy Play.
3. Start/Continue -> existing 3D shop. Tutorial is optional and can be skipped/replayed. Do not insert mandatory opening CG.
4. Pause -> Save & Main Menu only if save actually succeeds. On failed save, remain in paused shop, show actionable error. No outro logo.
5. Day end -> day report, next day. Optional Community Day finale: three brief story cards + visual stage, with `BACK TO SHOP` and `FINISH & KEEP SHOPPING`; NO forced scrolling staff credits or mandatory end-of-game cinematic.
6. Quit desktop from title -> close application. Never force a second studio ident or a Credits roll.

## Copyright and trade marks
- Studio developer/publisher: Little Cozy Games. New working game title: `Old Things, New Days`; it is not a registered mark and needs a release-stage confusion search.
- Do not put © OpenAI, © ChatGPT, or an OpenAI logo in the game. ChatGPT is a development tool, not the game's publisher or assumed copyright holder.
- A voluntary factual statement is in `licenses/AI_ASSISTED_PRODUCTION_NOTICE.txt`, accessible through optional Credits. This claims no affiliation or endorsement.
- AI tool use does not prove human-authored copyright eligibility, uniqueness, registered mark rights, or third-party clearance.
- Godot MIT, Kenney CC0 and hernandack CC0 music author/source notices remain separately maintained and accessible via player Credits. Never use ® unless registration is verified.

## Music provenance — new evidence on 22 Nov 2026
The owner re-uploaded four OGG tracks: Winter Dust, A Brand New Wisdom, Just Saying Tho, Swinging Sweet. Each uploaded file matches the already bundled `assets/audio/` file byte-for-byte (SHA-256 checks listed in `USER_REUPLOADED_BGM_MATCH_v0167.json`). This verifies the user's retained source files and project copy are identical, but is NOT proof that the external publisher's download is byte-identical. Music author / CC0 source remains documented in `documentation/MUSIC_SOURCE_EVIDENCE_v0166.json`.

## QA and release gate
Current Godot tests are not engine-validated in this environment. Verify fade, interactive skip, no double-click-through, pause-save failure path, focus changes, Reduced Motion, accessibility, player experience and music mixing on a real Windows build. Do not claim a finished EXE or certified photoseizure safety.

**Historical decisions must be read from this file before replacing the studio logo or changing splash behaviour.**
