# CI/CD quality gates

The executable definitions are `.github/workflows/ci.yml` and
`.gitlab-ci.yml`. Both consume Flutter from the repository-level
`.flutter-version`, validate their shared invariants with
`tools/scripts/validate-ci-config.mjs`, lint `contracts/api.yaml`, validate the
knowledgebase and block on backend lint/check/test/build, identity tests and
Flutter format/analyze/test/build. The platform uses one npm lockfile; ESLint
10.9.1 and its flat configuration are part of the reproducible backend gate.

The integration stage uses the isolated IPv4 stack. GitHub builds it directly;
GitLab reuses the correctly configured Flutter web artifact from its build
stage. Both provision a synthetic Keycloak learner, wait for dependency
readiness, execute Playwright and upload reports from `tools/e2e/.runtime`.
The main runner includes non-mutating health, public API, CMS publication,
Keycloak security, session and browser-journey projects. It must never create
CMS schemas or insecure realm clients during a verification run; the isolated
core journey provisions a fresh learner instead of reusing progress state.
These checks are release evidence only after the corresponding remote pipeline
has run successfully.

## Stufen

1. `format`: Dart/TypeScript/YAML/Markdown
2. `analyze`: Flutter Analyze, ESLint, Architekturregeln, OpenAPI-Lint
3. `test`: Unit, Widget, Backend, Migration, Contract
4. `security`: Secrets, SAST, Dependencies, Container, SBOM, Lizenz
5. `build`: API/CMS-Image, Flutter Web, Android, iOS
6. `deploy_staging`: Migration, Health, Smoke
7. `e2e`: Playwright, DAST, Accessibility und Provider-Mocks
8. `promote`: geschützter Tag, manuelle Freigabe, Changelog
9. `verify`: Produktion-Smoke, SLO und Rollbackfähigkeit

## Regeln

- Signierte Releases nur aus geschützten Tags.
- iOS auf abgesichertem macOS-Runner; Signiermaterial nur zur Laufzeit.
- Migrationen zuerst Staging, mit Vorwärts-/Rollbackstrategie.
- Contract-/Realm-/CMS-Export-Diffs sind Reviewartefakte.
- High/Critical Security, fehlgeschlagene Tests oder nicht reproduzierbarer Build blockieren.
- Playwright-Bootstrap ist kein regulärer Produktionsjob; Produktion importiert geprüfte Artefakte.
