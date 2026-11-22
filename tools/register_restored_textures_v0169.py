#!/usr/bin/env python3
"""Register ten restored PNGs with checksums and refresh the rights ledger.

Uses pinned Kenney CC0 mirror blobs; the Mini Shop palette is a compatible
but not source-archive-verified substitution from the older Mini Market set.
"""
from pathlib import Path
import csv,hashlib,json,struct,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
PIN="3694c6879e487c108f55677be7dd2ca75b07cc3b"
# target path, source kit, filename, exact source Git blob SHA-1, pack label
TEXTURES=[
("assets/third_party_kenney/building/Textures/colormap.png","building","colormap.png","084b4b3650474e1c73f528ad69c70e04b5e73155","Building Kit"),
("assets/third_party_kenney/city_suburban/Textures/colormap.png","city-suburban","colormap.png","9838fb4ccae35aa66eb2392e7f25c88f7ca28b38","City Kit (Suburban)"),
("assets/third_party_kenney/factory/Textures/colormap.png","factory","colormap.png","fddb472ccae14b57157b6d504977eda18b490291","Factory Kit"),
("assets/third_party_kenney/mini_arcade/Textures/colormap.png","mini-arcade","colormap.png","166a545e0e6fda582acc5b6475643acba1288bd7","Mini Arcade"),
("assets/third_party_kenney/prototype/Textures/colormap.png","prototype","colormap.png","166a545e0e6fda582acc5b6475643acba1288bd7","Prototype Kit"),
("assets/curated_v0147/mini_shop/Textures/colormap.png","mini-market","colormap.png","166a545e0e6fda582acc5b6475643acba1288bd7","Mini Market colormap (Mini Shop compatibility substitute)"),
("assets/expanded_v0153/Textures/colormap.png","mini-characters","colormap.png","166a545e0e6fda582acc5b6475643acba1288bd7","Mini Characters"),
("assets/models/Textures/colormap.png","mini-characters","colormap.png","166a545e0e6fda582acc5b6475643acba1288bd7","Mini Characters"),
("assets/selected_v015/characters/Textures/colormap.png","mini-characters","colormap.png","166a545e0e6fda582acc5b6475643acba1288bd7","Mini Characters"),
("assets/selected_v015/urban/Textures/roof.png","retro-urban","roof.png","3cc39ae4160a27864ce89204cf6eea0045f2939c","Retro Urban Kit"),
]
def blob_sha(data):
    return hashlib.sha1(b"blob "+str(len(data)).encode()+b"\0"+data).hexdigest()
def scan_glbs():
    models=sorted((ROOT/"assets").rglob("*.glb"))
    missing=[]
    for model in models:
        data=model.read_bytes()
        if data[:4]!=b"glTF":raise RuntimeError("Invalid GLB: "+str(model))
        size,kind=struct.unpack_from("<II",data,12)
        if kind!=0x4e4f534a:raise RuntimeError("Invalid GLB JSON header: "+str(model))
        j=json.loads(data[20:20+size])
        for tex in j.get("images",[]):
            uri=tex.get("uri","")
            if uri and not uri.startswith("data:") and not (model.parent/uri).is_file():
                missing.append(str(model.relative_to(ROOT))+" -> "+uri)
    if missing:raise RuntimeError("GLB references unresolved: "+"; ".join(missing))
    return len(models)
def main():
    additions={}
    for target,kit,name,expected,pack in TEXTURES:
        data=(ROOT/target).read_bytes()
        if not data.startswith(b"\x89PNG\r\n\x1a\n"):raise RuntimeError("Not a PNG: "+target)
        if blob_sha(data)!=expected:raise RuntimeError("Source blob differs: "+target)
        src="3d/"+kit+"/Textures/"+name
        note=("Pinned Kenney CC0 mirror texture; exact original source ZIP not byte-compared")
        if kit=="mini-market":
            note="Compatibility colormap from older Mini Market for Mini Shop 2.1; color equivalence not yet verified visually"
        additions[target]={
            "path":target,
            "source_zip":"shorepine/kenney git mirror at "+PIN,
            "source_member":src,
            "author":"Kenney",
            "pack":pack,
            "license":"CC0 1.0",
            "source_url":"https://github.com/shorepine/kenney/blob/"+PIN+"/"+src,
            "sha256":hashlib.sha256(data).hexdigest(),
            "purpose":note,
            "runtime_usage":"REFERENCED_BY_GAME",
            "derived_from_project_path":"",
            "source_verification_level":"PINNED_CC0_MIRROR_GIT_BLOB_MATCH_ORIGINAL_ZIP_NOT_BYTE_COMPARED",
        }
    n_glb=scan_glbs()
    ledger=ROOT/"licenses/USED_ASSET_PROVENANCE.csv"
    with ledger.open(encoding="utf-8-sig",newline="") as file:
        reader=csv.DictReader(file)
        columns=reader.fieldnames
        existing=list(reader)
    if not columns or len(existing)!=115:raise RuntimeError("Expected 115 original ledger rows")
    keyed={row["path"]:row for row in existing}
    if len(keyed)!=len(existing):raise RuntimeError("Duplicate ledger paths")
    keyed.update(additions)
    if len(keyed)!=125:raise RuntimeError("Expected 125 media ledger rows")
    with ledger.open("w",encoding="utf-8-sig",newline="") as file:
        writer=csv.DictWriter(file,fieldnames=columns,lineterminator="\n")
        writer.writeheader()
        writer.writerows(keyed.values())
    check=ROOT/"tools/check_creator_provenance_v0166.py"
    text=check.read_text(encoding="utf-8")
    before="assert_true(len(rows)==115,"
    if text.count(before)!=1:raise RuntimeError("Unexpected provenance script assertion")
    check.write_text(text.replace(before,"assert_true(len(rows)==125,"),encoding="utf-8")
    subprocess.run([sys.executable,"tools/sync_release_notices.py","--sync"],cwd=ROOT,check=True)
    lines=[
        "# Godot GLB texture recovery (v0.16.9)",
        "",
        "10 external PNG paths restored from pinned Kenney CC0 Git mirror, with original blobs checked by Git SHA-1.",
        "Upstream mirror commit: "+PIN,
        "GLB files checked for resolvable external texture URIs: "+str(n_glb),
        "",
        "One exception: Mini Shop 2.1 uses the compatible common colormap from older Mini Market.",
        "It is NOT verified byte-for-byte against the Mini Shop 2.1 official ZIP and needs visual review.",
        "",
        "## Files and SHA-256",
        "",
    ]
    for path,row in sorted(additions.items()):
        lines.append("- "+path+" | "+row["sha256"]+" | "+row["source_member"])
    lines.extend(["","No GLB mesh files or gameplay scripts were altered in this repair.",""])
    (ROOT/"documentation/TEXTURE_RECOVERY_V0169.md").write_text("\n".join(lines),encoding="utf-8")
    print(json.dumps({"status":"PASS","texture_paths":10,"ledger_entries":125,"glb_checked":n_glb},indent=2))
if __name__=="__main__":main()
