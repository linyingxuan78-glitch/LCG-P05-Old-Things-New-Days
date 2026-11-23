#!/usr/bin/env python3
"""Compare the four bundled CC0 OGG files to the exact OpenGameArt original URLs.
Pass only if each original byte stream really matches. A missing server response
is HOLD_NOT_VERIFIED, not an invented copyright clearance.
"""
from __future__ import annotations
import hashlib
import json
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
ORIGINAL_RECORD=ROOT/"documentation/MUSIC_SOURCE_EVIDENCE_v0166.json"
OUTPUT=ROOT/"documentation/music_origin_check_latest.json"

def sha(path: Path) -> str:
    h=hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda:f.read(65536),b""):
            h.update(chunk)
    return h.hexdigest()

def main() -> int:
    source=json.loads(ORIGINAL_RECORD.read_text(encoding="utf8"))
    results=[]
    for record in source["music"]:
        path=ROOT/record["file"]
        item={"file":record["file"],"author":record["artist"],
              "source_page":record["source_page"],"direct_url":record["direct_ogg_url"],
              "local_sha256":sha(path),"local_size":path.stat().st_size,
              "expected_local_sha256":record["sha256"],"upstream_sha256":None}
        if item["local_sha256"]!=item["expected_local_sha256"] or item["local_size"]!=record["local_bytes"]:
            item["status"]="FAIL_LOCAL_ASSET_MUTATED"
            results.append(item)
            continue
        try:
            req=urllib.request.Request(record["direct_ogg_url"],headers={
                "User-Agent":"LCG-P05-Release-Provenance-Verification/1.0",
                "Accept":"audio/ogg,application/octet-stream;q=0.9"})
            with urllib.request.urlopen(req,timeout=20) as response:
                data=response.read(2_000_000)
                content_type=response.headers.get("Content-Type","")
            if not data.startswith(b"OggS") or len(data)<5000:
                item["status"]="HOLD_UPSTREAM_NOT_OGG"
                item["response_type"]=content_type
            else:
                item["upstream_sha256"]=hashlib.sha256(data).hexdigest()
                item["upstream_size"]=len(data)
                item["status"]="VERIFIED_EXACT_BYTES" if item["upstream_sha256"]==item["local_sha256"] else "HOLD_ORIGINAL_BYTES_DIFFER"
        except Exception as exc:
            item["status"]="HOLD_ORIGINAL_DOWNLOAD_UNAVAILABLE"
            item["download_error"]=type(exc).__name__+": "+str(exc)[:180]
        results.append(item)
        print(item["file"],item["status"],flush=True)
    passed=sum(x["status"]=="VERIFIED_EXACT_BYTES" for x in results)
    status="VERIFIED_ALL_FOUR" if passed==4 else "HOLD_NOT_VERIFIED"
    report={"checked_at_utc":datetime.now(timezone.utc).isoformat(),
            "scope":"Four 2018 hernandack OpenGameArt CC0 music files only; other media and trademark separate",
            "licensed_source_page":"https://opengameart.org/content/short-loops-background-music-pack",
            "original_bytes_verified":passed,"source_count":4,
            "release_music_gate":status,"results":results,
            "note":"The official page labels the compositions CC0. Exact bytes can be verified only after successful original audio downloads; this is not a legal opinion."}
    OUTPUT.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    print("MUSIC_SOURCE_GATE:",status)
    # An inaccessible server is recorded honestly as HOLD. A locally changed
    # or demonstrably different upstream file prevents claiming release rights.
    return 1 if any(x["status"]=="FAIL_LOCAL_ASSET_MUTATED" for x in results) else 0

if __name__=="__main__":
    raise SystemExit(main())
