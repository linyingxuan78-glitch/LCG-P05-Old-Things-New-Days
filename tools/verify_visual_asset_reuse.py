#!/usr/bin/env python3
from pathlib import Path
import hashlib,csv,sys
root=Path(__file__).resolve().parents[1]
code=(root/'scripts/shop.gd').read_text()
needed=['bookcaseOpen','cardboardBoxClosed','desk','plantSmall1','character-female-a','character-female-c','character-male-a']
missing=[]
for model in needed:
    if not (root/'assets/models'/f'{model}.glb').exists(): missing.append('missing GLB '+model)
    if code.count('"'+model+'"')<1: missing.append('not called in code '+model)
rows=list(csv.DictReader((root/'documentation/ASSET_REGISTER.csv').open(newline='')))
for row in rows:
    f=root/row['relative_path']
    if not f.exists() or hashlib.sha256(f.read_bytes()).hexdigest()!=row['sha256']:
        missing.append('registry hash mismatch: '+row['relative_path'])
for asset in ['Mini Market','UI Pack']:
    assert asset in (root/'documentation/ASSET_REQUEST_PRIORITY_v0144.md').read_text()
if missing:
    print('ART STATIC AUDIT FAILED:',*missing,sep='\n')
    sys.exit(1)
print('ART STATIC AUDIT PASSED: 7 existing GLB references and all %d registered asset hashes.'%len(rows))
print('NOTE: this is NOT a Godot runtime or screenshot test.')
