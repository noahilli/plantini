# GitLab CI/CD

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
