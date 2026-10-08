# Glossar

Begriffe, die im Plantini-Code und in diesem Handbuch immer wieder vorkommen, mit Kurzdefinition und dem Ort, an dem du sie im Repository oder im Handbuch findest. Fachbegriffe bleiben englisch, wenn sie auch im Code so heißen. Die ältere Begriffsliste des Wissenspakets (`knowledge/product/glossary.md`) ist knapper und teilweise abweichend; bei Widerspruch gilt der Code.

!!! note "So liest du die Tabelle"
    Die Spalte „Wo“ nennt Quellpfade in Backticks (relativ zur Repository-Wurzel) und, wo es sie gibt, eine Handbuchseite. Namen in `Schreibmaschinenschrift` sind Bezeichner im Code.

## Lerninhalte

| Begriff | Bedeutung | Wo |
|---|---|---|
| Ökosystem (`ecosystem`) | Lebensraum als oberste Lerneinheit, zum Beispiel „Mitteleuropäischer Laubwald“. Hat Klimazone, Region, Saison und mehrere Level. Der Demo-Datensatz enthält drei. | `services/platform/src/api/ecosystem/`, `services/platform/src/api/platform/services/core/content/demo-content.de.json`; App: `apps/flutter/lib/features/catalog/` |
| Level (`level`) | Ein Lernschritt innerhalb eines Ökosystems mit Pflanzen, Quizfragen und einer Abschlussregel (`completionRule.requiredQuizIds`, genau drei Pflichtfragen). Der Server entscheidet über den Abschluss. | `services/platform/src/api/level/`, `…/learning/learning-service.js`, `contracts/api.yaml` (`/levels/{levelId}`) |
| Station | Darstellung eines Levels auf dem Lernpfad. Die Pfadansicht zeigt zehn Stationen pro Kapitel. | `apps/flutter/lib/features/catalog/presentation/widgets/researcher_path_view.dart` |
| Pflanze (`plant`) | Eine Art mit Namen, Merkmalen, Medien, Quellen und Review-Status. Darf nur veröffentlicht werden, wenn `reviewStatus` den Wert `approved` hat. | `services/platform/src/api/plant/`, `…/plant/content-types/plant/lifecycles.js` |
| Steckbrief | Strukturierte Beschreibung einer Pflanze (Abschnitte, Bild, Quellen, Sicherheitshinweis), aus dem CMS geliefert. | `GET /plants/{plantId}` in `contracts/api.yaml`; Handbuch: [Datenmodell](../architektur/datenmodell.md) |
| Karteikarte | Die Darstellung des Steckbriefs in der App als Karteikarte (`PlantIndexCard`). | `knowledge/handovers/index-card-and-3d-world.md`, `apps/flutter/lib/features/catalog/presentation/` |
| Lernkarte (`learningCards`) | Genau drei Karten je Pflanze mit Überschrift, Text, Frage und vier Antworten. Daraus entstehen die Quizfragen. Die richtige Antwort muss im Kartentext wörtlich vorkommen. | `services/platform/src/api/platform/services/core/content/lesson-cards.js` |
| Quiz (`quiz`) | Einzelne Frage mit Antwortoptionen, gehört zu einem Level, braucht Review-Status `approved` zur Veröffentlichung. | `services/platform/src/api/quiz/`, `GET /quiz-items` |
| Artkarte (`species-card`) | Zwischengespeicherte, kurze Zusammenfassung zu einer Art nach `speciesKey` (mit Foto und Quelle), unabhängig vom Lernkatalog. | `services/platform/src/api/species-card/`, `…/core/species/species-service.js`, `GET /species/{speciesKey}` |
| Journey-Blueprint (`journey-blueprint`) | Redaktionelle Vorlage, aus der das CMS Entwurfsserien von Leveln und Fragen erzeugt. Nur im Strapi-Admin, keine öffentliche API. | `services/platform/src/api/journey-blueprint/`, `…/content/journey-authoring.js` |

## Lernen und Feld

| Begriff | Bedeutung | Wo |
|---|---|---|
| Level-Attempt (`level-attempt`) | Ein Versuch an einem Level. Wird gestartet und abgeschlossen, jeweils mit Idempotency-Key und Client-ID. | `POST /level-attempts`, `POST /level-attempts/{attemptId}/complete`; `services/platform/src/api/level-attempt/` |
| Learning Event (`learning-event`) | Unveränderliches Ereignis des Lernfortschritts, mit `clientEventId` idempotent. Wird als Batch übertragen. | `POST /learning-events/batch`; `services/platform/src/api/learning-event/` |
| Fund / Beobachtung (`observation`) | Privater Fund mit Foto, Zeitpunkt, optionalem Ort und Notiz. Exakte Orte sind optional und privat. | `services/platform/src/api/observation/`, `/observations` |
| Herbarium | Die persönliche Sammlung der eigenen Funde, offline nutzbar und synchronisiert. In der App als Flaschen-Sammlung dargestellt. | `services/platform/src/api/platform/services/core/herbarium/herbarium-service.js`, `apps/flutter/lib/features/herbarium/`; Handbuch: [Herbarium](../nutzung/herbarium.md) |
| Bestimmung / Identification (`identification-job`) | Asynchroner Serverauftrag, der ein Foto über PlantNet auswertet und die Kandidaten normalisiert. Die App spricht nie direkt mit PlantNet. | `POST /identifications`, `…/core/field/field-service.js`, `…/field/plantnet-provider.js`, `…/field/identification-queue.js` |
| PlantNet | Externer Dienst zur Pflanzenbestimmung, nur über das Backend erreichbar. Im Test und in der Demo durch einen Mock ersetzt. | `infra/plantnet-mock/server.mjs`, `PLANTNET_MODE` in `infra/compose.e2e.yaml` |
| Provider-Guard | Redis-gestützte Quoten- und Circuit-Breaker-Logik für PlantNet-Aufrufe. | `services/platform/src/api/platform/services/core/field/provider-guard.js` |
| Upload (`media/uploads`) | Zweistufiger Foto-Upload: erst reservieren, dann Inhalt senden. Private Fotos liegen im privaten Medienspeicher. | `POST /media/uploads`, `…/core/private-media-store.js` |
| Sync | Abgleich lokaler Offline-Daten mit dem Server über stabile Client-IDs. | `POST /sync`; `apps/flutter/lib/features/field/application/sync_queue_service.dart` |

## Inhalte veröffentlichen

| Begriff | Bedeutung | Wo |
|---|---|---|
| Release (`content-release`) | Versionierte Menge veröffentlichter Inhalte. Ein Client aktiviert ein Release erst nach vollständiger Prüfung von Manifest und Prüfsummen. | `services/platform/src/api/content-release/`, `…/content/release-packages.js`, `GET /content/manifest`; Handbuch: [Inhalte und Releases](../backend/inhalte-releases.md) |
| Manifest | Beschreibung des aktiven Releases mit Paketen, Größen und SHA-256-Prüfsummen. | `GET /content/manifest`, `GET /content/packages/{version}/{packageId}` |
| Cursor | Undurchsichtige Zeichenkette des aktuellen Release-Stands. `GET /content/changes?since=<cursor>` liefert nur Änderungen; ist `since` gleich dem aktuellen Cursor, ist die Liste leer. Der Demo-Seed bildet ihn als SHA-256 über `<Version>:<Zeitstempel>`. | `services/platform/src/api/platform/services/core/strapi-repositories.js` (`findChangesSince`), `…/content/demo-seed.js` |
| Demo-Seed | Synthetische deutsche Inhalte, die der Server beim Start importiert, wenn `PLATFORM_SEED_DEMO_CONTENT=true`. | `services/platform/src/index.js`, `…/content/demo-seed.js` |
| Review-Status (`reviewStatus`) | Botanische Freigabe einer Pflanze oder Frage; ohne `approved` ist die Veröffentlichung gesperrt. | `lifecycles.js` der Inhaltstypen `plant`, `quiz`, `level` |
| Lifecycle | Strapi-Hook (`beforeCreate`, `beforeUpdate`), der Veröffentlichungsregeln erzwingt. | `services/platform/src/api/*/content-types/*/lifecycles.js` |

## Oberflächen und Rollen

| Begriff | Bedeutung | Wo |
|---|---|---|
| Fach-API | Die öffentliche Schnittstelle `/api/v1`; die App spricht ausschließlich mit ihr und mit Keycloak. | `services/platform/src/api/platform/routes/platform.js`, `contracts/api.yaml`; Handbuch: [Backend & API](../backend/index.md) |
| Studio | Separate Redaktionsoberfläche für Entwürfe und fachliches Review (statische Webanwendung). | `apps/editor/`; Handbuch: [Studio-Technik](../studio/studio-technik.md) |
| Portal | Lehrendenportal zur Verwaltung von Klassen und Schülerkonten. | `apps/teacher/`; Handbuch: [Portal-Technik](../studio/portal-technik.md) |
| Strapi-Admin | Interne Strapi-Oberfläche; wird nicht öffentlich ausgeliefert und ist kein Ersatz für das Studio. | `knowledge/editor-studio.md`, `infra/production/Caddyfile` (nur `/api/v1/*` wird proxyt) |
| Homepage | Statische Projektseite mit three.js-Szenen. | `apps/homepage/`; Handbuch: [Homepage](../betrieb/homepage.md) |
| Klasse, Schüler (`teaching-class`, `teaching-student`) | Verwaltungsobjekte des Portals; Konten liegen in Keycloak, Verwaltungsdaten im Backend. | `services/platform/src/api/teaching-class/`, `…/teaching-student/`, `…/core/teaching/teaching-service.js` |
| Rollen | Realm-Rollen: `lernende`, `lehrende`, `inhaltsredaktion`, `botanisches_review`, `systemadministration`, `organisationsadministration`, `forschende`. | `services/identity/realm/plantini-realm.json` |

## Identität und Sicherheit

| Begriff | Bedeutung | Wo |
|---|---|---|
| Keycloak | Identity Provider (Version 24.0.4). Hält Identitäten, Sitzungen und Rollen, keine Lern- oder Herbariumdaten. | `services/identity/`, `infra/compose.e2e.yaml`; Handbuch: [Identität & Keycloak](../betrieb/identity-keycloak.md) |
| Realm | Mandant in Keycloak. Plantini nutzt genau einen Realm: `plantini`. Er wird nur beim ersten Start importiert. | `services/identity/realm/plantini-realm.json` |
| Client (OIDC) | Registrierte Anwendung im Realm, zum Beispiel `plantini-web-dev`, `plantini-mobile-dev`, `plantini-editor-dev`, `plantini-teacher-dev` und deren `-production`-Gegenstücke. Die genannten Clients sind öffentliche Clients mit PKCE S256. | `services/identity/realm/plantini-realm.json` |
| PKCE | „Proof Key for Code Exchange“: Authorization-Code-Flow ohne Client-Secret. Verifier und `state` liegen im Browser bzw. in der App. | `apps/flutter/lib/auth/`, `apps/editor/app.js`, `apps/teacher/app.js`; Handbuch: [App-Auth](../app/auth.md) |
| Loopback-Redirect | Rückkehradresse `http://127.0.0.1:4000/` der Desktop-App (lokaler Empfänger). | `apps/flutter/lib/auth/auth_platform_io.dart` |
| App Link | Auf Telefonen verifizierter https-Link, über den die Anmeldung in die App zurückkehrt; Fallback ist das Schema `eu.plantini.app://oauth2redirect`. | `apps/flutter/lib/auth/auth_platform_io.dart`, `apps/flutter/android/app/src/main/AndroidManifest.xml` |
| Audience / Issuer | Prüfwerte der Tokens: die Fach-API validiert `iss` und `aud` (`plantini-api`) gegen den JWKS-Endpunkt. | `services/platform/src/api/platform/services/core/auth/jwt-validator.js`, `PLATFORM_OIDC_ISSUER`, `PLATFORM_OIDC_AUDIENCE` |
| Verwalteter Lernender | Von einer Lehrkraft angelegtes Konto, markiert durch das Admin-only-Attribut `plantini_managed_student`. | `tools/scripts/configure-managed-accounts.mjs` |
| Idempotency-Key | HTTP-Header (16 bis 128 Zeichen, nur zulässige Zeichen) bei wiederholbaren Schreibaufrufen. Gleicher Schlüssel und gleicher Inhalt liefern dasselbe Ergebnis. | `services/platform/src/api/platform/services/core/ids.js`; `components/parameters/IdempotencyKey` in `contracts/api.yaml`; Handbuch: [Idempotenz und Fehler](../backend/idempotenz-fehler.md) |
| Idempotenz | Eigenschaft, dass eine wiederholte Anfrage (zum Beispiel nach Netzabbruch) keine doppelten Funde, Events oder Bestimmungen erzeugt. Dafür tragen Datensätze `idempotencyKey`, `requestDigest` und Client-IDs. | `services/platform/src/api/level-attempt/content-types/level-attempt/schema.json`, `services/platform/src/api/learning-event/content-types/learning-event/schema.json` |

## App, 3D und Darstellung

| Begriff | Bedeutung | Wo |
|---|---|---|
| Modul (3D, `*_module.json`) | Aus Blender exportierte Weltdaten eines Ökosystems (Meshes, Slots, Lichter, Glühwürmchen) für Lernpfad und Vitrine. Es gibt `forest`, `meadow`, `alpine`. | `apps/flutter/assets/worlds/`, `apps/flutter/lib/features/catalog/presentation/widgets/world_module.dart`, `tools/blender/`; Handbuch: [3D & Blender](../3d/index.md) |
| Vitrine | Miniatur eines Ökosystems, die (seit 08.10.2026 ohne Glas und Sockel) schwebend mit Schatten vor dem Hintergrund steht; wird je Winkel einmal gebacken und als Textur wiederverwendet. Der Name stammt aus der früheren Glasvitrine. | `apps/flutter/lib/features/catalog/presentation/widgets/ecosystem_vitrine.dart`; Handbuch: [Leistung](../3d/performance.md) |
| Tageszeit (`DayPhase`) | `morning`, `noon`, `evening`, `night` (05–10, 10–16, 16–21, 21–05 Uhr lokal). Steuert Himmel, Licht und Lichtquellen der Welten. `DayClock` hält die Phase. | `apps/flutter/lib/features/catalog/presentation/widgets/world_lighting.dart`; Handbuch: [Tageszeit und Licht](../3d/tageszeit-licht.md) |
| Explorer | Eine der neun wählbaren Entdeckerfiguren (`kai` ist die Standardfigur). Das Profil speichert nur `{v: 2, id}`. | `apps/flutter/assets/characters/explorers.json`, `apps/flutter/lib/features/character/`, `services/platform/src/api/platform/services/core/profile/character-schema.js`; Handbuch: [Charaktere](../3d/charaktere.md) |
| Isar | Lokale Datenbank der App für Katalog, Warteschlange und Herbarium. | `apps/flutter/lib/core/storage/`; Handbuch: [Offline](../app/offline.md) |
| Client (Dart) | Der aus `contracts/api.yaml` generierte API-Client im Paket `openapi`. | `packages/api/`; Handbuch: [API-Vertrag](../backend/api-vertrag.md) |

## Betrieb und Prozess

| Begriff | Bedeutung | Wo |
|---|---|---|
| E2E-Stack | Frischer, isolierter IPv4-Stack für Demo und Tests (`plantini-e2e`). | `infra/compose.e2e.yaml`, `tools/e2e/scripts/run-e2e-stack.sh`; Handbuch: [Entwicklungsumgebung](../mitmachen/setup.md) |
| Overlay | Zusätzliche Compose-Datei, die über eine Basisdatei gelegt wird (`-f basis -f overlay`). | `infra/compose.{authoring,editor,teacher}.local.yaml` |
| Edge / Proxy | Caddy als HTTPS-Rand vor allen öffentlichen Diensten. | `infra/production/Caddyfile`, `infra/production/compose.proxy.yaml`; Handbuch: [Betrieb](../betrieb/index.md) |
| Aufgaben-ID | Kennung wie `AUTH-03`; verbindet `todos.md`, Statusregistry und Commits. | `todos.md`, `knowledge/state/STATUS_REGISTRY.csv`; Handbuch: [Konventionen](../mitmachen/konventionen.md) |
| Nachweis / Evidence | Eintrag `E-…` in der Nachweisliste; ohne ihn darf nichts `verified` sein. | `knowledge/state/EVIDENCE.md` |
| Engpassartefakt | Datei, die nie parallel ungeprüft überschrieben wird: Vertrag, Migrationen, Realm, Strapi-Schemas, `infra/**`. | `knowledge/delivery/coordination-protocol.md` |
| Handover | Übergabedokument zu einem Thema mit Änderungen, Nachweisen und Risiken. | `knowledge/handovers/`, Vorlage `knowledge/delivery/handoff-template.md` |
| Ownership | Zuordnung Pfad → Rolle → Pflicht-Reviews. | `knowledge/agents/ownership.csv`; Handbuch: [Mitmachen](../mitmachen/index.md) |

## Weiterführend

- [Stolperfallen](stolperfallen.md), [Ports und Dienste](ports-dienste.md)
- [Architektur](../architektur/index.md), [Datenmodell](../architektur/datenmodell.md)
- Quellen: `knowledge/product/glossary.md`, `contracts/api.yaml`, `services/platform/src/`, `apps/flutter/lib/`
