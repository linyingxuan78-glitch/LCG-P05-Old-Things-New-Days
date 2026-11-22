#!/usr/bin/env python3
"""Diagnostic-only full native QA after real Xvfb OpenGL asset import.

Never calls a failing Godot editor import a clean PASS; logs all errors and
runs all 23 original test scripts to expose real gameplay problems.
"""
from __future__ import annotations
import json
import os
import re
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"documentation/native_diagnostic_xvfb"
OUT.mkdir(parents=True,exist_ok=True)
ENGINE=os.environ.get("GODOT_BIN","godot")
def invoke(name,args,timeout_seconds=120,env_extra=None):
    env=os.environ.copy()
    env["LIBGL_ALWAYS_SOFTWARE"]="1"
    env["GODOT_DISABLE_CRASH_HANDLER"]="1"
    if env_extra:env.update(env_extra)
    try:
        cp=subprocess.run(args,cwd=ROOT,env=env,capture_output=True,text=True,errors="replace",timeout=timeout_seconds)
        output=cp.stdout+"\n"+cp.stderr
        rc=cp.returncode
    except subprocess.TimeoutExpired as e:
        output=((e.stdout or b"").decode("utf8","replace") if isinstance(e.stdout,bytes) else (e.stdout or ""))+"\nTIMEOUT\n"
        rc=124
    (OUT/(name+".log")).write_text(output,encoding="utf-8")
    errors=[line for line in output.splitlines() if ("ERROR:" in line or "SCRIPT ERROR:" in line or "Parse Error:" in line or "Parser Error:" in line)]
    return {"exit_code":rc,"error_count":len(errors),"first_errors":errors[:12],"log":str((OUT/(name+".log")).relative_to(ROOT))}
def main():
    src=(ROOT/"tools/run_native_acceptance.sh").read_text(encoding="utf-8")
    m=re.search(r"for name in (.+?);\s*do",src,flags=re.S)
    if not m:raise RuntimeError("Could not read project 23-suite acceptance list")
    names=m.group(1).split()
    markers=dict(re.findall(r"^\s*(qa_[a-z0-9_]+)\)\s+expected='([^']+)'",src,flags=re.M))
    if len(names)!=23 or any(n not in markers for n in names):
        raise RuntimeError("Acceptance list does not contain exactly 23 mapped test scripts")
    import_cmd=[
        "xvfb-run","-a","-s","-screen 0 1280x720x24",ENGINE,
        "--path",str(ROOT),"--editor","--import","--quit",
        "--audio-driver","Dummy","--rendering-method","gl_compatibility","--rendering-driver","opengl3"
    ]
    print("Importing GLB and textures using Xvfb OpenGL compatibility (not a release gate).",flush=True)
    imported=invoke("xvfb_editor_import",import_cmd,180)
    print("Editor import:",imported,flush=True)
    if imported["exit_code"]!=0:
        summary={"status":"BLOCKED_EDITOR_IMPORT_EXIT_NONZERO","import":imported,"test_results":[]}
        (OUT/"summary.json").write_text(json.dumps(summary,indent=2),encoding="utf-8")
        raise SystemExit(1)
    startup=invoke("main_scene_startup",[
        ENGINE,"--headless","--path",str(ROOT),"--quit-after","15"
    ],90)
    print("Main startup:",startup,flush=True)
    results=[]
    for i,name in enumerate(names,1):
        check=invoke(name,[ENGINE,"--headless","--path",str(ROOT),"--script","res://tests/"+name+".gd"],75)
        output=(OUT/(name+".log")).read_text(encoding="utf-8")
        marker_ok=re.search(markers[name],output,flags=re.M) is not None
        check["explicit_pass_marker"]=marker_ok
        check["qa_pass"]=check["exit_code"]==0 and check["error_count"]==0 and marker_ok
        check["suite"]=name
        results.append(check)
        print(f"[{i:02}/{len(names)}] "+("PASS" if check["qa_pass"] else "FAIL")+" "+name+f" (exit {check['exit_code']}, errors {check['error_count']})",flush=True)
    suites_pass=sum(r["qa_pass"] for r in results)
    import_clean=imported["error_count"]==0
    main_clean=startup["exit_code"]==0 and startup["error_count"]==0
    certified=import_clean and main_clean and suites_pass==23
    summary={
        "type":"diagnostic-run-after-Xvfb-not-a-public-release-certification",
        "godot_expected_version":"4.4.1",
        "import_exit_ok":imported["exit_code"]==0,
        "import_clean":import_clean,
        "main_clean":main_clean,
        "suite_pass_count":suites_pass,
        "suite_failed_count":len(results)-suites_pass,
        "native_qa_certified":certified,
        "import":imported,"startup":startup,"test_results":results,
        "notes":"The main release gate still relies on its original strict runner. Render/engine warnings are NOT ignored here.",
    }
    (OUT/"summary.json").write_text(json.dumps(summary,indent=2),encoding="utf-8")
    (OUT/"summary.txt").write_text(
        f"Xvfb import: exit {imported['exit_code']}, errors {imported['error_count']}\n"
        f"Main startup: exit {startup['exit_code']}, errors {startup['error_count']}\n"
        f"23 Godot suites: {suites_pass}/23 clean PASS\n"
        f"Diagnostic native QA certified: {certified}\n",
        encoding="utf-8")
    print(json.dumps({k:summary[k] for k in ["import_clean","main_clean","suite_pass_count","suite_failed_count","native_qa_certified"]},indent=2),flush=True)
    return 0 if certified else 1
if __name__=="__main__":sys.exit(main())
