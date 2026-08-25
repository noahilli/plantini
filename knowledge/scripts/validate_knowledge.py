#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
errors: list[str] = []
required = [
    "AGENT.md", "manifest.yaml", "features/features.csv",
    "contracts/openapi-seed.yaml", "operations/compose.blueprint.yml",
    "prompts/START_DEVELOPMENT.md", "references/plantini-anforderungen.pdf",
]
for relative in required:
    if not (root / relative).is_file():
        errors.append(f"missing: {relative}")

feature_path = root / "features" / "features.csv"
rows = []
if feature_path.is_file():
    with feature_path.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    ids = [row.get("id", "") for row in rows]
    if len(rows) != 95:
        errors.append(f"expected 95 features, got {len(rows)}")
    if len(ids) != len(set(ids)):
        errors.append("duplicate feature ids")
    if sum(item.startswith("FA") for item in ids) != 63:
        errors.append("functional requirement count must be 63")
    if sum(item.startswith("NFA") for item in ids) != 32:
        errors.append("non-functional requirement count must be 32")
    known = set(ids)
    for row in rows:
        for field in ("title", "priority", "description", "acceptance_criteria", "primary_role", "status"):
            if not row.get(field):
                errors.append(f"{row.get('id')}: missing {field}")
        for ref in filter(None, row.get("cross_references", "").split(";")):
            if ref not in known:
                errors.append(f"{row.get('id')}: unknown reference {ref}")

role_ids = set()
for path in (root / "agents").glob("[0-9][0-9]-*.md"):
    match = re.search(r"\*\*Rollen-ID:\*\* `([^`]+)`", path.read_text(encoding="utf-8"))
    if match:
        role_ids.add(match.group(1))
for row in rows:
    if row.get("primary_role") not in role_ids:
        errors.append(f"{row.get('id')}: no role file for {row.get('primary_role')}")

if errors:
    print("Knowledge validation FAILED")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)
print(f"Knowledge validation OK: {len(rows)} features, {len(role_ids)} roles")
