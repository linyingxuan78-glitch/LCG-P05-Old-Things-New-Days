> **SUPERSEDED FACTUAL CORRECTIONS (v0.16.6):** studio itch account is confirmed by its owner and four matching games. ChatGPT-assisted logo creation at owner direction is recorded. Music four source creator pages and track links confirmed. Refer to CREATOR_PROVENANCE_AND_NAME_v0166.md. Historic old HOLD wording below is not the current factual status.

# LCG-P05 v0.16.5: Commercial IP and branding decision register

Date: 2026-11-22. Internal development evidence; NOT a legal clearance.

## Historical original document recovered
"Little Cozy Games — Project #5: Prototype Delivery, Third-Party Asset Rights & IP Clearance" (16 November 2026) was reviewed. It specifically documented that Second Chance Shop was retired and "LCG-P05 SHOP LAB" was an internal, descriptive project identifier. It covered an older *standalone HTML prototype*, NOT the current Godot game. Do not mix those two delivery results.

## Clearance findings and decisions
1. **Original asset archives** — 69 directly bundled Kenney/Poly Pizza files have exact original ZIP entries with SHA256; 26 model-derived product preview pictures are traceable via their original models; own pictures are identified separately. Evidence: documentation/ORIGINAL_SOURCE_EVIDENCE_v0165.json. Raw ZIPs are not shipped or necessary for player runtime.
2. **Music** — hernandack's Short Loops Background Music Pack is publicly described as CC0. The four tracks in the current project have no independently verified original archive to match the final OGG bytes to; old 2026-11-16 report verified title/file-size congruence only. HOLD exact byte provenance.
3. **Godot Engine** — MIT text included. Godot 4.4 documentation says engine has additional third-party libraries with their own copyright terms. `scripts/engine_notices.gd` reads `Engine.get_license_info()` and `Engine.get_copyright_info()` from the running binary; optional in-game Credits displays them. `tools/generate_engine_notices.gd` generates the specific selected binary's written snapshot for internal developer EXE exports; cannot execute in environment without engine. Must validate snapshot in actual Windows export.
4. **Studio name/branding** — the current internal project called Little Cozy Games, but a public itch.io profile at https://itch.io/profile/little-cozy-games uses this name; ownership/relationship is NOT established by the web result. Do not presume registration, clearance, or infringement. Existing logo was marked "Internal art — rights review pending" in the ledger. Both image files are retained for internal work, removed from game UI, and excluded from export.
5. **Game name** — Second Chance Shop retired as a precaution. LCG-P05 Shop Lab is an internal development code only. No launch name approved. No confirmed clearance in MyIPO, USPTO or WIPO.

## Official / creator evidence
- Historical review: LCG_P05_IP_Clearance_QA_2026-11-16.md (user Library; review extracted in this development).
- https://kenney.nl/support and original Kenney ZIP License.txt.
- https://poly.pizza/bundle/Homely-House-Set-zECUN0FUzz and https://poly.pizza/bundle/Pretty-park-set-G2WINPAG9S; indexed creator CC0 listings.
- https://opengameart.org/content/short-loops-background-music-pack (hernandack CC0 page, author/pack only; bytes not verified).
- https://docs.godotengine.org/en/4.4/about/complying_with_licenses.html
- https://docs.godotengine.org/en/4.4/classes/class_engine.html
- https://www.wipo.int/en/web/global-brand-database/index
- https://tmsearch.uspto.gov/search/ and https://www.myipo.gov.my/search-trademark/

## Mandatory commercial hold
- No public game title or studio logo may be advertised as cleared based on this report. Perform manual review of actual and similar marks, marketplace uses, logos and relevant jurisdictions/classes, including the ownership of the existing itch.io name; preserve dated evidence and consider legal professional review before important commercial launches.
- Export is **INTERNAL_TEST_ONLY**, not a retail executable. Godot runtime, legal snapshot and final device reviews are pending.
- Audit script checks integrity; **a matching hash is not a legal license or proof of original ownership**. Commercial release must additionally consider final music bytes, platform terms, trademark/name, copyright particulars and user data handling.
