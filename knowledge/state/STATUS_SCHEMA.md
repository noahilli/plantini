# Canonical Status Registry

`STATUS_REGISTRY.csv` is the sole mutable authority for delivery status. It is
machine-readable, append-safe, and deliberately separate from implementation
claims in commits or handoffs.

## Record contract

The file is UTF-8 RFC-4180 CSV. Its required columns are:

| Column | Rule |
|---|---|
| `id` | Unique stable work-item, workstream, release, or OQ identifier. Every direct task ID in `todos.md` has exactly one `work_item` row. |
| `record_type` | `release`, `workstream`, `work_item`, or `open_question`. |
| `priority` | `P0`–`P3`, `gate`, or `release`. |
| `status` | Exactly one of `planned`, `ready`, `in_progress`, `verified`, `blocked`, `deferred`. There is intentionally no `done` value. |
| `owner` | Accountable role; multiple roles are semicolon-separated only where the question itself has joint accountability. |
| `requirement_refs` | Requirement IDs or documented contiguous ranges. `todos.md` remains the normative task wording. |
| `depends_on` | Registry IDs; use `NONE` only when no direct tracked dependency exists. |
| `evidence_refs` | IDs from `EVIDENCE.md`; `verified` requires at least one non-`NONE` evidence ID. |
| `blocker_ids` | IDs from `BLOCKERS.md`; a `blocked` record requires at least one. |
| `scope` | Current delivery horizon, not a release promise. |
| `last_reviewed` | ISO date of the last evidence review. |
| `next_action` | Concrete next action; it cannot be a completion claim. |

## Status meaning

- `planned`: accepted backlog work, not yet ready or started.
- `ready`: Definition of Ready is met and work may start; it is not evidence of implementation.
- `in_progress`: a named owner has an active, scoped change. A handoff is still required before `verified`.
- `verified`: the work item's own acceptance is evidenced and its handoff links the evidence. It never proves a whole requirement, milestone, or release unless the corresponding aggregate row is also verified.
- `blocked`: an explicit blocker prevents the next material step.
- `deferred`: intentionally outside the active delivery horizon; it is neither cancelled nor complete.

`Release Candidate`, `Production Ready`, `complete`, and percentage-complete
language may only appear in a release record whose required release-gate
evidence is present. The current release record is explicitly `blocked`.

## Source precedence and derived views

1. `STATUS_REGISTRY.csv` is the status authority.
2. `DECISIONS.md` is the decision register and `BLOCKERS.md` is the blocker register.
3. `EVIDENCE.md` describes admissible evidence and its scope.
4. `PROJECT_STATUS.md` is a rendered human view and must not be edited as an independent status source.
5. `BACKLOG.csv` is a retired legacy-map only. Handoffs provide evidence, but do not themselves alter status.
6. `features/features.csv` is the normative requirement catalogue. Its existing `status` field is a compatibility projection: it may be changed only in the same change as the matching registry/evidence update. As of 2026-08-25 all 95 requirements remain `planned`; no requirement is `verified`.

Before a CI implementation exists, the following invariants are still
deterministic and must be checked in review:

- all 117 direct task IDs in `todos.md` occur once as `work_item` records;
- every ID is unique;
- every status is in the closed vocabulary above;
- every `verified` row cites real evidence;
- every `blocked` row cites a registered blocker;
- every evidence and blocker reference resolves;
- no rendered document claims an RC while `RELEASE-2026-08-25` is blocked.

`INFRA-03` owns promotion of these checks into the existing knowledge CI gate.
Until then, the check is repeatable with standard-library CSV parsing and is
recorded in the handoff for every registry change.

## Update protocol

Follow [the shared knowledgebase protocol](../delivery/shared-knowledgebase-protocol.md)
before and after work. In short: acquire the task lease, change the row to
`in_progress`, attach only reproducible evidence, write the handoff, then ask
the Product Manager to set `verified`. Do not delete historical evidence or
replace another agent's status update.
