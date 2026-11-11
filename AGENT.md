# Plantini – Einstieg für KI-Agenten (Claude, Codex & Co.)

Diese Datei ist der Startpunkt für jede Agenten-Sitzung. `CLAUDE.md` bindet sie ein; andere Werkzeuge lesen sie direkt.

## Was Plantini ist

Offene Flutter-Lernplattform für Artenkenntnis: Ökosysteme → Level → Steckbrief → Quiz → Feldfoto → Pl@ntNet-Bestimmung (nur serverseitig, im Test gemockt) → privates Offline-Herbarium. Redaktion im Studio (`apps/editor`) auf Strapi, Klassenverwaltung im Lehrendenportal (`apps/teacher`), Identität über Keycloak. Lizenz: Code AGPL-3.0-or-later, Inhalte CC BY-SA 4.0 (`LICENSE`, `NOTICE`).

Ziel ist eine **präsentierbare, öffentlich zugängliche Demo**, kein Produktionsausbau.

## Zuerst lesen

1. `knowledge/AGENT.md` – **verbindliche** Systemgrenzen, Arbeitsprotokoll und Stop-Bedingungen (Pfade dort relativ zu `knowledge/`).
2. `todos.md` – offene Aufgaben mit IDs (`AUTH-06`, `OSS-01`, …).
3. `knowledge/handovers/*.md` – jüngster Entwicklungsstand je Thema (3D-Welt, Karteikarten, App-Design …).
4. `CONTRIBUTING.md` – Commit-, Issue- und PR-Format.
5. Handbuch `docs-site/docs/` – ausführlich zu App, Backend, Betrieb, Studio/Portal; Einstieg `docs-site/docs/mitmachen/index.md`.

## Grenzen, die bei jeder Änderung gelten (Kurzfassung)

- Die App spricht nur mit Fach-API und Keycloak, nie mit Strapi-Admin oder Pl@ntNet.
- Keine Secrets in App, Repository, Image, Testtrace oder Screenshot.
- Levelabschluss und Pl@ntNet-Abgleich validiert der Server; ein Clientergebnis allein zählt nicht.
- Offline-Schreibvorgänge haben stabile Client-IDs und sind idempotent.
- Exakte Fundorte sind privat (die App rundet vor dem Upload, siehe `SECURITY.md`).
- Stoppen und nachfragen bei: Produktionszugang, echten Provider-Secrets, realen Nutzerdaten, irreversibler Migration, ungeklärten Bildrechten, Breaking API Change.

## Layout

| Pfad | Inhalt |
|---|---|
| `apps/flutter/` | App (Web, Linux, Android, iOS). `lib/app` Config/Router/DI, `lib/features/*` Domain/Application/Infrastructure/Presentation, `lib/ui/*` ältere Screens (Spiel, Quiz, Weltkarte), `lib/design_system`, `lib/auth`, `lib/adapters/http`, `lib/dev/*_preview.dart` Designvorschauen (nicht im Router) |
| `apps/editor/`, `apps/teacher/`, `apps/homepage/` | Studio, Lehrendenportal, Projekt-Homepage (statisch, Vite) |
| `packages/api/` | **Generierter** Dart-Client aus `contracts/api.yaml` – nie von Hand editieren |
| `contracts/api.yaml` | OpenAPI 3.1, kanonischer Vertrag |
| `services/platform/` | Strapi 4.25 + Fach-API (`src/api/platform/services/core/*`), Tests in `test/` (`node --test`) |
| `services/identity/` | Keycloak-Realm `plantini`, Validator und Sicherheitstests |
| `infra/` | Compose (dev, e2e, lan, production, authoring, plantnet), nginx, Pl@ntNet-Mock, `production/` (Caddy, Backup) |
| `tools/e2e/` | Playwright (health, contract, web-app, resilience, accessibility) |
| `tools/scripts/`, `tools/blender/` | Validatoren, Client-Generator, Demo-Start, Foto-Prefetch, Blender-Generatoren für 3D-Module |
| `docs-site/` | MkDocs-Handbuch |
| `knowledge/` | Wissenspaket: Rollen, Architektur, Betrieb, Handovers, `state/` (Status, Nachweise, Blocker) |

## Befehle

Immer mit absolutem Pfad oder `cd "$(git rev-parse --show-toplevel)"` arbeiten – `npm` im falschen Ordner scheitert mit ENOENT.

```sh
R="$(git rev-parse --show-toplevel)"

# Flutter (Version aus .flutter-version = 3.47.1, Dart 3.13.1)
cd "$R/apps/flutter" && flutter analyze && flutter test
cd "$R/apps/flutter" && flutter test test/router_test.dart          # einzelne Datei
cd "$R/apps/flutter" && dart format --output=none --set-exit-if-changed lib test

# Backend (Node 20; Node > 20 ist per engines ausgeschlossen)
cd "$R/services/platform" && npm run lint && npm run check && npm test && npm run build
cd "$R" && node --test services/identity/test/*.test.mjs

# Verträge und Konsistenz (blockieren in CI)
cd "$R" && node tools/scripts/validate-api-contract.mjs
cd "$R" && node tools/scripts/validate-ci-config.mjs
cd "$R" && python3 knowledge/scripts/validate_knowledge.py
cd "$R" && npx --yes @redocly/cli@1.34.3 lint contracts/api.yaml

# Client neu erzeugen – nach JEDER Änderung an contracts/api.yaml
cd "$R" && tools/scripts/generate-api-client.sh

# Frischer, isolierter IPv4-Stack + Demo (baut Web-App, legt Testlerner an, druckt Login)
cd "$R" && tools/scripts/start-local-demo.sh [--no-open]     # App http://127.0.0.1:3000, API :1338, Keycloak :8082
cd "$R/tools/e2e" && npm run stack:up && npm test             # Playwright; stack:down räumt auf
cd "$R" && tools/scripts/ci-check.sh                          # kompletter lokaler CI-Lauf
```

## Fallstricke

- `flutter analyze --no-pub lib` (so in älteren Handovers) übersieht Fehler in `test/`. Für Nachweise immer `flutter analyze` ohne Einschränkung.
- Vier Backend-Tests sind Redis-gesteuert und werden ohne Redis **übersprungen** („45 von 49 grün, 4 übersprungen“ ist kein Vollnachweis).
- 13 Flutter-Tests sind seit längerem rot (`TEST-01`); nicht stillschweigend „reparieren“.
- Stack und E2E sind **IPv4-first** (`127.0.0.1` statt `localhost`).
- `start.sh`/`infra/compose.yaml` ist der alte Dev-Stack; der Demo- und E2E-Pfad ist `infra/compose.e2e.yaml` über `tools/e2e/scripts/run-e2e-stack.sh`.
- Demo-Inhalte werden nur bei `PLATFORM_SEED_DEMO_CONTENT=true` importiert; Seeds unter `content/seeds`.
- Keycloak importiert den Realm nur beim ersten Start. Änderungen an `services/identity/realm/plantini-realm.json` wirken auf bestehende Instanzen nicht; dort per Admin-API/`kcadm` nachziehen (Handbuch `betrieb/identity-keycloak.md`).
- Wikimedia liefert beim Fotoabruf HTTP 429; keine Umgehung, keine ungeprüften Ersatzbilder.
- Blender-Generatoren (`tools/blender/*.py`) verweigern das Überschreiben vorhandener Artefakte; Ausgabeordner versionieren.

## Konventionen

- **Commits:** `change|featre|bugfix|test|docs|wip (ID) beschreibung` – Details und Beispiele in `CONTRIBUTING.md`. Keine Co-Author- oder Werkzeug-Zeilen in Commit-Nachrichten.
- **Kein Push** ohne ausdrückliche Anweisung.
- Änderungen an Vertrag, Schema oder Auth immer im selben Inkrement mit Client-Neugenerierung, Tests und Doku (`knowledge/delivery/definition-of-ready-done.md`).
- **Parallele Sitzungen:** Im selben Arbeitsbaum können andere Agenten schreiben. Nie `git stash`, `checkout`, `reset` oder Formatierung über fremde uncommittete Dateien; nur eigene Dateien stagen. Für Vergleiche gegen `HEAD` ein separates `git worktree` anlegen.
- Projektwissen gehört nach `knowledge/` (Handover unter `knowledge/handovers/`), Nachweise nach `knowledge/state/EVIDENCE.md`.

## Status-Quellen

1. `todos.md` – offene Aufgaben (nur Offenes; Erledigtes in der Git-Historie).
2. `knowledge/state/STATUS_REGISTRY.csv` – Status je ID, auch erledigte. Jede ID aus `todos.md` braucht hier eine Zeile, sonst ist `validate_knowledge.py` rot.
3. `knowledge/state/EVIDENCE.md`, `BLOCKERS.md`, `PROJECT_STATUS.md`.
4. `requirements/features.csv`, `knowledge/features/features.csv`, `BACKLOG.csv` – nur noch für Anforderungstexte (FA/NFA).

Nichts auf `verified`/`[x]` setzen ohne Nachweis-ID. „Production Ready“ oder „Release Candidate“ nicht behaupten, solange `RELEASE-2026-08-25` blockiert ist.

## Arbeitsweise

- Nicht behaupten, was nicht gelaufen ist: Build-Erfolg ist keine UI-Abnahme. Nutzerabnahmen (Abschnitt 2 in `todos.md`) sind offen, bis die Person sie bestätigt.
- Keine neuen Tests ohne Absprache, solange die Anpassung der Spieltests (GAME-QA) pausiert ist.

## Geheimnisse

`todos-credentials`, `docs/plantnet-credentials`, `.env*`, `tools/e2e/.runtime/` und `continue-codex` sind git-ignoriert und lokal. **Nie lesen, ausgeben oder in Doku/Screenshots übernehmen.**

`operations/private/` (git-ignoriert) enthält das Roll-out-Protokoll des Betreibers mit Servernamen und Adressen. Lesen ist erlaubt, wenn es um den Produktivbetrieb geht; Inhalte daraus nie in versionierte Dateien übernehmen. Pl@ntNet-Erreichbarkeit nur über `tools/scripts/verify-plantnet-credentials.mjs` prüfen (gibt den Schlüssel nicht aus).
