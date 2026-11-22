#!/usr/bin/env python3
"""Offline consistency checks for a *proposed* CI pipeline.

This does NOT run Godot or claim any cloud workflow has actually executed.
"""
from pathlib import Path
import re
import sys
import json
root = Path(__file__).resolve().parents[1]
yml = root / '.github' / 'workflows' / 'godot_native_qa.yml'
linux = (root/'tools'/'run_native_acceptance.sh').read_text(encoding='utf-8')
win = (root/'tools'/'run_native_acceptance_windows.ps1').read_text(encoding='utf-8')
ci = yml.read_text(encoding='utf-8') if yml.exists() else ''
problems = []
if not ci: problems.append('Missing CI workflow')
if 'chickensoft-games/setup-godot@v2' not in ci or 'version: "4.4.1"' not in ci:
    problems.append('Pinned Godot setup missing')
if 'include-templates: true' not in ci: problems.append('Windows export templates not requested')
if 'tools/run_native_acceptance.sh' not in ci: problems.append('Native Linux QA script not registered')
if 'build_windows_release.ps1' not in ci: problems.append('Windows internal build tool not registered')
if 'workflow_dispatch' not in ci or 'attempt_windows_exe' not in ci:
    problems.append('No manual opt-in for Windows EXE build')
if 'needs: native_qa' not in ci or 'github.event_name' not in ci:
    problems.append('Windows export is not protected by successful QA and explicit selection')
if 'actions/upload-artifact@v4' not in ci:
    problems.append('CI log artifacts not retained')
if 'permissions:' not in ci or 'contents: read' not in ci:
    problems.append('CI token is not restricted to read-only contents')
if any(k in ci for k in ('gh release create','butler push','itch.io/deploy','github-pages-deploy')):
    problems.append('Unexpected publishing step found')
linux_cases=set(re.findall(r'\b(qa_[A-Za-z0-9_]+)\b', re.search(r'for name in ([^\n]+); do',linux).group(1))) if re.search(r'for name in ([^\n]+); do',linux) else set()
windows_cases=set(re.findall(r"'(?P<test>qa_[a-z0-9_]+)'", re.search(r'\$tests = @\((.*?)\)',win,re.S).group(1))) if re.search(r'\$tests = @\((.*?)\)',win,re.S) else set()
all_tests={p.stem for p in (root/'tests').glob('qa_*.gd')}
if linux_cases != all_tests: problems.append(f'Linux QA list mismatch: missing={sorted(all_tests-linux_cases)} extraneous={sorted(linux_cases-all_tests)}')
if windows_cases != all_tests: problems.append(f'Windows QA list mismatch: missing={sorted(all_tests-windows_cases)} extraneous={sorted(windows_cases-all_tests)}')
for test in sorted((root/'tests').glob('qa_*.gd')):
    source=test.read_text(encoding='utf-8')
    for match in re.finditer(r'root\.add_child\((\w+)\)',source):
        var=match.group(1)
        preceding=source[:match.start()]
        last_inst=max(preceding.rfind('.instantiate()'),preceding.rfind('.new()'))
        last_qa=preceding.rfind(f'{var}.set("qa_mode", true)')
        if last_qa<last_inst:
            problems.append(f'{test.name} enables QA after _ready() for {var}, or never enables QA')
report={'scope':'OFFLINE CI SOURCE CHECK ONLY -- cloud jobs have NOT run',
 'status':'PASS' if not problems else 'FAIL',
 'suites_registered':len(all_tests), 'linux_cases':len(linux_cases),'windows_cases':len(windows_cases),
 'workflow_file':str(yml.relative_to(root)),'errors':problems}
out=root/'documentation'/'CI_PIPELINE_STATIC_CHECK_v0169.json'
out.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
raise SystemExit(1 if problems else 0)
