# Blocker Register

This register contains conditions that stop a material next step. A risk is
not a blocker merely because it is undesirable; it becomes one when the
specified exit condition is required before safe progress or acceptance.

| ID | Severity | Blocks | Accountable owner | Exit condition | Evidence / next review |
|---|---|---|---|---|---|
| B-EVIDENCE-01 | critical | RC/release claims and any `verified` aggregate claim | product-manager; release-manager | Every claimed release gate has reproducible evidence on a fresh environment. | `E-BASELINE-01`; review before any tag. |
| B-CI-01 | high | API/QA/infra acceptance and release | devops-release | Required format, analysis, tests, contract, security, and knowledge checks fail the pipeline when red. | `INFRA-03`; no current blocking-pipeline evidence. |
| B-ENV-01 | high | integration and E2E acceptance | devops-release | A fresh seeded stack with backing services and readiness checks is running and reproducible. | `INFRA-04`; baseline says containers are not confirmed running. |
| B-REMOTE-01 | high | remote-pipeline claim | devops-release | Authorised publication of the relevant commits and a successful remote pipeline artifact. | `INFRA-01`; local state is not remote proof. |
| B-TESTDATA-01 | high | auth and UI E2E | qa-playwright; auth-manager; cms-manager | Synthetic users, roles, content release, and reset procedure are provisioned from the approved specification. | `STATUS-06`; see `delivery/test-data-and-accounts.md`. |
| B-OQ-01 | high | final MVP content count and scientific content acceptance | product-manager; scientific-board | Written decision on global vs per-ecosystem 25/50/75 logic and reviewed seed plan. | `OQ-01`. |
| B-OQ-02 | resolved | production web offline choice | orchestrator; flutter-frontend | Web-Support via SharedPreferences / Isar-Abstraktion; Linux-Desktop-Plattform hinzugefügt. | `OQ-02`; `OFFLINE-01`. |
| B-OQ-03 | high | stable API boundary and contract implementation | orchestrator; backend-api | Sync/worker spike compares Strapi extension and separate service with recorded decision. | `OQ-03`; `API-01`. |
| B-OQ-04 | critical | minor-facing consent, research, certificate, and pilot | product-manager; security-privacy; legal | Approved target ages, consent texts/versions, legal basis, and retention decision. | `OQ-04`; no inferred legal approval. |
| B-OQ-05 | high | real PlantNet activation and field pilot | product-manager; backend-api; devops-release | Provider contract, quota, flora, attribution, privacy assessment, and staging load evidence. | `OQ-05`; mock-only development remains allowed. |
| B-OQ-06 | high | organisation administration and reporting | product-manager; auth-manager; backend-api | Signed MVP organisation boundary and server-side claim/policy model. | `OQ-06`; query parameters alone are not authority. |
| B-OQ-07 | high | public repository/content publication | steering-committee; legal | Approved licence register for code, text, and each asset class. | `OQ-07`. |
| B-OQ-08 | medium | production social/institutional login and beta | auth-manager; release-manager | Selected provider set, redirect domains, client registrations, and Store obligations. | `OQ-08`; local test IdP remains allowed. |
