#!/usr/bin/env python3
"""Verifies raw-original archive members for this version's source evidence.
Requires the user's authorized original ZIPs in --archive-dir. They are not bundled
inside the player project. Outputs a versioned evidence snapshot; no legal clearance.
"""
import argparse,csv,hashlib,json,zipfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
LEDGER=ROOT/'licenses/USED_ASSET_PROVENANCE.csv'
OUT=ROOT/'documentation/ORIGINAL_SOURCE_EVIDENCE_v0165.json'

def sha(data):return hashlib.sha256(data).hexdigest()

def run(archive_dir,write):
    with LEDGER.open(encoding='utf-8-sig',newline='') as f:rows=list(csv.DictReader(f))
    by_path={r['path']:r for r in rows}
    archive_cache={}
    report={'type':'source-byte-evidence; not rights clearance','build':'v0.16.6','archive_dir_assumption':'Original user-provided ZIP archive folder; not shipped with game','direct_verified':[],'derived_verified':[],'original_archive_unavailable':[],'music_source_page_only':[],'brand_owner_attested':[],'project_artwork':[],'errors':[],'archive_sha256':{}}
    for r in rows:
        file_path=ROOT/r['path']
        if not file_path.is_file():report['errors'].append('Missing media '+r['path']);continue
        actual_sha=sha(file_path.read_bytes())
        if actual_sha!=r['sha256']:report['errors'].append('Modified media '+r['path']);continue
        status=r['source_verification_level']
        if status.startswith('PUBLIC_CC0_PAGE'):
            report['music_source_page_only'].append({'path':r['path'],'sha256':actual_sha,'source_url':r['source_url'],'archive_member':'not independently verified'})
            continue
        if status.startswith('INTERNAL_ONLY') or status.startswith('USER_CONFIRMED_AI_ASSISTED_'):
            report['brand_owner_attested'].append({'path':r['path'],'sha256':actual_sha,'public_use':'Owner-confirmed AI origin. Private playtest permitted; market trademark clearance pending'})
            continue
        if status=='PROJECT_AUTHORED_OR_ASSET_TRACE_REVIEW':
            report['project_artwork'].append({'path':r['path'],'sha256':actual_sha,'claimed_source':r['source_zip']})
            continue
        archive_name=r['source_zip']
        archive=archive_dir/archive_name
        if not archive.is_file():
            report['original_archive_unavailable'].append({'path':r['path'],'original_zip':archive_name})
            continue
        if archive_name not in archive_cache:
            archive_cache[archive_name]=zipfile.ZipFile(archive,'r')
            report['archive_sha256'][archive_name]=sha(archive.read_bytes())
        z=archive_cache[archive_name]
        member=r['source_member']
        if member not in z.namelist():
            report['errors'].append('Original member missing '+r['path']+' in '+archive_name+'#'+member)
            continue
        original_hash=sha(z.read(member))
        parent=r['derived_from_project_path']
        if parent:
            src=by_path.get(parent)
            if src is None or sha((ROOT/parent).read_bytes())!=original_hash:
                report['errors'].append('Derived image parent/source mismatch '+r['path'])
            else:
                report['derived_verified'].append({'path':r['path'],'preview_sha256':actual_sha,'derived_from':parent,'original_zip':archive_name,'zip_member':member,'source_model_sha256':original_hash})
        elif original_hash==actual_sha:
            report['direct_verified'].append({'path':r['path'],'original_zip':archive_name,'zip_member':member,'sha256':actual_sha})
        else:
            report['errors'].append('Original ZIP bytes mismatch '+r['path'])
    for z in archive_cache.values():z.close()
    report['summary']={'total_media':len(rows),'exact_original_zip_copies':len(report['direct_verified']),'derivatives_with_verified_parent':len(report['derived_verified']),'third_party_music_missing_raw_original_zip':len(report['music_source_page_only']),'owner_attested_brand_files_pending_trademark_review':len(report['brand_owner_attested']),'original_local_art':len(report['project_artwork']),'missing_archives':len(report['original_archive_unavailable']),'errors':len(report['errors'])}
    if write:OUT.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'status':'PASS_RAW_BYTE_CHAIN_WITH_DECLARED_HOLDS' if not report['errors'] and not report['original_archive_unavailable'] else 'FAIL','summary':report['summary']},ensure_ascii=False,indent=2))
    return 0 if not report['errors'] and not report['original_archive_unavailable'] else 1

if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--archive-dir',type=Path,required=True,help='Original user-provided asset ZIPs, not player resources')
    ap.add_argument('--no-write',action='store_true')
    a=ap.parse_args()
    raise SystemExit(run(a.archive_dir,not a.no_write))
