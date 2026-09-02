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

# The status registry is the canonical implementation view. Keep its direct
# work items aligned with the expert-authored TODO inventory and reject status
# claims whose evidence or blockers do not resolve.
status_path = root / "state" / "STATUS_REGISTRY.csv"
todo_path = root.parent / "todos.md"
evidence_path = root / "state" / "EVIDENCE.md"
blocker_path = root / "state" / "BLOCKERS.md"
status_rows: list[dict[str, str]] = []
if status_path.is_file():
    with status_path.open(encoding="utf-8-sig", newline="") as handle:
        status_rows = list(csv.DictReader(handle))
else:
    errors.append("missing: state/STATUS_REGISTRY.csv")

status_ids = [row.get("id", "") for row in status_rows]
if len(status_ids) != len(set(status_ids)):
    errors.append("duplicate status registry ids")

allowed_statuses = {
    "planned", "ready", "in_progress", "verified", "blocked", "deferred",
}
for row in status_rows:
    record_id = row.get("id", "<missing-id>")
    if row.get("status") not in allowed_statuses:
        errors.append(f"{record_id}: invalid status {row.get('status')}")

todo_ids: set[str] = set()
if todo_path.is_file():
    todo_ids = set(re.findall(
        r"\*\*P[0-3]\s+\|\s+([A-Z]+-[0-9]{2}):",
        todo_path.read_text(encoding="utf-8"),
    ))
    if len(todo_ids) != 117:
        errors.append(f"expected 117 direct TODO ids, got {len(todo_ids)}")
else:
    errors.append("missing: ../todos.md")

registry_work_items = {
    row.get("id", "") for row in status_rows if row.get("record_type") == "work_item"
}
missing_work_items = sorted(todo_ids - registry_work_items)
unexpected_work_items = sorted(registry_work_items - todo_ids)
if missing_work_items:
    errors.append(f"status registry missing TODO ids: {','.join(missing_work_items)}")
if unexpected_work_items:
    errors.append(f"status registry has unknown work items: {','.join(unexpected_work_items)}")

def table_ids(path: Path, prefix: str) -> set[str]:
    if not path.is_file():
        errors.append(f"missing: {path.relative_to(root)}")
        return set()
    return set(re.findall(
        rf"^\|\s*({re.escape(prefix)}[A-Z0-9-]+)\s*\|",
        path.read_text(encoding="utf-8"),
        flags=re.MULTILINE,
    ))

evidence_ids = table_ids(evidence_path, "E-")
blocker_ids = table_ids(blocker_path, "B-")
for row in status_rows:
    record_id = row.get("id", "<missing-id>")
    evidence_refs = set(filter(None, row.get("evidence_refs", "").split(";"))) - {"NONE"}
    blocker_refs = set(filter(None, row.get("blocker_ids", "").split(";"))) - {"NONE"}
    for reference in sorted(evidence_refs - evidence_ids):
        errors.append(f"{record_id}: unknown evidence {reference}")
    for reference in sorted(blocker_refs - blocker_ids):
        errors.append(f"{record_id}: unknown blocker {reference}")
    if row.get("status") == "verified" and not evidence_refs:
        errors.append(f"{record_id}: verified without evidence")
    if row.get("status") == "blocked" and not blocker_refs:
        errors.append(f"{record_id}: blocked without blocker")

if errors:
    print("Knowledge validation FAILED")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)
print(
    "Knowledge validation OK: "
    f"{len(rows)} features, {len(role_ids)} roles, "
    f"{len(registry_work_items)} TODO work items, "
    f"{len(evidence_ids)} evidence records, {len(blocker_ids)} blockers"
)
