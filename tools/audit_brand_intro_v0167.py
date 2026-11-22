from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parents[1]
s=(root/'scripts/shop.gd').read_text()
required=['const BRAND_SPLASH_SECONDS: float = 1.8','BRAND_FADE_IN_SECONDS','BRAND_FADE_OUT_SECONDS','_skip_splash()','minf(fade_in, fade_out)','event.keycode == KEY_ESCAPE','event.keycode == KEY_ENTER','event is InputEventScreenTouch','if not _save_game():','AI_ASSISTED_PRODUCTION_NOTICE.txt']
missing=[x for x in required if x not in s]
tracks=json.loads((root/'documentation/USER_REUPLOADED_BGM_MATCH_v0167.json').read_text())['tracks']
for n,data in tracks.items():
 b=(root/data['game_path']).read_bytes()
 if hashlib.sha256(b).hexdigest()!=data['sha256'] or len(b)!=data['bytes']:
  missing.append('music:'+n)
for p in ['assets/branding/lcg_logo.png','assets/branding/lcg_icon.png','documentation/LITTLE_COZY_GAMES_STUDIO_IDENT_STANDARD_v0167.md','licenses/AI_ASSISTED_PRODUCTION_NOTICE.txt','tests/qa_v0167_brand_intro_and_exit.gd']:
 if not (root/p).is_file():missing.append(p)
if missing:raise SystemExit('BRAND INTRO 0167 FAIL: '+repr(missing))
print('BRAND INTRO 0167 STATIC PASS: script markers, BGM hashes, original logo and documentation. Not an engine or visual test.')
