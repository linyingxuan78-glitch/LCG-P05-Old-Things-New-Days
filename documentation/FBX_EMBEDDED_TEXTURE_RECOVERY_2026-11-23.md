# Godot 4.4.1 FBX-embedded PNG extraction — 2026-11-23

## Discovery and evidence
- Exact Windows Godot 4.4.1 native import, main-scene startup and **23/23 actual QA suites passed**: https://github.com/linyingxuan78-glitch/LCG-P05-Old-Things-New-Days/actions/runs/45086423354
- A *second*, strict export-stage source audit properly stopped the INTERNAL_TEST_ONLY build because Godot imported **7 external PNGs from 7 original binary FBX source files** and the media ledger only contained 125 entries.
- Each FBX embeds its own PNG bytes. Binary chunks were extracted and verified by PNG signature, chunk layout/CRC and a SHA-256 hash, then restored as source-controlled PNGs in the exact Godot-generated filenames. They are **not additional purchases or newly invented source art**.
- All 7 PNG files belong to existing CC0 source archives already recorded as original FBX members: Homely House Set (4), Pretty park set (2), Restaurant Bits (1). The newly registered PNG rows retain each corresponding original archive member, original asset author/URL/license, exact derived PNG SHA-256, and the parent project FBX path. Media ledger count **125 -> 132**.
- Six PNGs share exactly the same 20,167-byte embedded texture, SHA-256 `0dc04a048fd85b129183864788cf85bd63ead6fdccb788a21be98d92f2c4e408`; one separate crate texture is 21,070 bytes, SHA-256 `1bfff8f880c5e5e1b793bc46fa1f91149b7f70766174a817b3d5962495c5e40f`.
- No gameplay changes, mesh changes or discarded error checks. The original v0.16.9 Google Drive ZIP remains untouched.

## Verification
Use `python tools/audit_embedded_fbx_textures_v0170.py` to prove every restored PNG is **byte-for-byte identical** to the one embedded in its licensed parent FBX, and both parent and derived paths are correctly attributed in `licenses/USED_ASSET_PROVENANCE.csv`. Then run `python tools/sync_release_notices.py` (without --sync) to independently check generated Credits.

This repairs the *packaging provenance* blocker only. The Windows EXE has **not** been certified as built until a subsequent full GitHub Actions workflow actually passes and provides an EXE artifact. A public commercial release remains on hold for independent player/graphics/audio/licence/title checks.
