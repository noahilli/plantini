# Repo-Karte

Das Repository ist ein Monorepo. Diese Seite beschreibt jede Top-Level-Struktur und die wichtigen Unterordner mit Zweck und Sprache, und schließt mit einer Tabelle „Wo ändere ich was?“. Alle Pfade sind relativ zur Wurzel des Repositories.

!!! note "Stand der Karte"
    Geprüft am 05.10.2026 gegen den Arbeitsbaum (`git ls-files`, `ls`). Die Zielstruktur in `AGENT.md` (Abschnitt „Zielstruktur des Produkt-Repositories“) ist die Absicht; diese Seite beschreibt, was tatsächlich liegt.

## Überblick

```text
.
├── apps/
│   ├── flutter/        Flutter-App (Web, Linux, Android, iOS)
│   ├── editor/         Studio: statische Redaktionsoberfläche (Nginx)
│   ├── teacher/        Lehrendenportal: statische Webanwendung (Nginx)
│   └── homepage/       Projekt-Homepage (Vite + three.js)
├── services/
│   ├── platform/       Strapi 4.25 + Fach-API (/api/v1)
│   └── identity/       Keycloak-Realm, Prüfskripte, Sicherheitstests
├── packages/api/       generierter Dart-Client (nicht von Hand ändern)
├── contracts/          OpenAPI-Vertrag (api.yaml)
├── infra/              Compose-Dateien, Nginx, Caddy, PlantNet-Mock, Backup
├── tools/              E2E-Tests, Skripte, Blender-Generatoren, Hilfsserver
├── knowledge/          Wissenspaket: Rollen, Architektur, Betrieb, Handover, Status
├── content/            Seed-Datei für Ökosysteme (siehe Hinweis)
├── operations/         Runbooks (Deployment, Backup/Restore)
├── docs/               ADRs, Release Notes, SBOM
├── docs-site/          dieses Handbuch (MkDocs Material)
├── requirements/       features.csv (deprecated)
├── artifacts/          Vorschaubilder und Berichte
├── .github/workflows/  GitHub-CI
└── .gitlab-ci.yml      GitLab-CI
```

## apps/

### apps/flutter

Die App. Dart, Flutter (Version aus `.flutter-version`, aktuell 3.47.1; `pubspec.yaml` verlangt `sdk: ^3.13.1`, Paketname `plantini_app`). Zielplattformen mit Ordnern im Repository: `android/`, `ios/`, `linux/`, `web/`.

| Pfad | Inhalt |
|---|---|
| `lib/main.dart` | Einstieg |
| `lib/app/` | `app_config.dart` (Konfiguration per `--dart-define`), `app_dependencies.dart` (Abhängigkeiten), `router.dart` (go_router), `plantini_app.dart`, `app_version.dart` |
| `lib/auth/` | OIDC/PKCE: `auth_service.dart`, plattformabhängig `auth_platform_io.dart` und `auth_platform_web.dart`, `credential_store.dart` |
| `lib/adapters/http/` | `platform_api_client.dart`: HTTP-Zugriff auf die Fach-API |
| `lib/core/` | Querschnitt: `storage/` (Isar, Web/Native-Fabriken), `images/`, `theme/`, `errors/`, `ids/` (Client-IDs), `widgets/` |
| `lib/design_system/` | `async_state_view.dart`, `plant_specimen_bottle.dart`, `world_art.dart` |
| `lib/features/` | Fachmodule: `catalog`, `learning`, `field`, `herbarium`, `character`, `home`; je Modul bis zu `domain/`, `application/`, `infrastructure/`, `presentation/` |
| `lib/dev/` | Entwicklungsvorschauen (`forest_preview.dart`, `card_preview.dart`, `analysis_preview.dart`, `world_bench.dart`), nicht im Router |
| `assets/worlds/` | Blender-Module als JSON (`forest_module.json`, `meadow_module.json`, `alpine_module.json`) plus Vorschau-PNGs |
| `assets/characters/explorers.json` | die neun Entdeckerfiguren |
| `assets/fonts/` | Caprasimo und Figtree (SIL OFL) |
| `test/` | Widget- und Unit-Tests |
| `integration_test/perf_walk_test.dart` | Leistungs-Messlauf, siehe [Tests und CI](tests-ci.md) |
| `tool/build-linux.sh` | Linux-Build, verlangt vier Build-Variablen |

!!! warning "Stolperfalle: leere Verzeichnisse"
    `apps/flutter/lib/ui/*` und `apps/flutter/lib/storage/` existieren im Arbeitsbaum nur als **leere, nicht versionierte** Verzeichnisse. Wenn ältere Notizen von „älteren Screens in `lib/ui`“ sprechen, ist das überholt; die Screens liegen in `lib/features/*/presentation/`.

### apps/editor (Studio)

Statische Redaktionsoberfläche: `index.html`, `app.js`, `json-editor.js`, `style.css`, ausgeliefert von `nginxinc/nginx-unprivileged` (`Dockerfile`, `nginx.conf`). Vanilla-JavaScript ohne Build-Schritt und ohne `package.json`. `Dockerfile.release-overlay` ist für Quelltext-Updates auf einem schon übertragenen Image. Die Umgebung (lokal oder Produktion) leitet `app.js` am Hostnamen ab (`studio.`-Präfix). Details: [Studio-Technik](../studio/studio-technik.md).

### apps/teacher (Lehrendenportal)

Statische Webanwendung ohne npm-Abhängigkeiten: `index.html`, `app.js`, `style.css`, `config.json` (Entwicklungsstandard), `nginx.conf.template` und `40-teacher-config.sh` (erzeugt beim Containerstart `config.json` und die Nginx-Konfiguration aus Umgebungsvariablen). `compose.yaml` startet das Portal allein. Details: [Portal-Technik](../studio/portal-technik.md).

### apps/homepage

Projektseite mit Vite und three.js: `src/` (u. a. `main.js`, `world.js`, `config.js`, `content.json`), `public/` (Fotos, `worlds/*.json`), Unterseiten `technik/`, `bildnachweise/`, `impressum/`, `datenschutz/`, `scripts/snapshot-content.mjs`, `Dockerfile`, `nginx.conf`, `security-headers.conf`. `engines.node` in `package.json` ist `>=20`. Details: [Homepage](../betrieb/homepage.md).

## services/

### services/platform

Strapi 4.25.10 (CommonJS, Node `>=18 <=20.x`, siehe [Entwicklungsumgebung](setup.md)) mit der Fach-API unter `/api/v1`.

| Pfad | Inhalt |
|---|---|
| `src/index.js` | `bootstrap`: Teaching-Indizes, optionaler Demo-Seed, Redis-Warteschlange, Provider-Guard, Worker |
| `src/api/platform/routes/platform.js` | alle `/v1/…`-Routen (ein Eintrag je Route) |
| `src/api/platform/controllers/platform.js` | ein Handler je Route |
| `src/api/platform/services/core/` | die Geschäftslogik, nach Bereichen: `auth/`, `content/`, `editor/`, `field/`, `herbarium/`, `learning/`, `profile/`, `species/`, `teaching/`; dazu `errors.js`, `http-conventions.js`, `ids.js`, `validation.js`, `platform-runtime.js`, `strapi-repositories.js`, `private-media-store.js` |
| `src/api/<typ>/content-types/<typ>/schema.json` | Strapi-Inhaltstypen (`ecosystem`, `level`, `plant`, `quiz`, `media`, `observation`, `identification-job`, `content-release`, `teaching-*`, …) |
| `src/api/<typ>/content-types/<typ>/lifecycles.js` | Veröffentlichungsregeln für `level`, `plant`, `quiz`, `media`, `journey-blueprint` |
| `config/` | `database.js` (Standard-Client `sqlite`, Produktion: `postgres`), `middlewares.js` (CORS), `server.js`, `plugins.js`, `api.js`, `admin.js` |
| `test/*.test.js` | Backend-Tests (`node --test`) |
| `Dockerfile`, `Dockerfile.release-overlay` | Image; der Build führt `npm run lint && npm run check && npm test && npm run build` aus |
| `tmp_plant.json`, `tmp_quiz.json` | versionierte Hilfsdateien ohne Verwendung im Code (nicht untersucht) |

Die Teile der Fach-API erklärt das Kapitel [Backend & API](../backend/index.md), den Aufbau der Services [Services](../backend/services.md).

### services/identity

| Pfad | Inhalt |
|---|---|
| `realm/plantini-realm.json` | versionierter, geheimnisfreier Realm-Export (Clients, Rollen, Scopes) |
| `scripts/validate-realm-security.mjs` | Sicherheitsprüfung des Realms (`--environment=development|staging|production`) |
| `scripts/sanitize-realm-export.mjs` | entfernt Nutzer, Schlüssel und Client-Secrets aus einem Export |
| `test/realm-security.test.mjs` | Tests für beides |
| `Dockerfile` | Keycloak 24.0.4 mit `kc.sh build` für `start --optimized` |

## packages/api

Generierter Dart-Client (`dart-dio` mit `built_value`), erzeugt aus `contracts/api.yaml`. **Nicht von Hand ändern.** Die Dateien `.openapi-generator/{FILES,SPEC_SHA256,TREE_SHA256,VERSION}` halten Generatorversion und Prüfsummen; `tools/scripts/validate-api-contract.mjs` prüft sie. Neu erzeugen mit `tools/scripts/generate-api-client.sh`. Ablauf: [API-Vertrag](../backend/api-vertrag.md).

## contracts

`contracts/api.yaml`: OpenAPI 3.1, der kanonische Vertrag (Pfade wie `/me`, `/content/manifest`, `/level-attempts`, `/observations`, `/teaching/…`). Jede Operation trägt `operationId`; geplante Operationen sind mit `x-plantini-implementation-status: planned` markiert, alle anderen gelten als implementiert und müssen eine Route in `services/platform/src/api/platform/routes/platform.js` haben. Die Referenz steht in der [API-Referenz](../backend/api-referenz.md).

## infra

| Datei | Zweck |
|---|---|
| `compose.e2e.yaml` | frischer, isolierter IPv4-Stack (Demo und E2E); der Standardweg |
| `compose.authoring.local.yaml` | Overlay: Quelltext von `services/platform/src` read-only einhängen |
| `compose.editor.local.yaml` | Overlay: Studio-Container, CORS, Seed aus |
| `compose.teacher.local.yaml` | Overlay: Portal-Container und Keycloak-Verwaltungsclient |
| `compose.yaml` | alter Dev-Stack (Postgres, Keycloak, Redis, MinIO, Mailpit, MockServer) |
| `compose.plantnet.local.yaml` | Opt-in-Overlay für den echten PlantNet-Provider (nur mit `compose.yaml`) |
| `compose.production.yaml` | Produktionsstack (Platform, Postgres, Redis, Keycloak, Homepage, Studio, Portal) |
| `production.env.example` | Vorlage der Produktions-Variablen |
| `production/Caddyfile`, `production/compose.proxy.yaml` | HTTPS-Rand (Caddy) |
| `production/backup.sh`, `plantini-backup.service`, `plantini-backup.timer` | tägliche Sicherung |
| `production/configure-smtp.sh` | SMTP im laufenden Realm setzen |
| `production/update-release-env.mjs`, `promote-public-assets.mjs` | Release-Hilfen |
| `scripts/keycloak-bootstrap-e2e.sh` | legt den synthetischen Test-Lernenden an |
| `plantnet-mock/` | deterministischer PlantNet-Mock (`server.mjs`, `Dockerfile`) |
| `nginx/e2e.conf` | Nginx-Konfiguration des Web-Containers im E2E-Stack |

Details zum Betrieb: [Betrieb](../betrieb/index.md).

## tools

| Pfad | Zweck |
|---|---|
| `tools/e2e/` | Playwright-Projekt (TypeScript) und Stack-Skripte (`scripts/`) |
| `tools/scripts/start-local-demo.sh` | Demo starten und Zugang ausgeben |
| `tools/scripts/ci-check.sh` | lokaler CI-Lauf (unvollständig, siehe [Tests und CI](tests-ci.md)) |
| `tools/scripts/generate-api-client.sh` | Dart-Client neu erzeugen |
| `tools/scripts/validate-api-contract.mjs`, `validate-ci-config.mjs` | Konsistenzprüfungen |
| `tools/scripts/configure-local-editor.mjs`, `configure-managed-accounts.mjs` | Keycloak lokal einrichten (Studio, Portal) |
| `tools/scripts/build-production-realm.mjs` | Produktions-Realm aus dem versionierten Realm ableiten |
| `tools/scripts/prepare-app-release.mjs` | APK-Metadaten erzeugen |
| `tools/scripts/verify-plantnet-credentials.mjs`, `verify-teacher-production.mjs` | Prüfskripte (Zugangsdaten nie ausgeben) |
| `tools/scripts/botany_data.py`, `generate_botany_dataset.py`, `seed_wikipedia_botany.py` | ältere Python-Skripte zur Datenerzeugung (nicht Teil des aktuellen Seed-Wegs) |
| `tools/blender/` | Python-Generatoren für 3D-Module und Figuren: `create_ecosystem_modules.py`, `create_forest_world.py`, `export_forest_module.py`, `add_night_lights.py`, `create_explorer_characters.py` |
| `tools/openapi/analysis_options.yaml` | wird von `generate-api-client.sh` ins generierte Paket kopiert |
| `tools/prefetch-plant-photos.mjs` | Fotoabdeckung gegen den lokalen Stack prüfen, schreibt `artifacts/content/plant-photo-coverage.json` |
| `tools/serve-flutter-review.py` | IPv4-Hilfsserver für einen Web-Build (`--directory`, `--port`, Standard 3000) |

## knowledge, docs, operations

| Pfad | Inhalt |
|---|---|
| `knowledge/` | Wissenspaket: `agents/` (Rollen, `ownership.csv`), `architecture/`, `delivery/`, `operations/`, `handovers/`, `state/` (Statusregistry, Nachweise, Blocker), `features/`, `product/`, `references/`, `scripts/validate_knowledge.py` |
| `knowledge/state/` | `STATUS_REGISTRY.csv`, `EVIDENCE.md`, `BLOCKERS.md`, `PROJECT_STATUS.md`, `DECISIONS.md`, `RISKS.md` |
| `knowledge/handovers/` | jüngster Entwicklungsstand je Thema (Spiel, Karteikarten, 3D-Welt, Lernmaterial) |
| `docs/adr/` | Architekturentscheidungen (`001-initial-architecture.md`, `002-api-v1-boundary.md`) |
| `docs/RELEASE_NOTES.md`, `docs/SBOM.md` | Release Notes und Stückliste (Stand August 2026, teils überholt) |
| `operations/runbooks/` | `deployment.md`, `production-deploy.md`, `backup-restore.md` |
| `requirements/features.csv` | **deprecated**; nur für Anforderungstexte FA/NFA |

!!! warning "Stolperfalle: Seeds"
    `content/seeds/01-ecosystems-levels.json` wird von keinem Skript und keinem Quelltext referenziert (`grep` über `*.js`, `*.mjs`, `*.sh`, `*.py`, `*.yaml`, `Dockerfile` findet nichts). Der tatsächliche Demo-Seed (`PLATFORM_SEED_DEMO_CONTENT=true`) liest `services/platform/src/api/platform/services/core/content/demo-content.de.json` über `demo-seed.js`. Inhalte für die Demo änderst du dort.

## Nicht versioniert oder lokal

| Pfad | Bedeutung |
|---|---|
| `.runtime/` | lokal, in `.gitignore` |
| `tools/e2e/.runtime/` | vom Stack erzeugt (`e2e.env`, Berichte, lokale Studio-Konten); enthält Geheimnisse, nie lesen oder ausgeben |
| `apps/flutter/build/`, `apps/flutter/coverage/`, `apps/homepage/dist/`, `node_modules/` | Build- und Abhängigkeitsordner, ignoriert |
| `apps/flutter/android/key.properties`, `*.jks`, `*.keystore` | Signierung, ignoriert |
| `docs/plantnet-credentials`, `todos-credentials`, `.env*`, `continue-codex` | Zugangsdaten bzw. lokale Notizen, ignoriert oder lokal; nie lesen |
| `dummy.png`, `mock.json` | Wegwerfdateien im Wurzelverzeichnis, ignoriert |

## Wo ändere ich was?

| Ich will … | Ändere … | Danach |
|---|---|---|
| einen API-Endpunkt hinzufügen | `contracts/api.yaml`, `services/platform/src/api/platform/routes/platform.js`, `controllers/platform.js`, Service unter `services/core/<bereich>/` | `tools/scripts/generate-api-client.sh`, `node tools/scripts/validate-api-contract.mjs`, Tests, Doku. Siehe [Neuer Endpunkt](../backend/neuer-endpunkt.md) |
| eine Fehlermeldung des Backends anpassen | `services/platform/src/api/platform/services/core/errors.js` | `npm test` in `services/platform` |
| ein Strapi-Feld ergänzen | `services/platform/src/api/<typ>/content-types/<typ>/schema.json` | Vertrag und Mapper (`content-service.js`) prüfen; Migration beachten |
| Veröffentlichungsregeln ändern | `…/content-types/<typ>/lifecycles.js` | Demo-Seed und Tests prüfen |
| Demo-Inhalte ändern | `services/platform/src/api/platform/services/core/content/demo-content.de.json` | Release-Version in `demo-content.js` beachten |
| erlaubte Browser-Origins ändern | Umgebungsvariable `CORS_ORIGINS`; Header-Liste in `services/platform/config/middlewares.js` | Compose-Datei der Umgebung |
| einen Keycloak-Client oder eine Rolle ändern | `services/identity/realm/plantini-realm.json` | `node --test services/identity/test/*.test.mjs`; laufende Realms live per Admin-API nachziehen |
| die App-Konfiguration ändern | `apps/flutter/lib/app/app_config.dart` und die `--dart-define`-Werte | Build-Skripte (`tools/e2e/scripts/run-e2e-stack.sh`, `apps/flutter/tool/build-linux.sh`) |
| eine App-Route ergänzen | `apps/flutter/lib/app/router.dart` | `apps/flutter/test/router_test.dart` |
| Login-Verhalten der App ändern | `apps/flutter/lib/auth/` | Realm-Redirects abgleichen |
| ein Weltmodul (3D) ändern | `tools/blender/*.py` → `apps/flutter/assets/worlds/*_module.json` | `add_night_lights.py` erneut ausführen; siehe [3D & Blender](../3d/index.md) |
| die Tageszeit-Beleuchtung ändern | `apps/flutter/lib/features/catalog/presentation/widgets/world_lighting.dart` | [Tageszeit und Licht](../3d/tageszeit-licht.md) |
| eine Entdeckerfigur ändern | `tools/blender/create_explorer_characters.py` → `apps/flutter/assets/characters/explorers.json`; Whitelist in `services/platform/src/api/platform/services/core/profile/character-schema.js` | Test `services/platform/test/character-schema.test.js` |
| die Studio-Oberfläche ändern | `apps/editor/app.js`, `index.html`, `style.css` | `node --check apps/editor/app.js` |
| das Lehrendenportal ändern | `apps/teacher/app.js` | `node --check apps/teacher/app.js` |
| die Homepage ändern | `apps/homepage/src/` | `npm run build` in `apps/homepage` |
| den Produktionsstack ändern | `infra/compose.production.yaml`, `infra/production/Caddyfile` | Betriebsregeln in [Betrieb](../betrieb/index.md) |
| einen E2E-Test ergänzen | `tools/e2e/<bereich>/*.spec.ts` und passendes Projekt in `tools/e2e/playwright.config.ts` | sonst läuft die Datei nie (siehe [Tests und CI](tests-ci.md)) |
| eine CI-Stufe ändern | `.gitlab-ci.yml` **und** `.github/workflows/ci.yml` | `node tools/scripts/validate-ci-config.mjs` |
| eine neue Aufgabe anlegen | `todos.md` und `knowledge/state/STATUS_REGISTRY.csv` | `python3 knowledge/scripts/validate_knowledge.py` |
| die Flutter-Version ändern | `.flutter-version` | `.gitlab-ci.yml` (`FLUTTER_VERSION`) abgleichen |

## Weiterführend

- [Entwicklungsumgebung](setup.md), [Konventionen](konventionen.md), [Tests und CI](tests-ci.md)
- [Architektur](../architektur/index.md), [Datenmodell](../architektur/datenmodell.md)
- [Glossar](../referenz/glossar.md)
- Quellen: `AGENT.md`, `knowledge/agents/ownership.csv`, `.gitignore`, `services/platform/package.json`, `apps/flutter/pubspec.yaml`
