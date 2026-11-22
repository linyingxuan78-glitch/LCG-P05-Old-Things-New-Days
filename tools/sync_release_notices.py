#!/usr/bin/env python3
"""Validate all shipped media against the provenance ledger and generate player credits.

No legal conclusions: CC0 entries are declarations in the project register. This tool
will fail closed on missing or modified media, without silently repairing the register.
"""
from __future__ import annotations
import argparse
import csv
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "licenses" / "USED_ASSET_PROVENANCE.csv"
NOTICE = ROOT / "licenses" / "PLAYER_THIRD_PARTY_NOTICES.txt"
REPORT = ROOT / "documentation" / "CURRENT_RIGHTS_AUDIT.json"
MEDIA_EXTS = {".glb", ".fbx", ".ogg", ".mp3", ".wav", ".png", ".jpg", ".jpeg", ".webp", ".svg", ".ttf", ".otf"}
ENGINE_NOTICE = ROOT / "licenses" / "GODOT_ENGINE_MIT_LICENSE_NOTICE.txt"


def audit():
    errors, warnings = [], []
    if not LEDGER.exists():
        return ["Missing provenance ledger"], [], [], []
    with LEDGER.open("r", encoding="utf-8-sig", newline="") as inp:
        rows = list(csv.DictReader(inp))
    actual = {p.relative_to(ROOT).as_posix(): p for p in (ROOT / "assets").rglob("*") if p.is_file() and p.suffix.lower() in MEDIA_EXTS}
    registered = {}
    for index, row in enumerate(rows, 2):
        name = row.get("path", "").replace("\\", "/").strip()
        if not name or name in registered:
            errors.append(f"Line {index}: blank or duplicate media path: {name}")
            continue
        registered[name] = row
        if not name.startswith("assets/") or ".." in Path(name).parts:
            errors.append(f"Line {index}: unsafe media path: {name}")
            continue
        if name not in actual:
            errors.append(f"Line {index}: registered media missing from project: {name}")
            continue
        sha = hashlib.sha256(actual[name].read_bytes()).hexdigest()
        if sha.lower() != row.get("sha256", "").lower().strip():
            errors.append(f"Line {index}: SHA256 mismatch: {name}")
        if not row.get("author", "").strip() or not row.get("license", "").strip() or not row.get("pack", "").strip():
            errors.append(f"Line {index}: author/pack/license missing: {name}")
        studio_authored = row.get("author", "").strip().lower().startswith("little cozy games")
        if not studio_authored and not row.get("source_url", "").strip():
            errors.append(f"Line {index}: third-party asset lacks source URL: {name}")
        if not row.get("source_member", "").strip() and row.get("source_verification_level", "").startswith("PUBLIC_CC0_PAGE"):
            warnings.append(f"CC0 music source page exists but raw original archive member was not independently verified: {name}")
        elif row.get("source_verification_level", "").startswith("INTERNAL_ONLY") or row.get("source_verification_level", "").startswith("USER_CONFIRMED_AI_ASSISTED_"):
            warnings.append(f"Brand origin user-confirmed; trademark and public launch review still pending: {name}")
    for missing in sorted(set(actual) - set(registered)):
        errors.append(f"Unregistered new asset (stop release until its source is reviewed): {missing}")
    if not ENGINE_NOTICE.exists():
        errors.append("Missing full Godot MIT license notice")
    else:
        mit = ENGINE_NOTICE.read_text(encoding="utf-8-sig")
        for phrase in ("2007-2014 Juan Linietsky, Ariel Manzur", "Permission is hereby granted", "THE SOFTWARE IS PROVIDED", "Godot Engine contributors"):
            if phrase not in mit: errors.append(f"MIT notice incomplete: {phrase}")
    source = (ROOT / "scripts" / "shop.gd").read_text(encoding="utf-8")
    export_cfg = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    for path in ("PLAYER_THIRD_PARTY_NOTICES.txt", "GODOT_ENGINE_MIT_LICENSE_NOTICE.txt"):
        if (f'res://licenses/{path}' not in source):
            errors.append(f"Game Credits panel does not load required in-project notice: {path}")
    # Existing owner-created AI-assisted studio branding is allowed in private tests.
    # This does not automatically clear a public storefront trademark conflict.
    if 'load("res://assets/branding/lcg_logo.png")' not in source:
        errors.append("Missing established studio logo from private internal build")
    if "Engine.get_license_info()" not in (ROOT / "scripts/engine_notices.gd").read_text(encoding="utf-8"):
        errors.append("Third-party engine dependencies are not obtained from running binary")
    if 'binary_format/embed_pck=true' not in export_cfg:
        errors.append("Windows export is not configured to embed PCK resources")
    if 'include_filter="licenses/*.txt,licenses/*.csv"' not in export_cfg:
        errors.append("Windows export does not explicitly include legal text and asset register")
    return errors, warnings, rows, actual


def credits(rows):
    groups = defaultdict(lambda: [0, set()])
    for r in rows:
        author = r["author"].strip()
        if author.lower().startswith("little cozy games"):
            continue
        key = (author, r["pack"].strip(), r["license"].strip())
        groups[key][0] += 1
        url = r.get("source_url", "").strip()
        if url: groups[key][1].add(url)
    result = [
        "OLD THINGS, NEW DAYS · LCG-P05 INTERNAL PROTOTYPE — OPTIONAL CREDITS AND NOTICES",
        "This notice is generated from licenses/USED_ASSET_PROVENANCE.csv.",
        "It describes media included in this project, not endorsement by its creators.",
        "",
        "PROJECT CREDIT",
        "Little Cozy Games is the owner-identified existing itch.io publisher of Tidy Little Home, Little Repair Workshop, PAPER WORKS and RingBop.",
        "The original studio logo was generated with ChatGPT at the project owner’s direction, per owner testimony; this is not a trademark registration certificate.",
        "Third-party media, Godot Engine, and independently licensed components are excluded from this ownership claim.",
        "Existing studio name/logo are preserved for internal testing; public mark confusion review still required.",
        "",
        "BUNDLED THIRD-PARTY MEDIA (author / source set / declared license)",
    ]
    for (author, pack, license_name), (count, urls) in sorted(groups.items(), key=lambda i:(i[0][0].lower(),i[0][1].lower())):
        result.append(f"- {author} — {pack} — {license_name} ({count} media file(s))")
        for url in sorted(urls):result.append("  " + url)
    total = len(rows)
    internal = total - sum(v[0] for v in groups.values())
    result.extend([
        "", "PROJECT-AUTHORED / SOURCE-DERIVED MEDIA",
        f"{internal} project-authored or third-party-derived media files are itemized in the provenance register.",
        "Derived previews retain their underlying creator and license in the register.",
        "", "DETAILED RECORD", f"{total} media files listed in licenses/USED_ASSET_PROVENANCE.csv with SHA-256.",
        "Licenses and originals are retained in the project as documented; no claim that every source is copyright-exclusive.",
        "", "GAME ENGINE", "Godot Engine — MIT license.",
        "The full engine notice is in licenses/GODOT_ENGINE_MIT_LICENSE_NOTICE.txt and accessible in this game's optional Credits screen.",
        "Official source: https://godotengine.org/license/",
        "", "RELEASE DISCLAIMER", "Not yet a commercial release, and the rights audit is not a substitute for independent legal review.",
        "Godot engine components are accessible via the optional ENGINE COMPONENTS view. Public title and mark review and native QA remain pending; no retail release.",
        "",
    ])
    return "\n".join(result)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sync", action="store_true", help="Write or update the generated Credits notice")
    args = parser.parse_args()
    errors, warnings, rows, actual = audit()
    computed = credits(rows) if not errors else ""
    if not errors and not args.sync and (not NOTICE.exists() or NOTICE.read_text(encoding="utf-8-sig") != computed):
        errors.append("Player credits out of sync: run python tools/sync_release_notices.py --sync")
    if not errors and args.sync:
        NOTICE.write_text(computed, encoding="utf-8")
    result = {
        "type": "static-asset-provenance-and-credits-check-only",
        "status": "PASS" if not errors else "FAIL", "media_files":len(actual), "ledger_rows":len(rows),
        "errors":errors,"warnings":warnings,"credits_synced":not errors,
        "known_release_gates_still_open":["Godot runtime/export not executed", "Godot 4.4.1 exact-binary snapshot pending until native builder runs", "official similarity mark search pending; itch account ownership user-confirmed", "legal review is not automatic"],
    }
    REPORT.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
    print(json.dumps({"status":result["status"],"media":len(actual),"ledger":len(rows),"errors":errors,"warning_count":len(warnings)},ensure_ascii=False))
    return 1 if errors else 0

if __name__ == "__main__":sys.exit(main())
