#!/usr/bin/env python3
"""Deterministic file/provenance checks. Does NOT claim to execute or render Godot."""
from pathlib import Path
import csv, hashlib, struct, json
ROOT=Path(__file__).resolve().parents[1]
CODE=(ROOT/'scripts/shop.gd').read_text(encoding='utf-8')
rows=list(csv.DictReader((ROOT/'documentation/NEW_ASSETS_v0146.csv').open(encoding='utf-8',newline='')))
assert len(rows)==6, f'Expected 6 curated files, got {len(rows)}'
assert sum(r['path'].endswith('.glb') for r in rows)==5
assert sum(r['path'].endswith('.png') for r in rows)==1
ok=0
for row in rows:
    path=ROOT/row['path']
    assert path.is_file(), f'missing {path}'
    blob=path.read_bytes()
    assert hashlib.sha256(blob).hexdigest()==row['sha256'],f'hash mismatch {row["path"]}'
    assert f'res://{row["path"]}' in CODE, f'not referred to in gameplay code {row["path"]}'
    if path.suffix=='.glb':
        assert blob[:4]==b'glTF' and struct.unpack_from('<I',blob,8)[0]==len(blob)
        jsonlength,typ=struct.unpack_from('<I4s',blob,12)
        assert typ==b'JSON'
        parsed=json.loads(blob[20:20+jsonlength])
        assert parsed.get('meshes') and parsed.get('nodes')
    elif path.suffix=='.png':
        assert blob[:8]==b'\x89PNG\r\n\x1a\n'
    ok+=1
assert not (ROOT/'art.zip').exists(), 'Unlicensed art archive must be quarantined outside runtime'
assert len(list(ROOT.rglob('*.ttf')))==0, 'No unverified font should be integrated'
print(f'PASS: {ok} curated CC0 assets correctly copied, hashed and referenced')
print('PASS: no art.zip or its TTF in Godot runtime')
print('NOTE: static checks only, not Godot import, startup or visual gameplay validation')
