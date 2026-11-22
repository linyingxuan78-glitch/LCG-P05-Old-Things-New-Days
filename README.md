# Old Things, New Days — LCG-P05

Godot 4.4.1 first-person secondhand shop management prototype. Current source handoff: **v0.16.9**.

- The repository is a **development project**, not a playable Windows release.
- Source version: `v0.16.9`. **23/23 real Godot 4.4.1 native gameplay QA suites passed** (every suite exit=0, errors=0, expected PASS marker) after source texture recovery and test fixes. **The full editor-import release gate remains NOT PASSED**, because GitHub's Xvfb environment logs 4 Vulkan initialization ERROR lines despite import exit=0. Windows packaging and real-device playability are not yet validated.
- Public repository: do not include personal saves, credentials, or unverifiable third-party media.
- The canonical original archive remains in the project owner's Google Drive as `LCG_P05_LATEST_Godot_Project.zip`, SHA-256 `c4ebf7a05b1e573b6e4af981c0b914ffb27272207f46811211e301c746752d07`.

See `README_中文.md`, `documentation/TEXTURE_RECOVERY_V0169.md` and [`documentation/NATIVE_QA_TEXTURE_RECOVERY_AND_23_SUITES_2026-11-22.md`](documentation/NATIVE_QA_TEXTURE_RECOVERY_AND_23_SUITES_2026-11-22.md) for evidence, follow-up checks, and limitations.
