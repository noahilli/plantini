# GAME-03 backend handoff

Owner: backend-api → main orchestrator / Flutter / QA. Worktree: `/tmp/plantini-game-backend` (detached HEAD). Only `services/platform/**`, `contracts/api.yaml` and this handoff were changed. The orchestrator reviews the additive contract before integration.

## Result and frontend contract

Release `2026.09.07-de.1` expands the existing 3 ecosystems / 30 plants / 90 source questions into **30 playable sequential levels per ecosystem**, with **3 questions per level** (270 unique quiz record IDs overall). Each level teaches one plant. Three phases of ten plants are explicitly called Kennenlernen, Wiederholen and Festigen. The existing botanical descriptions, questions, choices and answers are reused unchanged; later phases disclose the repetition. No additional botanical facts or species are invented.

- `Level.learningGoal`: phase/review instruction only. Frontend PlantLesson renders the actual plant description separately. `plantIds` identifies that one plant; its complete description, sources and warning remain available through plant GET.
- Every new level has `completionRule.collectionScope: 'ecosystem'`, `requiredLevelIds` and explicit `requiredPlantIds`.
- `minimumScore: 2 / 3`: two of the three answers suffice to pass the demo level.
- Levels 1–29: `requiredPlantIds: []`. Level 30: exactly the three public UUIDs listed below. The final level's teaching plant need not be a collection target.
- Frontend `Level.collectionTargets` must use the explicit rule list; no fallback to teaching `plantIds`.
- `POST /api/v1/level-attempts` enforces prerequisites (`409 LEVEL_LOCKED`). A failed retry uses a new `clientAttemptId`. A passed level remains revisitable. Completing an old/bypassed active attempt also checks access.
- Ordinary and final quiz completion persist `passed` independently of ecosystem collection. Existing `LevelCompletion.passed` / `status` / `progress` drive the level reward UI. No currency, reward balance or new reward persistence is introduced.
- Authenticated level GET remains actor-specific. Prior passed attempts retain completed status after a failed revisit. A progress refresh with `since` cannot discard older unlock history.

Authenticated `GET /api/v1/ecosystems/{ecosystemId}/progress` returns exactly:

```json
{
  "ecosystemId": "public-uuid",
  "status": "collection_pending",
  "completed": false,
  "totalLevels": 30,
  "completedLevelCount": 30,
  "completedLevelIds": ["all-passed-level-public-uuids-in-sequence-order"],
  "requiredPlantIds": ["target-1", "target-2", "target-3"],
  "collectedPlantIds": ["target-1"],
  "missingPlantIds": ["target-2", "target-3"]
}
```

The array contents above are abbreviated placeholders, not real UUID examples. `completed` is the server authority for the trophy. Status is `in_progress` while any published quiz level remains unpassed, `collection_pending` when only collection remains, otherwise `completed`. A frontend refresh/Prüfen action only needs GET; no completion-write endpoint exists.

Collection checks the authenticated owner's non-deleted herbarium `confirmedPlantId` values, across all pages. Early collection counts without starting any level. Only distinct required species count; duplicates, other species, deleted observations and another user's observations cannot satisfy missing targets. Deleting the last record of a required species removes current ecosystem completion on the next GET, while passed quizzes remain passed. Missing herbarium availability fails closed with 503 for the ecosystem check without affecting quiz submission.

Rules without `collectionScope` retain legacy per-level collection gating. Their ecosystem progress simply aggregates passed levels, because collection was already enforced at each level. Mixed or malformed ecosystem rules fail closed.

## Stable target IDs

| Ecosystem | Species | Public plant UUID |
| --- | --- | --- |
| Laubwald (`cf258570-a979-4d4b-8c12-d7f16c630b5c`) | Rotbuche | `e86229bc-320e-41ff-8741-033e3a118cd4` |
| Laubwald | Stieleiche | `2f45b87e-e05f-473d-b56d-2e14f10e45a5` |
| Laubwald | Gewöhnliche Hasel | `6c667c53-23d7-4dbd-b266-0b85a2947cc0` |
| Alpenraum (`1c34e8aa-6f2e-48c7-ad9b-3ce6521db54a`) | Silberwurz | `9776bf4c-fb4b-4d74-bdd1-1d98246a0efb` |
| Alpenraum | Silberdistel | `16cf9ea8-190c-43c7-8d4a-7867dfaa81f2` |
| Alpenraum | Alpen-Aster | `5fda6409-e95f-4dfc-9005-a4d18037b1ac` |
| Wiese (`912c831c-2995-4e3f-8fd6-676c74baa864`) | Wiesen-Salbei | `1dfb7d58-4ba0-4915-a3ca-e17426bfef0f` |
| Wiese | Spitzwegerich | `3ec91620-f9ca-422a-af8e-40251676440c` |
| Wiese | Wiesen-Glockenblume | `5afe1048-5fde-4bc0-a74e-8bbe334952d1` |

Collection means photographic herbarium records, not picking plants. Selection is explicit in `demo-journeys.js`, independent of relation ordering.

## Migration and files

The existing opt-in bootstrap `PLATFORM_SEED_DEMO_CONTENT=true` runs the new seed. No database schema change is needed: completion rules and quiz provenance use existing JSON attributes. Stable plant/ecosystem IDs remain unchanged. New level/quiz IDs are deterministic and phase-specific. Old attempts and observations remain stored; old three-level attempts are not automatically credited as thirty new levels.

The seed retires only the 9 known level IDs and 90 known quiz IDs belonging to `2026.08.28-de.1`, with content-change tombstones. It never deletes those rows, never writes user tables, and does not unpublish unrelated authored content. Matching authored slug/ID collisions outside the owned demo release fail rather than being overwritten. Repeated runs perform no content writes; interrupted content creation and release retirement are recoverable by rerunning. This remains a bootstrap seed, not a transactional online content publishing system; run during the controlled demo restart. Older published records in use by open attempts may become unavailable as in the existing version-conflict behavior.

Implementation files:

- `services/platform/src/api/platform/services/core/content/demo-journeys.js`: phases, targets and validated expansion.
- `services/platform/src/api/platform/services/core/content/demo-content.js`: release version.
- `services/platform/src/api/platform/services/core/content/demo-seed.js`: relation import and scoped retirement.
- `services/platform/src/api/platform/services/core/content/content-service.js`: public completion rules and ordered ecosystem levels.
- `services/platform/src/api/platform/services/core/learning/learning-service.js`: sequential access and computed ecosystem completion.
- `services/platform/src/api/platform/services/core/strapi-repositories.js`: populated ecosystem/plant relations and level ordering.
- Platform controller/routes and `contracts/api.yaml`: authenticated GET and additive schema.
- `services/platform/test/game-journeys.test.js`, `game-progress-api.test.js`, `helpers/memory-entities.js`: migration, service/adapter and controller coverage.

## Validation, limitations and next owner

Executed in this isolated worktree on Node 26.7.0 **before the final user-requested source cleanup**:

- `npm test`: **38 passed, 0 failed, 4 skipped**. Skipped cases require `PLANTINI_TEST_REDIS_URL` and are unrelated Redis queue/guard integrations.
- `npm run lint`: passed.
- `npm run check`: passed.
- `@apidevtools/swagger-parser.validate('../../contracts/api.yaml')`: passed, OpenAPI 3.1.0.
- `git diff --check`: passed.
- Targeted coverage: journey generator and seed both 100% line/branch/function coverage. The expanded learning service has 90.20% line / 82.08% branch coverage in the targeted suite; this does not establish the repository's 90% branch target for the entire learning service.

The 12 new GAME-03 tests exercise all 90 quiz completions, 30 ordered levels per ecosystem, exact quiz/plant relations and source preservation, authentication/response fields, sequential bypass attempts, retries/replays/revisits, actor isolation, collection before starting, final missing/correct/duplicate/foreign/deleted plants, pagination beyond 1000 observations, malformed rules, authored collision protection, migration and interruption recovery.

Initial `npm ci --ignore-scripts` failed because the existing lockfile omits platform-specific optional package entries; the current runtime also exceeds Strapi's declared Node 18–20 range. Validation dependencies were installed locally using `NODE_OPTIONS=--dns-result-order=ipv4first npm install --ignore-scripts --package-lock=false --no-save --no-audit --no-fund @apidevtools/swagger-parser`. No package manifest or lockfile changes are part of this handoff.

No main worktree, Flutter, E2E tooling, TODO or status-registry files were changed. No live PostgreSQL/Strapi/Keycloak or frontend E2E run was performed; the seed/repository tests use an in-memory entity-service boundary. Next: orchestrator reviews/cherry-picks this commit, integrates frontend DTO/repository and trophy refresh, then validates the fresh demo bootstrap and the actual learning/collection journey on the supported runtime over IPv4. Preserve botanical warnings in the frontend introduction and field flow.

Final user steering: stop adding/running tests and separate existing tests into `wip: tests ecosystem journeys`. Source is committed separately as `change (GAME-03) build ecosystem journeys`. The final source cleanup sets learningGoal to the phase notice only, lowers minimumScore to 2/3, and stops collection pagination on a short page even without a reported total. No tests or validation commands were run after this instruction. Existing tests are deliberately preserved as WIP: the old assertion expecting learningGoal to start with plant.description is stale after this cleanup and must be updated when test work resumes. The earlier green results do not validate this final source revision.
