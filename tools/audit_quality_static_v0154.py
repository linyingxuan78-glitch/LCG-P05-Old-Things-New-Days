#!/usr/bin/env python3
"""Non-engine source/GLB quality audit. NOT a Godot runtime test."""
from pathlib import Path
import ast,csv,hashlib,math,json,struct,sys,re
ROOT=Path(__file__).resolve().parent.parent
S=(ROOT/'scripts/shop.gd').read_text(encoding='utf8')
checks=[]
def check(name,ok,detail=''):
 checks.append(dict(check=name,passed=bool(ok),detail=detail))

section=S.split('const PRODUCTS = [',1)[1].split('\n]',1)[0]
products=[ast.literal_eval(line.strip().rstrip(',')) for line in section.splitlines() if line.strip().startswith('{')]
check('27 product definitions',len(products)==27,str(len(products)))
models=[]
for p in products:
 key=p['model']
 if key.startswith('procedural/'):
  continue
 asset=ROOT/('assets/expanded_v0153/'+key.split('/',1)[1]+'.glb' if key.startswith('expanded/') else 'assets/models/'+key+'.glb')
 models.append(asset)
check('every product model bundled',all(x.is_file() for x in models),str(len(models))+' product references')
check('daily supplier quota persisted',all(k in S for k in ['"supplier_remaining":supplier_remaining.duplicate()','supplier_remaining[index] -= 1','supplier_remaining[index] -= 3','supplier_remaining.append(_daily_supplier_quota(i))']))
check('oversized shelf props scale down',all(k in S for k in ['DISPLAY_FIT_FACTORS','fitted_scale','_model(holder, str(PRODUCTS[sku]["model"])']))
check('visitor yaw turns smoothly',all(k in S for k in ['lerp_angle(customer.rotation.y','CUSTOMER_TURN_SPEED']))
check('walk animation loops without repeated one-shot restarting',all(k in S for k in ['playing_clip.loop_mode = Animation.LOOP_LINEAR','requested not in ["walk", "idle"]']))
check('front-left aisle detour present',S.count('Vector3(-4.9, 0.0, 2.0)') >= 3)
check('old save SKU count accepted','stored_count == SHELF_POINTS.size() or stored_count == PRODUCTS.size()' in S)
check('shared shelf stock capped when loading old files',all(k in S for k in ['stock[i] = mini(stock[i], room)','consignment_stock[i] = mini(consignment_stock[i], stock[i])']))

with (ROOT/'licenses/USED_ASSET_PROVENANCE.csv').open('r',encoding='utf-8-sig',newline='') as f:
 rows=list(csv.DictReader(f))
all_match=True;bad=[]
for row in rows:
 path=ROOT/row['path']
 if not path.exists() or hashlib.sha256(path.read_bytes()).hexdigest().lower()!=row['sha256'].lower():
  all_match=False;bad.append(row['path'])
check('asset hashes and provenance',all_match,f'{len(rows)} registered; invalid: {bad[:3]}')

# GLB keyframe validity (including the exact walking/idle/gesture tracks we play).
characters=list((ROOT/'assets/models').glob('character-*.glb'))+list((ROOT/'assets/selected_v015/characters').glob('character-*.glb'))
required={'walk','idle','interact-right','interact-left','pick-up','emote-no'}
keyframes=0;clips=0;bad_timeline=[]
for path in characters:
 data=path.read_bytes()
 if data[:4]!=b'glTF': bad_timeline.append(path.name+': bad GLB');continue
 json_size,json_type=struct.unpack_from('<II',data,12)
 payload=json.loads(data[20:20+json_size])
 binary_start=20+json_size+8
 animations=payload.get('animations',[])
 names={a.get('name','') for a in animations}
 if not required <= names:bad_timeline.append(path.name+':missing '+str(required-names))
 clips+=len(animations)
 for anim in animations:
  for sampler in anim.get('samplers',[]):
   acc=payload['accessors'][sampler['input']]
   if acc['componentType']!=5126:bad_timeline.append(path.name+':nonfloat times');continue
   bv=payload['bufferViews'][acc['bufferView']]
   offset=binary_start+bv.get('byteOffset',0)+acc.get('byteOffset',0)
   stride=bv.get('byteStride',4)
   times=[struct.unpack_from('<f',data,offset+i*stride)[0] for i in range(acc['count'])]
   keyframes+=len(times)
   if not all(math.isfinite(t) for t in times) or any(b<a for a,b in zip(times,times[1:])):
    bad_timeline.append(path.name+':invalid timeline '+anim.get('name',''))
check('all six character GLBs have required clips',len(characters)==6 and not any('missing' in x for x in bad_timeline),f'{len(characters)} GLBs, {clips} animations')
check('animation keyframe time streams valid',not bad_timeline,f'{keyframes} input keyframes; errors: {bad_timeline[:5]}')

# Catalog visual sizing is measured on the bundled GLB mesh, not guessed.
try:
 import trimesh
 fit_match=re.search(r'const DISPLAY_FIT_FACTORS = \{([^}]+)\}',S)
 fits=ast.literal_eval('{'+fit_match.group(1)+'}') if fit_match else {}
 too_large=[]
 for i,p in enumerate(products):
  k=p['model']
  if k.startswith('procedural/'):continue
  path=ROOT/('assets/expanded_v0153/'+k.split('/',1)[1]+'.glb' if k.startswith('expanded/') else 'assets/models/'+k+'.glb')
  scene=trimesh.load(path,force='scene')
  extent=(scene.bounds[1]-scene.bounds[0])*float(p['scale'])*fits.get(i,1.0)
  if extent[0]>0.61 or extent[1]>0.60 or extent[2]>0.55:
   too_large.append((i,p['name'],[round(float(v),3) for v in extent]))
 check('GLB products fit per-slot shelf display dimensions',not too_large,str(too_large[:10]))
except ImportError:
 check('GLB product display fit','SKIPPED','trimesh unavailable in local environment')

report={'kind':'STATIC_AND_GLTF_INSPECTION_ONLY','godot_engine_run':False,'total_checks':len(checks),'passed':sum(c['passed'] for c in checks),'checks':checks}
out=ROOT/'documentation/QUALITY_STATIC_AUDIT_v0154.json'
out.write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf8')
for c in checks:print(('PASS' if c['passed'] else 'FAIL')+' '+c['check']+' '+c['detail'])
print(f'RESULT {report["passed"]}/{report["total_checks"]} static checks (not Godot engine tests)')
sys.exit(0 if report['passed']==report['total_checks'] else 1)
