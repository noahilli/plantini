# Evidence Register

Evidence is scoped: a passing formatter or a document update is evidence only
for the precise claim below, never for product or release readiness. Paths are
repository-relative and contain no secrets or personal data.

| ID | Collected | Kind | Reference | Result and scope |
|---|---|---|---|---|
| E-BASELINE-01 | 2026-08-25 | independent audit | `todos.md` | Baseline records a valid Compose syntax check and a local Flutter analyze/smoke, but no running integrated environment, complete backend tests, or remote CI proof. This disproves the former RC claim; it is not a release test. |
| E-STATUS-01 | 2026-08-25 | rendered-status review | `state/PROJECT_STATUS.md` | The release view now states development/not-RC and points to the blocked release record. |
| E-STATUS-02 | 2026-08-25 | registry review | `state/STATUS_REGISTRY.csv`; `state/STATUS_SCHEMA.md` | One structured source tracks workstream, task, OQ, dependency, blocker, and evidence fields. |
| E-STATUS-03 | 2026-08-25 | structural validation | `state/STATUS_REGISTRY.csv`; `state/STATUS_SCHEMA.md` | Closed status vocabulary and evidence/blocker invariants are defined; validation result is recorded in the product-manager M5 handoff. |
| E-STATUS-04 | 2026-08-25 | decision review | `state/DECISIONS.md`; `product/mvp-and-open-questions.md` | All eight OQs are visible as blocked with an owner, gate, and unblock condition. |
| E-STATUS-05 | 2026-08-25 | scope review | `product/mvp-and-open-questions.md` | Alpha sequencing is explicit and does not silently remove normative go-live requirements. |
| E-STATUS-06 | 2026-08-25 | test-data specification | `delivery/test-data-and-accounts.md` | Synthetic dataset and account contract defined; provisioning is explicitly not yet evidenced. |
| E-STATUS-07 | 2026-08-25 | product data contract | `product/canonical-content-values.md` | Authoritative sources and prohibited placeholder values are documented; implementation remains open. |
| E-QA-01 | 2026-08-25 | quality strategy | `delivery/test-strategy-and-quality-gates.md` | Test pyramid, evidence boundaries, and release gates are defined; no missing test is credited as passing. |
| E-OQ-01 | 2026-08-25 | decision review | `product/mvp-and-open-questions.md#oq-01` | No scientific count decision is recorded; 75 unique taxa is planning-only. |
| E-OQ-02 | 2026-08-25 | audit review | `todos.md`; `state/handoffs/flutter-frontend-M0-06.md` | A build/smoke does not prove browser storage durability; the spike is still required. |
| E-OQ-03 | 2026-08-25 | architecture review | `product/mvp-and-open-questions.md`; `todos.md` | No completed sync/worker boundary spike exists. |
| E-OQ-04 | 2026-08-25 | governance review | `product/mvp-and-open-questions.md` | Age and consent rules require Product, Privacy, and legal approval. |
| E-OQ-05 | 2026-08-25 | provider review | `todos.md`; `product/mvp-and-open-questions.md` | Development uses a mock; provider contract, quota, attribution, and load evidence are absent. |
| E-OQ-06 | 2026-08-25 | scope review | `product/mvp-and-open-questions.md`; `todos.md` | MVP organisation boundary is not decided; unchecked query filtering is not accepted as a substitute. |
| E-OQ-07 | 2026-08-25 | governance review | `product/mvp-and-open-questions.md` | Final code/content licence decision has no Steering/legal approval record. |
| E-OQ-08 | 2026-08-25 | release review | `product/mvp-and-open-questions.md` | Production social/institutional provider set and redirect domains are not selected. |
| E-REVIEW-ANTIGRAVITY-01 | 2026-08-26 | implementation review | `todos.md`; `apps/flutter/test/app_flow_widget_test.dart`; `apps/flutter/lib/features/herbarium/infrastructure/local_herbarium_repository.dart` | The claimed E2E walkthrough was reclassified as a fake widget flow. The review also found fabricated herbarium data and a local-only sync success path; neither is accepted as product or E2E evidence. |
