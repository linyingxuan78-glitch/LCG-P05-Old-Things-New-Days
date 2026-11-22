#!/usr/bin/env python3
"""Windows Godot 4.4.1 native QA: NO false green status and NO public release.

Runs an actual GL Compatibility editor import on Windows, main scene startup,
and exactly the 23 existing GDScript suites with their existing PASS markers.
A build is only attempted by CI after every strict stage passes.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"documentation"/"windows_ci_diagnostics"
OUT.mkdir(parents=True,exist_ok=True)
ERR_PATTERN=re.compile(r"(?:^|\s)(?:SCRIPT ERROR:|Parse Error:|Parser Error:|ERROR:|FAILED:)",re.M)

def editor_exe():
    candidates=[os.getenv("GODOT_BIN"),shutil.which("godot"),shutil.which("godot.exe"),shutil.which("Godot.exe")]
    for c in candidates:
        if c and Path(c).is_file():
            return str(Path(c).resolve())
    raise RuntimeError("BLOCKED: no Godot executable (verify setup-godot PATH or GODOT_BIN)")

def invoke(name,cmd,timeout):
    try:
        p=subprocess.run(cmd,cwd=ROOT,text=True,encoding="utf-8",errors="replace",
                         stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=timeout)
        status=p.returncode
        body=p.stdout or ""
    except subprocess.TimeoutExpired as e:
        b=e.stdout or b""
        body=(b.decode("utf-8","replace") if isinstance(b,bytes) else b)+"\nTIMED OUT\n"
        status=124
    (OUT/(name+".log")).write_text(body,encoding="utf-8")
    errors=[line for line in body.splitlines() if ERR_PATTERN.search(line)]
    return {"name":name,"exit_code":status,"godot_error_lines":len(errors),
            "first_errors":errors[:20],"log":name+".log"}

def suite_contract():
    script=(ROOT/"tools/run_native_acceptance_windows.ps1").read_text(encoding="utf-8-sig")
    match=re.search(r"\$tests\s*=\s*@\((.*?)\)\s*\$expectedMarkers\s*=\s*@\{",script,re.S)
    if not match:raise RuntimeError("Could not parse the canonical Windows QA suite list")
    names=re.findall(r"'(qa_[a-z0-9_]+)'",match.group(1))
    markers=dict(re.findall(r"'(qa_[a-z0-9_]+)'\s*=\s*'([^']+)'",script))
    if len(names)!=23 or len(set(names))!=23 or any(n not in markers for n in names):
        raise RuntimeError("Windows QA runner contract changed: expected 23 unique mapped suites")
    for n in names:
        if not (ROOT/"tests"/(n+".gd")).is_file():
            raise RuntimeError("Missing required test "+n)
    return names,markers

def main():
    summary={"platform":"Windows runner only","game_version":"v0.16.9+native-repairs",
             "release_status":"NO_PUBLIC_RELEASE","test_results":[]}
    try:
        engine=editor_exe()
        ver=invoke("godot_version",[engine,"--version"],20)
        version=(OUT/"godot_version.log").read_text(encoding="utf-8").strip()
        summary["engine_version"]=version
        if ver["exit_code"]!=0 or not version.startswith("4.4.1"):
            raise RuntimeError("Expected official Godot 4.4.1: "+version)
        names,markers=suite_contract()
        summary["engine_exe"]=Path(engine).name
        print("Godot 4.4.1 Windows CI version confirmed:",version,flush=True)

        # This is a real Windows renderer import, NOT Linux dummy renderer.
        # A runner without functional graphics may fail; such failures block export.
        imported=invoke("editor_import_gl_compatibility",[
            engine,"--path",str(ROOT),"--editor","--import","--quit",
            "--audio-driver","Dummy",
            "--rendering-method","gl_compatibility","--rendering-driver","opengl3"
        ],180)
        summary["editor_import"]=imported
        summary["clean_editor_import"]=(imported["exit_code"]==0 and imported["godot_error_lines"]==0)
        print("EDITOR IMPORT:",json.dumps(imported),flush=True)
        if imported["exit_code"]!=0:
            raise RuntimeError("Windows real editor import failed; no gameplay tests/build attempted")

        startup=invoke("main_scene_startup",[engine,"--headless","--path",str(ROOT),"--quit-after","15"],75)
        summary["scene_startup"]=startup
        summary["clean_scene_startup"]=(startup["exit_code"]==0 and startup["godot_error_lines"]==0)
        print("MAIN SCENE:",json.dumps(startup),flush=True)

        for i,name in enumerate(names,1):
            result=invoke(name,[engine,"--headless","--path",str(ROOT),
                                "--script","res://tests/"+name+".gd"],90)
            output=(OUT/(name+".log")).read_text(encoding="utf-8")
            result["marker_matched"]=bool(re.search(markers[name],output,re.M))
            result["passed"]=(result["exit_code"]==0 and
                              result["godot_error_lines"]==0 and result["marker_matched"])
            summary["test_results"].append(result)
            print("[%02d/%02d] %s %s (exit %s, error lines %s)"%
                  (i,len(names),"PASS" if result["passed"] else "FAIL",name,
                   result["exit_code"],result["godot_error_lines"]),flush=True)

        summary["passed_suites"]=sum(r["passed"] for r in summary["test_results"])
        summary["total_suites"]=23
        summary["strict_windows_native_qa_passed"]=(
            summary["clean_editor_import"] and summary["clean_scene_startup"]
            and summary["passed_suites"]==23)
        return 0 if summary["strict_windows_native_qa_passed"] else 1
    except Exception as exc:
        summary["blocked_or_failed"]=str(exc)
        print("BLOCKED_OR_FAILED:",str(exc),flush=True)
        return 1
    finally:
        if summary.get("total_suites") is None:
            summary["total_suites"]=23
            summary["passed_suites"]=sum(r.get("passed",False) for r in summary["test_results"])
            summary["strict_windows_native_qa_passed"]=False
        (OUT/"summary.json").write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding="utf-8")
        (OUT/"summary.txt").write_text(
            "Windows native QA pass: "+str(summary.get("strict_windows_native_qa_passed",False))+"\n"+
            "Editor import clean: "+str(summary.get("clean_editor_import","NOT RUN"))+"\n"+
            "Main scene clean: "+str(summary.get("clean_scene_startup","NOT RUN"))+"\n"+
            "Suites passed: "+str(summary["passed_suites"])+"/23\n"+
            "No public build or storefront upload performed by diagnostic.\n",
            encoding="utf-8")

if __name__=="__main__":
    sys.exit(main())
