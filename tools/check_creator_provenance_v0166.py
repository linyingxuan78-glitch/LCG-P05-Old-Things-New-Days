#!/usr/bin/env python3
"""Source/story consistency check; NOT legal clearance, auth verification or engine QA."""
from pathlib import Path
import csv,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
errors=[]
def assert_true(cond,msg):
    if not cond:errors.append(msg)

def load(s):return (ROOT/s).read_text(encoding='utf-8')

project=load('project.godot')
shop=load('scripts/shop.gd')
settings=load('export_presets.cfg')
audit=load('documentation/CREATOR_PROVENANCE_AND_NAME_v0166.md')
assert_true('Old Things, New Days' in project,'missing game candidate in project metadata')
assert_true('OLD THINGS' in shop and 'NEW DAYS' in shop,'missing in-game title')
assert_true('Little Cozy Games' in audit and 'PAPER WORKS' in audit and 'RingBop' in audit,'owner / portfolio statement incomplete')
assert_true('load("res://assets/branding/lcg_logo.png")' in shop,'owner-stated ChatGPT logo not preserved in private preview')
assert_true('assets/branding/*' not in settings,'owner-attributed branding erroneously excluded from private test bundle')
assert_true('binary_format/embed_pck=true' in settings,'project lost embed_pck setting')
assert_true('HOLD_PLATFORM_LEGAL_NATIVE_QA'==json.loads(load('documentation/IP_PUBLIC_RELEASE_GATE_v0165.json'))['status'],'public release gate cannot be bypassed by provenance discovery')
assert_true('Engine.get_license_info()' in load('scripts/engine_notices.gd'),'engine third-party licensing API missing')
assert_true('Old Things, New Days' in load('documentation/CREATOR_PROVENANCE_AND_NAME_v0166.md'),'name evidence missing')

with (ROOT/'licenses/USED_ASSET_PROVENANCE.csv').open(encoding='utf-8-sig',newline='') as f:
    rows=list(csv.DictReader(f))
assert_true(len(rows)==125,'media ledger count changed')
by={r['path']:r for r in rows}
music=json.loads(load('documentation/MUSIC_SOURCE_EVIDENCE_v0166.json'))['music']
assert_true(len(music)==4,'4 composer BGM missing')
for track in music:
    path=track['file']; item=ROOT/path
    assert_true(item.is_file(),f'missing track: {path}')
    if item.is_file():
        assert_true(hashlib.sha256(item.read_bytes()).hexdigest()==track['sha256'],f'track hash no longer matches cited build: {path}')
        assert_true(item.stat().st_size==track['local_bytes'],f'track length changed: {path}')
    r=by.get(path)
    assert_true(r is not None and r['author']=='hernandack' and r['license']=='CC0 1.0',f'music CC0/author claim missing in registry: {path}')
    assert_true(track['direct_ogg_url'].startswith('https://opengameart.org/sites/default/files/'),f'public audio URL not traced: {path}')
    assert_true('no direct byte hash' in track['verification'],f'music source proof overclaimed: {path}')
for name in ('lcg_logo.png','lcg_icon.png'):
    path='assets/branding/'+name
    r=by.get(path)
    assert_true(r is not None and r['source_verification_level']=='USER_CONFIRMED_AI_ASSISTED_ORIGIN_NOT_TRADEMARK_CLEARED',f'user AI source status missing: {path}')

print(json.dumps({'creator_rights_static':'PASS' if not errors else 'FAIL','checked_music_tracks':len(music),'checked_media_records':len(rows),'owner_brand_files':2,'errors':errors},ensure_ascii=False,indent=2))
sys.exit(1 if errors else 0)
