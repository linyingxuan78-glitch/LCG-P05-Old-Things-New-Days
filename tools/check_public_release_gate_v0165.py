#!/usr/bin/env python3
"""Fails closed when commercial distribution checks have not been documented.
This is a reminder/enforcement in the build process, not legal permission.
Private developer QA exports use a different path and are not blocked here.
"""
from pathlib import Path
import json, sys
root=Path(__file__).resolve().parents[1]
gate=json.loads((root/'documentation/IP_PUBLIC_RELEASE_GATE_v0165.json').read_text(encoding='utf-8'))
issues=[f'{key}: {value}' for key,value in gate['requirements'].items() if value != 'HUMAN_REVIEW_COMPLETED_WITH_EVIDENCE']
if not (root/'licenses/GODOT_BINARY_DEPENDENCIES.txt').is_file():issues.append('Specific Godot binary copyright/licence snapshot: absent')
if gate.get('status') != 'REVIEWED_FOR_PUBLIC_BUILD':issues.append('Official public build sign-off: not issued')
if issues:
 print('PUBLIC COMMERCIAL RELEASE: BLOCKED (this is expected for v0.16.6)')
 for x in issues: print('- '+x)
 sys.exit(2)
print('Administrative documentary gates marked complete; this script is not a legal opinion or tested-game certification.')
