# Tests und CI

Diese Seite ist die Anleitung für die QA-Spur: welche Prüfungen es gibt, wie du sie lokal ausführst, was die beiden CI-Konfigurationen tun und welche Lücken und roten Tests heute bestehen. Alle Zahlen mit dem Vermerk „lokal gemessen“ habe ich am 05.10.2026 im Arbeitsbaum selbst erhoben; sie sind Momentaufnahmen und können sich mit dem nächsten Commit ändern.

!!! warning "Aktueller Stand in einem Satz"
    Lokal gemessen: Backend 45 von 49 Tests grün (4 übersprungen), Realm-Tests 5 von 5, Flutter 128 grün und 13 rot, `flutter analyze` mit einem Fehler. Die CI-Gates für Flutter-Analyse und Flutter-Tests würden heute also fehlschlagen; das Wissens-Gate (`validate_knowledge.py`) ist seit 11.11.2026 grün. Details unten.

`$R` steht in den Befehlen für das Repository-Verzeichnis (siehe [Entwicklungsumgebung](setup.md)).

## Überblick

| Ebene | Werkzeug | Ort | Läuft ohne Stack |
|---|---|---|---|
| Flutter Unit/Widget | `flutter test` | `apps/flutter/test/` | ja |
| Flutter Statik | `flutter analyze`, `dart format` | `apps/flutter/` | ja |
| Generierter Client | `dart analyze`, `dart test` | `packages/api/` | ja |
| Backend | `node --test` | `services/platform/test/` | ja (Redis-Tests übersprungen) |
| Realm-Sicherheit | `node --test` | `services/identity/test/` | ja |
| Vertrag | Node-Skript, Redocly | `tools/scripts/validate-api-contract.mjs`, `contracts/api.yaml` | ja |
| CI-Konfiguration | Node-Skript | `tools/scripts/validate-ci-config.mjs` | ja |
| Wissenspaket | Python | `knowledge/scripts/validate_knowledge.py` | ja |
| E2E | Playwright | `tools/e2e/` | nein (Stack nötig) |
| Leistung | Integrationstest | `apps/flutter/integration_test/perf_walk_test.dart` | ja, braucht Gerät/Display |

## Flutter

```sh
cd $R/apps/flutter && flutter analyze
cd $R/apps/flutter && flutter test
cd $R/apps/flutter && flutter test test/router_test.dart         # einzelne Datei
cd $R/apps/flutter && dart format --output=none --set-exit-if-changed lib test
```

!!! warning "Stolperfalle: `flutter analyze` ohne `lib`"
    In älteren Handovers steht `flutter analyze --no-pub lib`. Das **übersieht Fehler in `test/`**. Die CI ruft `flutter analyze` ohne Pfad auf (`.gitlab-ci.yml`, `.github/workflows/ci.yml`, `tools/scripts/ci-check.sh`); für Nachweise nimmst du denselben Aufruf.

Aufbau von `apps/flutter/test/` (28 Testdateien): Top-Level-Tests für Konfiguration (`app_config_test.dart`), Auth (`auth_platform_io_test.dart`), Routing (`router_test.dart`), Inhalts-Sync (`content_sync_test.dart`, `progress_sync_test.dart`, `sync_queue_test.dart`), Feld/Herbarium (`field_and_herbarium_test.dart`, `offline_herbarium_repository_test.dart`, `http_field_and_herbarium_repository_test.dart`), Lernfluss (`learning_flow_test.dart`) und Widget-Abläufe; dazu `core/` (`image_service_test.dart`) und `features/{catalog,learning,character}/…`. Der Widget-Ablauf nutzt Fakes: `createWidgetFlowDependencies({int extraLevels = 0})` in `test/app_flow_widget_test.dart` baut komplette `AppDependencies` ohne Netzwerk; der Leistungs-Messlauf verwendet dieselbe Funktion.

### Bekannte rote Tests (TEST-01)

`todos.md` führt die Aufgabe `TEST-01` (seit 11.11.2026 P0 als Voraussetzung für eine aussagekräftige öffentliche CI, Registry-Status `planned`, Owner `qa-playwright`): „13 schon vor diesen Änderungen fehlschlagende Flutter-Tests reparieren … `game05_herbarium_bottles_test.dart` kompiliert nicht: `await tester.view.reset()` ist `void`“. Die Zahl 13 stimmt mit meiner Messung überein.

Lokal gemessen (`flutter test`, 05.10.2026): `+128 -13`. Die 13 Fehler im Einzelnen:

| Datei | Test | Art |
|---|---|---|
| `test/game05_herbarium_bottles_test.dart` | (ganze Datei) | **Kompilierfehler** `Error: This expression has type 'void' and can't be used.` bei Zeile 311 (`await tester.view.reset();`) |
| `test/app_flow_widget_test.dart` | Plantini widget flow uses fakes for the visible Login -> Lernen -> Profil -> Logout journey | Testfehler |
| `test/domain_logic_test.dart` | Level Rules legacy levels use their first three plants as collection targets | Testfehler |
| `test/features/catalog/presentation/widgets/level_gate_card_test.dart` | shows available level correctly | Testfehler |
| `test/features/catalog/presentation/widgets/level_gate_card_test.dart` | shows completed level correctly | Testfehler |
| `test/features/catalog/presentation/widgets/researcher_path_view_test.dart` | active level renders its herbarium collection mission | Testfehler |
| `test/features/catalog/presentation/widgets/researcher_path_view_test.dart` | completed path celebrates the ecosystem goal | Testfehler |
| `test/features/catalog/presentation/widgets/researcher_path_view_test.dart` | ResearcherPathView displays levels sorted by sequence | Testfehler |
| `test/herbarium_ui_test.dart` | HerbariumDetailScreen Widget Tests renders full detail with PlantNet AI result, sync status, and notes | Testfehler |
| `test/plant_catalog_test.dart` | PlantDetailScreen Widget renders cleanly without optional warning or media | Testfehler |
| `test/plant_catalog_test.dart` | PlantDetailScreen Widget renders plant details, warning and sources | Testfehler |
| `test/router_test.dart` | GoRouter & Navigation renders HerbariumScreen | Testfehler |
| `test/router_test.dart` | GoRouter & Navigation renders PlantDetailScreen via router fallback | Testfehler |

Die Ursachen der zwölf Testfehler habe ich **nicht untersucht**; sie gelten laut `knowledge/handovers/herbarium-map-character-daytime.md` (Abschnitt „Tests“) als Altlasten vor den damaligen Änderungen (Stand `7a4bf03`).

Dasselbe Problem zeigt `flutter analyze`: ein Fehler und zwei Hinweise, alle in derselben Datei:

```text
error • This expression has a type of 'void' so its value can't be used … • test/game05_herbarium_bottles_test.dart:311:23 • use_of_void_result
```

Damit schlägt auch der Analyse-Schritt der CI heute fehl. `dart format --output=none --set-exit-if-changed lib test` ist dagegen sauber (167 Dateien, 0 Änderungen).

!!! note "Keine neuen Tests, solange GAME-QA pausiert ist"
    Laut Projektstand (Nutzerwunsch seit 07.09.2026) werden zurzeit **keine neuen Tests** geschrieben, und bestehende rote Tests werden nicht stillschweigend „repariert“. Stimm dich vorher ab, wenn du `TEST-01` angehen willst.

## Backend

```sh
cd $R/services/platform && npm ci
cd $R/services/platform && npm run lint && npm run check && npm test && npm run build
```

Die Skripte (`services/platform/package.json`):

| Skript | Bedeutung |
|---|---|
| `npm test` / `npm run test:unit` | `node --test test/*.test.js` |
| `npm run lint` | `eslint config src test` |
| `npm run check` | `node --check src/index.js && node --check src/api/platform/controllers/platform.js` |
| `npm run build` | `strapi build` (Admin-Oberfläche) |

Lokal gemessen (`node --test test/*.test.js`, Node 26.10.0): **49 Tests, 45 bestanden, 0 fehlgeschlagen, 4 übersprungen**. Die Testdateien liegen in `services/platform/test/`: `api-conventions`, `character-schema`, `content-service`, `demo-content`, `field-herbarium`, `field-identification-queue`, `game-journeys`, `game-progress-api`, `idempotency-schema`, `jwt-validator`, `learning-service`, `plantnet-provider`, `provider-guard`, `tile-proxy` (alle `*.test.js`). Die Tests sind hermetisch: `test/helpers/memory-entities.js` ersetzt den Strapi-Entity-Service durch eine Speicher-Variante, die numerische Relationen auflöst, damit der echte Public-ID-Repository-Adapter mitgetestet wird.

### Redis-abhängige Tests werden übersprungen

Vier Tests laufen nur, wenn `PLANTINI_TEST_REDIS_URL` gesetzt ist:

| Datei | Tests |
|---|---|
| `test/provider-guard.test.js` | `FIELD-07: Redis guard preserves quota reserve atomically`, `FIELD-07: transient failures open a shared circuit breaker` |
| `test/field-identification-queue.test.js` | `FIELD-04: a submitted identification travels through the real BullMQ queue until it is identified`, `FIELD-04: a job persisted while the queue was unreachable is recovered and processed` |

Ohne die Variable melden sie `skipped` mit dem Hinweis `PLANTINI_TEST_REDIS_URL is not set`. „45 von 49 grün“ ist deshalb **kein Vollnachweis** der Warteschlangen- und Quotenlogik. Ein Nachweis braucht einen laufenden Redis:

```sh
cd $R/services/platform && PLANTINI_TEST_REDIS_URL=redis://<host>:<port> npm test
```

(Der Redis des E2E-Stacks veröffentlicht keinen Host-Port; starte einen eigenen.) Dieser Lauf mit Redis war **nicht Teil meiner Messung**.

## Realm-Sicherheitstests

```sh
cd $R && node --test services/identity/test/*.test.mjs
```

Lokal gemessen: 5 von 5 bestanden. `services/identity/test/realm-security.test.mjs` prüft, dass der eingecheckte Realm die Entwicklungs-Baseline besteht; dass ein Wildcard-Redirect (`*`) abgelehnt wird; dass `directAccessGrantsEnabled` am Client `plantini-api` abgelehnt wird; dass der Produktions-Gate den reinen Entwicklungs-Realm ablehnt (`production promotion requires sslRequired=all`); und dass `sanitizeRealmExport` Nutzer, Schlüsselkomponenten und Client-Secrets entfernt.

Das Skript lässt sich auch direkt aufrufen. Es verlangt die Realm-Datei als Argument:

```sh
cd $R && node services/identity/scripts/validate-realm-security.mjs services/identity/realm/plantini-realm.json
cd $R && node services/identity/scripts/validate-realm-security.mjs services/identity/realm/plantini-realm.json --environment=production
```

Lokal gemessen: `development` besteht („Realm security validation passed (development)“). `production` liefert gegen die versionierte Datei sechs Befunde, unter anderem `production promotion requires sslRequired=all` und `plantini-web-production: must be enabled only after exact HTTPS/app-link redirects are approved`. Das ist beabsichtigt: Die Produktions-Datei wird erst von `tools/scripts/build-production-realm.mjs` aus der versionierten abgeleitet.

## Vertrag und Konfiguration

```sh
cd $R && node tools/scripts/validate-ci-config.mjs
cd $R && node tools/scripts/validate-api-contract.mjs
cd $R && npx --yes @redocly/cli@1.34.3 lint contracts/api.yaml
cd $R && python3 knowledge/scripts/validate_knowledge.py
```

Lokal gemessen:

| Aufruf | Ergebnis |
|---|---|
| `validate-ci-config.mjs` | OK: `Flutter 3.47.1`, IPv4-E2E-Lebenszyklus und Artefaktpfade stimmen überein |
| `validate-api-contract.mjs` | OK: `52 implemented, 8 planned, generator 7.25.0` |
| `validate_knowledge.py` | OK (seit 11.11.2026; Regeln in den [Konventionen](konventionen.md#das-prufskript-und-sein-aktueller-zustand)) |

`validate-ci-config.mjs` ist ein Konsistenzwächter für beide CI-Dateien: Es verlangt die gleiche Flutter-Version, die Playwright-Image-Version `v1.55.0-noble`, `PLANTINI_E2E_SKIP_WEB_BUILD: "true"` in GitLab, in **beiden** Dateien eine feste Liste von Schritten (u. a. `npm run stack:up`, `npm test`, `npm run stack:down`, `flutter analyze`, `flutter test`, `dart run build_runner build`, `git diff --exit-code -- packages/api`), das Fehlen von `|| true`, `allow_failure: true` und `continue-on-error: true`, die Existenz von `services/platform/package-lock.json` und die Abwesenheit von `yarn.lock`.

## Playwright (E2E)

Die Suite liegt in `tools/e2e/` (`@playwright/test` 1.55.0, `@axe-core/playwright` 4.10.2, TypeScript 5.8.3). Sie testet gegen den isolierten Stack aus [Entwicklungsumgebung](setup.md); es gibt **keinen localhost-Fallback**: alle URLs und Zugangsdaten kommen aus `tools/e2e/.runtime/e2e.env`, die `tools/e2e/scripts/run-with-e2e-env.mjs` vor jedem Befehl lädt.

```sh
cd $R/tools/e2e && npm ci && npm run install:browsers      # einmalig (install:browsers:ci mit --with-deps)
cd $R/tools/e2e && npm run stack:up                         # Stack frisch starten (Flutter 3.47.1 nötig)
cd $R/tools/e2e && npm test                                 # check:stack + alle Projekte
cd $R/tools/e2e && npm run test:health                      # nur ein Projekt
cd $R/tools/e2e && npm run stack:down                       # aufräumen (löscht Volumes)
```

Weitere Skripte: `typecheck` (`tsc --noEmit`), `check:environment`, `check:stack`, `test:list`. Chromium kann per `PLAYWRIGHT_CHROMIUM_EXECUTABLE` auf eine vorhandene Installation zeigen. Mit `PLANTINI_E2E_IPV4_HOSTS=host=IPv4,…` löst Chromium Hostnamen über `--host-resolver-rules` auf feste IPv4-Adressen auf.

### Projekte und Dateien

Die Projekte stehen in `tools/e2e/playwright.config.ts`. Alle außer `health` hängen von `health` ab.

| Projekt | `testMatch` | Datei(en) | Inhalt |
|---|---|---|---|
| `health` | `health/*.spec.ts` | `health/services.spec.ts` | Web-Shell `/healthz` = `ok`, API-Health (`x-api-version: v1`, Antwort `{status:'ok', apiVersion:'v1'}`), OIDC-Discovery |
| `contract` | `contract/*.spec.ts` | `contract/public-content.spec.ts` | veröffentlichter Ökosystem-Detail-Vertrag |
| `auth-contract` | `auth/*.spec.ts` | `auth/realm-contract.spec.ts` | OIDC-Endpunkte; Password-Grant wird abgelehnt |
| `cms-contract` | `cms/*.spec.ts` | `cms/published-release.spec.ts` | ein unveränderliches deutsches Release, unbekannte IDs, undokumentierte Filter |
| `web-app` | nur `qa/core-journey.spec.ts` | `qa/core-journey.spec.ts` | Keycloak-Login → Inhalt → Quiz → Feld → Herbarium → Re-Login |
| `auth-session` | `qa/auth-session.spec.ts` | `qa/auth-session.spec.ts` | Sitzung übersteht einen harten Reload |
| `resilience` | `qa/resilience.spec.ts` | **keine Datei** | |
| `accessibility` | `accessibility/*.spec.ts` | **kein Verzeichnis** | |

Lokal gemessen mit `playwright test --list`: **8 Tests in 6 Dateien**.

!!! warning "Stolperfalle: Projekte ohne Tests, Tests ohne Projekt"
    - `npm run test:resilience` und `npm run test:accessibility` rufen Projekte auf, zu denen **keine Spec-Datei** existiert. `@axe-core/playwright` ist installiert, aber nirgends verwendet. In Dokumentation, die Suiten wie „resilience“ oder „accessibility“ als vorhanden aufzählt, stimmt das nicht.
    - Drei Dateien in `tools/e2e/qa/` passen auf **kein** Projekt und laufen deshalb **nie**: `walking-skeleton.spec.ts`, `learning-flow.spec.ts`, `herbarium-conflict.spec.ts`. Ein neuer Test in `qa/` läuft nur, wenn `testMatch` eines Projekts ihn erfasst. Prüfe mit `npm run test:list`, ob dein Test auftaucht.

### Aufbau eines Tests

Hilfen in `tools/e2e/support/`: `environment.ts` (liest und validiert die Umgebung, IPv4-Zwang), `session.ts` (`provisionIsolatedLearner`, `signInAsE2ELearner`, `signOutFromPlantini`), `ui.ts` (Locator-Sammlung `appUi`, `enableFlutterWebSemantics`). Ein Beispiel aus `tools/e2e/qa/auth-session.spec.ts`:

```ts title="tools/e2e/qa/auth-session.spec.ts"
test('persists the learner session across a clean hard reload', async ({ page }) => {
  const environment = requireE2EEnvironment();
  await signInAsE2ELearner(page, environment);
  const callback = new URL(page.url());
  expect(callback.searchParams.has('code')).toBe(false);

  await page.reload({ waitUntil: 'domcontentloaded' });
  await enableFlutterWebSemantics(page);
  await expect(appUi.ecosystemsTitle(page)).toBeVisible();
});
```

Wichtige Eigenheiten:

- **Flutter-Web braucht die Semantik-Schicht.** Flutter zeichnet auf ein Canvas; Locator wie `getByRole` funktionieren erst, wenn der unsichtbare Knopf „Enable accessibility“ ausgelöst ist. `enableFlutterWebSemantics` macht das per `dispatchEvent('click')`, weil das Element außerhalb des Viewports liegt.
- **Isolierter Lernender pro Lauf.** `provisionIsolatedLearner` legt über die Keycloak-Admin-API einen frischen Nutzer `e2e-<zweck>-<uuid>@plantini.test` an, damit ein Wiederholungslauf keine abgeschlossenen Level erbt (`qa/core-journey.spec.ts` nutzt das).
- **Kein Warten per Sleep.** `core-journey.spec.ts` scrollt Flutter-Listen per Mausrad, bis ein Control sichtbar wird, weil Flutter Listenelemente erst beim Rendern in die Semantik-DOM aufnimmt.
- **Timeouts:** 45 s je Test, 10 s je `expect`; die Kernreise erhöht auf 180 s. In der CI `retries: 1`, `workers: 2`, `forbidOnly`.
- **Artefakte:** Berichte, Traces und Screenshots landen in `tools/e2e/.runtime/{test-results,playwright-report}`; `verify-e2e-env.mjs` erzwingt diese Pfade. Traces und Screenshots werden nur bei Fehlern gehalten (`retain-on-failure`, `only-on-failure`) und nur, wenn `PLANTINI_E2E_CAPTURE_FAILURE_ARTIFACTS=true` gesetzt ist; `prepare-e2e-env.mjs` setzt das lokal auf `true`.

!!! warning "Stolperfalle: IPv4-first"
    Stack und Tests verwenden durchgehend `127.0.0.1` statt `localhost` und `--dns-result-order=ipv4first`. `verify-e2e-env.mjs` lehnt URLs mit IPv6-Literal oder Hostnamen ohne IPv4-Zuordnung ab. Der Grund (IPv6-Probleme auf den Entwicklungsrechnern) ist in den Skripten nur als Kommentar angedeutet („an unavailable IPv6 route cannot make an E2E run flake“), nicht im Detail belegt.

## Lokaler CI-Lauf: `tools/scripts/ci-check.sh`

```sh
cd $R && tools/scripts/ci-check.sh
```

Das Skript hat vier Schritte: (1) Backend (`lint`, `check`, `test`, `build`) und Realm-Tests, (2) `flutter analyze` und `flutter test`, (3) `flutter build web` und `tool/build-linux.sh` mit Entwicklungs-Variablen, (4) Smoke-Tests per `curl --ipv4` gegen `http://127.0.0.1:1338/api/v1/health`, `/api/v1/content/manifest`, `/api/v1/ecosystems` und die Keycloak-Discovery. Es bricht beim ersten Fehler ab (`set -euo pipefail`).

Es ist **kein Ersatz für die CI**. Es führt nicht aus:

- `validate-ci-config.mjs`, `validate-api-contract.mjs`, Redocly und `validate_knowledge.py`,
- die Schritte im Paket `packages/api` (`build_runner`, `dart analyze`, `dart test`, Diff-Prüfung),
- `dart format --set-exit-if-changed`,
- Playwright.

Schritt 4 verlangt einen **bereits laufenden** Stack auf 1338 und 8082 (zum Beispiel nach `start-local-demo.sh`). Zudem enthält Schritt 2 heute zwei Fehlerquellen (Analyse-Fehler und rote Tests), das Skript endet also vor den Smoke-Tests.

## CI-Konfigurationen

Es gibt zwei: `.gitlab-ci.yml` und `.github/workflows/ci.yml`. Beide müssen dieselben Gates enthalten (`validate-ci-config.mjs`). Beide haben keine fail-open-Schritte.

### GitLab (`.gitlab-ci.yml`)

Stufen `lint`, `test`, `build`, `integration`; globale Variable `FLUTTER_VERSION: "3.47.1"`.

| Job | Stufe | Image | Schritte |
|---|---|---|---|
| `ci:configuration` | lint | `node:20.20.2-bookworm-slim` (+ `python3`) | `validate-ci-config.mjs`, `validate-api-contract.mjs`, `redocly lint`, `validate_knowledge.py` |
| `backend:test` | test | `node:20.20.2-bookworm-slim` | `npm ci`, `lint`, `check`, `test`, `build`, danach Realm-Tests |
| `flutter:test` | test | `ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION}` | in `packages/api`: `dart pub get`, `build_runner build`, `dart format`, `dart analyze`, `dart test`, `git diff --exit-code -- packages/api`; in `apps/flutter`: `pub get`, `dart format`, `flutter analyze`, `flutter test` |
| `flutter:build_web` | build | wie oben | `flutter build web --release` mit vier `--dart-define` (Client `plantini-web-dev`), Artefakt `apps/flutter/build/web/` (1 Woche) |
| `e2e:playwright` | integration | `mcr.microsoft.com/playwright:v1.55.0-noble` + Dienst `docker:27.5-dind` | `apt-get install docker.io docker-compose-v2`, `npm ci`, `npm run stack:up`, `npm test`; `PLANTINI_E2E_SKIP_WEB_BUILD: "true"` (nutzt das Artefakt); `after_script`: `stack:down`, falls `.runtime/e2e.env` existiert; Artefakte aus `tools/e2e/.runtime/` |

### GitHub (`.github/workflows/ci.yml`)

Auslöser: Push und Pull Request auf `main`. Drei Jobs:

| Job | Abhängigkeit | Inhalt |
|---|---|---|
| `backend-and-contracts` | | Node 20.20.2 mit npm-Cache; Validatoren, Backend-Gates, Realm-Tests |
| `flutter-test-and-build` | | Linux-Build-Abhängigkeiten, Flutter aus `.flutter-version`, Client-Prüfung wie bei GitLab, `dart format`, `flutter analyze`, `flutter test`, `flutter build web`, `./tool/build-linux.sh` mit Entwicklungs-Variablen |
| `e2e-integration-tests` | `needs: [backend-and-contracts, flutter-test-and-build]` | Node 20.20.2, Flutter, `npm ci`, `npm run install:browsers:ci`, `npm run stack:up`, `npm test`, Upload der Artefakte (`retention-days: 7`), `stack:down` (`if: always()` bzw. wenn `e2e.env` existiert) |

Unterschiede, die du kennen solltest:

- **Web-Build:** GitLab baut `flutter build web --release` mit den vier `--dart-define`; GitHub ruft in `flutter-test-and-build` `flutter build web` **ohne Dart-Defines** auf (reiner Kompilierbeweis). Den E2E-relevanten Build mit Defines erzeugt dort erst `npm run stack:up` selbst (kein `SKIP_WEB_BUILD`), deshalb braucht der E2E-Job eine eigene Flutter-Installation.
- **Linux-Build:** nur in der GitHub-CI.
- **Runner-Isolation:** GitLab nutzt Docker-in-Docker, GitHub den Runner-eigenen Docker.
- **Auslöser:** GitLab definiert keine `rules:`/`only:`-Einschränkungen, die Pipeline läuft also bei jedem Push; GitHub nur für `main` (Push und Pull Request).

!!! note "Kein Remote-Nachweis"
    Für den dokumentierten Stand gab es noch keinen nachgewiesenen Remote-Pipeline-Lauf (Aufgabe `OSS-01` in `todos.md`). Die Aussagen zur CI auf dieser Seite beschreiben die Konfiguration, nicht einen beobachteten Lauf.

## Leistungs-Messlauf

`apps/flutter/integration_test/perf_walk_test.dart` läuft die App mit Fake-Daten (kein Netz, kein Login) durch Home, Lernen, Lernpfad (30 Level, vier Tageszeiten), Herbarium und Profil und druckt je Schritt Bildzeiten: UI-Thread (`build`) und Raster-Thread, jeweils p50, p90 und Maximum, dazu die Zahl der Bilder über 16,7 ms und über 33 ms.

```sh
cd $R/apps/flutter && DISPLAY=:0 flutter drive --profile -d linux \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/perf_walk_test.dart
```

Quelle dieses Befehls ist der Abschnitt „Leistung“ in `knowledge/handovers/herbarium-map-character-daytime.md`; der Treiber `apps/flutter/test_driver/integration_test.dart` existiert (`integrationDriver()`). **Nicht von mir ausgeführt** (braucht Display und Linux-Desktop-Toolchain). Mit `--dart-define=ONLY_HOME=1` läuft nur die Startseite. Der Kommentar am Dateianfang nennt als Alternative `flutter test integration_test/perf_walk_test.dart -d linux --profile`; diese Variante habe ich ebenfalls nicht geprüft.

Hinweise:

- Zahlen sind nur im Profilmodus (`--profile`) aussagekräftig; Debug-Builds sind laut Kommentar „slower by a multiple“.
- Die Tageszeit der Welten fixiert der Test mit `DayClock.pin(phase)` für jede `DayPhase`; in einem normalen Build setzt `--dart-define=PLANTINI_DAYTIME=night` (Werte `morning`, `noon`, `evening`, `night`) die Tageszeit fest (`apps/flutter/lib/main.dart`, `apps/flutter/lib/features/catalog/presentation/widgets/world_lighting.dart`).
- Für Messungen auf einem echten Gerät gibt es `--dart-define=PLANTINI_PERF_LOG=true`: `FrameStats` druckt dann eine Zeile pro Sekunde mit Bildzahl und UI-/Raster-Zeiten (`apps/flutter/lib/core/diagnostics/frame_stats.dart`).
- Referenzwerte (Handover, Messung 01.10.2026, Linux-Profil mit echter GPU, nicht von mir wiederholt): Rasterzeit beim Scrollen der Startseite vor der Korrektur p90 35 ms (Spitzen 200 ms), danach p90 0,5 ms; nicht gemessen sind echte Android-Geräte (`PERF-01` in `todos.md` ist offen).

## Wo ein neuer Test hingehört

| Du änderst … | Test auf niedrigster sinnvoller Ebene |
|---|---|
| Domänenregel in der App | `apps/flutter/test/` (Unit) |
| Widget oder Screen | `apps/flutter/test/` mit Fakes (siehe `createWidgetFlowDependencies`) |
| Service der Fach-API | `services/platform/test/*.test.js` mit `memory-entities.js` |
| Vertrag | `validate-api-contract.mjs` läuft automatisch; ggf. `tools/e2e/contract/` |
| Keycloak-Client oder -Rolle | `services/identity/test/realm-security.test.mjs` bzw. `validate-realm-security.mjs` |
| Nutzerreise im Browser | `tools/e2e/qa/` **und** passendes Projekt in `playwright.config.ts` |

(Beachte die Einschränkung zu neuen Tests oben.)

## Weiterführend

- [Entwicklungsumgebung](setup.md), [Konventionen](konventionen.md), [Repo-Karte](repo-karte.md)
- [Idempotenz und Fehler](../backend/idempotenz-fehler.md) (was die Backend-Tests absichern), [App-Auth](../app/auth.md)
- [Stolperfallen](../referenz/stolperfallen.md)
- Quellen: `.gitlab-ci.yml`, `.github/workflows/ci.yml`, `tools/scripts/ci-check.sh`, `tools/scripts/validate-ci-config.mjs`, `tools/e2e/playwright.config.ts`, `tools/e2e/package.json`, `services/platform/package.json`, `apps/flutter/integration_test/perf_walk_test.dart`, `knowledge/operations/playwright-e2e.md`
