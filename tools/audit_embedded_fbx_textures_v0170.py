#!/usr/bin/env python3
"""Fail-closed audit of PNGs deterministically embedded in 7 verified FBX files."""
from pathlib import Path
from hashlib import sha256
import csv,struct,zlib,sys

ROOT=Path(__file__).resolve().parents[1]
ITEMS={
"assets/third_party/homely_house/bench_A.fbx":"assets/third_party/homely_house/bench_A_0.png",
"assets/third_party/homely_house/doormat.fbx":"assets/third_party/homely_house/doormat_0.png",
"assets/third_party/homely_house/mailbox.fbx":"assets/third_party/homely_house/mailbox_0.png",
"assets/third_party/homely_house/package.fbx":"assets/third_party/homely_house/package_0.png",
"assets/third_party/pretty_park/bush.fbx":"assets/third_party/pretty_park/bush_0.png",
"assets/third_party/pretty_park/flower_A.fbx":"assets/third_party/pretty_park/flower_A_0.png",
"assets/third_party/restaurant_bits/crate.fbx":"assets/third_party/restaurant_bits/crate_0.png",
}
SIG=b"\x89PNG\r\n\x1a\n"
def extract_png(buf):
    pos=buf.find(SIG)
    if pos<0:raise AssertionError("FBX does not contain embedded PNG signature")
    at=pos+len(SIG)
    while True:
        if at+12>len(buf):raise AssertionError("PNG chunk truncated")
        size=struct.unpack(">I",buf[at:at+4])[0]
        typ=buf[at+4:at+8]
        payload=buf[at+8:at+8+size]
        crc=int.from_bytes(buf[at+8+size:at+12+size],"big")
        if len(payload)!=size or (zlib.crc32(typ+payload)&0xffffffff)!=crc:
            raise AssertionError("Embedded PNG chunk CRC mismatch")
        at+=12+size
        if typ==b"IEND":break
    return buf[pos:at]
def main():
    with (ROOT/"licenses/USED_ASSET_PROVENANCE.csv").open("r",encoding="utf-8-sig",newline="") as f:
        rows=list(csv.DictReader(f))
    by={r["path"]:r for r in rows}
    if len(rows)!=132:raise AssertionError("Expected 132 registered media paths")
    for parent,texture in ITEMS.items():
        if parent not in by or texture not in by:raise AssertionError("Missing parent/derived register record: "+texture)
        original=extract_png((ROOT/parent).read_bytes())
        generated=(ROOT/texture).read_bytes()
        if original!=generated:raise AssertionError("Godot's extracted texture differs from parent FBX bytes: "+texture)
        if sha256(generated).hexdigest()!=by[texture]["sha256"]:raise AssertionError("PNG ledger hash differs: "+texture)
        if by[texture]["derived_from_project_path"]!=parent:raise AssertionError("Incorrect image parent: "+texture)
        for key in ("author","pack","license","source_url","source_zip","source_member"):
            if by[texture][key]!=by[parent][key]:raise AssertionError("Incorrect attribution field "+key+": "+texture)
    print("PASS: seven FBX-embedded PNGs match parent bytes, hashes, licences and source archives")
if __name__=="__main__":
    try:main()
    except Exception as e:
        print("FAIL:",e)
        sys.exit(1)
