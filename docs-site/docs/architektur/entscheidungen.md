# Architekturentscheidungen

Diese Seite führt die Architekturentscheidungen von Plantini zusammen: die beiden ADR-Dateien im Repository, die ADR-Tabelle der Wissensbasis und die Entscheidungen, die sich erst aus dem Code ergeben. Zu jeder Entscheidung stehen Kontext, Entscheidung, Folgen und Alternativen – und ob der Code sie heute einhält.

## Quellen und Nummerierung

Es gibt drei Quellen, und zwei davon verwenden dieselben Nummern für verschiedene Dinge:

| Präfix hier | Quelle | Inhalt |
|---|---|---|
| **R-001**, **R-002** | `docs/adr/001-initial-architecture.md`, `docs/adr/002-api-v1-boundary.md` | echte ADR-Dateien mit Kontext, Entscheidung, Konsequenzen |
| **K-001** … **K-009** | `knowledge/architecture/decisions.md` | nur eine Tabelle „ADR-001 … ADR-009“, **ohne** Kontext- und Alternativentext |
| **D-01** … | dieses Handbuch | aus dem Code abgeleitete Entscheidungen; Kontext und Alternativen sind Rückschlüsse |

!!! warning "Nummernkollision"
    `docs/adr/001-initial-architecture.md` (Repository-Struktur und Toolchain) und „ADR-001“ in `knowledge/architecture/decisions.md` (Flutter-Codebasis) sind verschiedene
    Entscheidungen mit derselben Nummer. Auch ADR-002 meint in den beiden Quellen etwas anderes (Fach-API-Vertrag bzw. Strapi + PostgreSQL). Dieses Handbuch
    verwendet deshalb die Präfixe R, K und D. Neue ADRs sollten eine fortlaufende Nummer in einem einzigen Ort bekommen
    (die Wissensbasis nennt dafür die Vorlage `knowledge/delivery/decision-template.md`).

Wo eine Quelle nichts über Alternativen sagt, steht hier „nicht dokumentiert“. Bei abgeleiteten Entscheidungen sind Alternativen als *naheliegende Alternativen*
gekennzeichnet; das sind Einschätzungen, keine überlieferten Abwägungen.

## Übersicht

| ID | Entscheidung | Quelle | Code heute |
|---|---|---|---|
| R-001 | Monorepo, Toolchain, Walking Skeleton, Fragen OQ-01 bis OQ-03 | `docs/adr/001-initial-architecture.md` | überwiegend umgesetzt; Lizenzpunkt widerspricht dem Projektstatus |
| R-002 | Fach-API unter `/api/v1` als stabiler Vertrag | `docs/adr/002-api-v1-boundary.md` | umgesetzt, App nutzt den generierten Client nicht |
| K-001 | Flutter-Codebasis, Clean Architecture, vertikale Features | `decisions.md` | umgesetzt (iOS nicht gebaut) |
| K-002 | Strapi CE + PostgreSQL | `decisions.md` | umgesetzt |
| K-003 | Keycloak als zentraler IdP und Broker | `decisions.md` | Keycloak ja, Broker/SAML/Social **nein** |
| K-004 | App spricht nur mit Fach-API | `decisions.md` | umgesetzt |
| K-005 | S3-Speicher und asynchrone Worker/Queue | `decisions.md` | Queue ja, S3 **nein** |
| K-006 | Offline idempotent; Releases atomar und versioniert | `decisions.md` | Idempotenz ja, Versionierung ja, atomare Aktivierung **nein** |
| K-007 | Isar mobil hinter Port, Web nach Spike | `decisions.md` | entschieden: `isar_plus` auch im Web |
| K-008 | Monorepo für Produktcode | `decisions.md` | umgesetzt |
| K-009 | `/api/v1`, idempotente Schreibvorgänge, serverautoritärer Fortschritt | `decisions.md` | = R-002 |
| D-01 | Strapi als Host mit eigener Fach-API statt Content-API | Code | umgesetzt |
| D-02 | Serverseitige Bewertung; Lösungen verlassen den Server nie | Code | umgesetzt |
| D-03 | Bestimmung als persistenter asynchroner Job (BullMQ) mit Provider-Guard | Code | umgesetzt; Retry-Pfad lückenhaft |
| D-04 | Idempotenz über gehashte Schlüssel, Client-IDs und Nutzlast-Digest | Code | umgesetzt |
| D-05 | Isar plus Sync-Queue für Offline-Schreiben | Code | teilweise (nur Herbarium) |
| D-06 | OpenAPI-Vertrag mit generiertem Client als Konsistenz-Gate | Code | Gate ja, Nutzung nein |
| D-07 | Unveränderliche Release-Pakete mit Prüfsumme | Code | nur Demo-Seed |
| D-08 | CPU-projizierte 3D-Meshes statt Engine | Code | umgesetzt |
| D-09 | Caddy als Edge mit automatischem TLS | Code | umgesetzt |
| D-10 | Ein Container pro Dienst, getrennte Netze, gehärtet | Code | umgesetzt |
| D-11 | Studio und Portal als Framework-lose statische Webanwendungen | Code | umgesetzt |
| D-12 | Server als Proxy für Kacheln und Fremdfotos | Code | umgesetzt |
| D-13 | Rollen nur über Client-Scope-Mappings im Token | Code | umgesetzt |
| D-14 | IPv4 zuerst | Code | umgesetzt |

## R-001: Initiale Architektur, Toolchain und Walking Skeleton

*Datum 2026-08-24, Status „Akzeptiert (Gate A)“.*

**Kontext.** Plantini wird als Multi-Agent-Projekt entwickelt. Es braucht eine feste Repository-Struktur, festgelegte Toolchain-Versionen und eine Klärung der offenen
Fragen OQ-01 bis OQ-03; Anforderungsbezug NFA001 bis NFA004, NFA027 (modular, dokumentiert, portabel).

**Entscheidung.** Monorepo mit `apps/flutter`, `services/platform`, `services/identity`, `contracts`, `infra`, `tools/e2e`, `content`, `docs/adr`; Apache-2.0 (NFA001);
entkoppeltes Backend, Auth, Frontend, Datenbank (NFA002); Artenanzahl 75 im Seed (OQ-01); Isar im Web testen, Rückfall IndexedDB/Drift-WASM (OQ-02); dünne
Strapi-Custom-Routes als Fach-API (OQ-03); Docker/Compose, Strapi CE, Keycloak, PostgreSQL, Flutter, Playwright.

**Folgen (laut ADR).** Toolchain steht, DevOps kann die Docker-Basis `M0-02` beginnen.

**Alternativen.** Nicht dokumentiert (außer dem Rückfall in OQ-02).

**Code-Befund.**

- Die Verzeichnisse existieren; dazu kamen `apps/editor`, `apps/teacher`, `apps/homepage`, `packages/api`, `operations`.
- Versionen sind festgelegt: Strapi 4.25.10, Node 20.20.2, Keycloak 24.0.4, Flutter 3.47.1.
- OQ-01: Der Seed enthält 30 Arten (3 Ökosysteme à 10), nicht 75.
- OQ-02: Isar läuft im Web; der Rückfall wurde nicht gebraucht (siehe K-007).
- OQ-03: dünne Custom-Routes – siehe D-01.
- **Lizenz:** Punkt 2 („Eigener Code wird unter Apache-2.0 veröffentlicht“) gilt nicht. Das Repository enthält zwar `LICENSE` und `NOTICE`, aber Plantini ist
  nicht Open Source; die Rechte liegen nicht beim Entwickler. Siehe [Projektstatus und Rechte](../start/status.md).

## R-002: Fach-API v1 als stabiler App-Vertrag

*Status „Akzeptiert für Slice A bis C am 2026-08-25“.*

**Kontext.** Strapi-Custom-Routen, generierter Dart-Client und Architekturdokumentation verwendeten widersprüchliche Pfade und Datenmodelle. Mock-Identitäten und lokal
simulierte Synchronisation konnten keinen sicheren oder wiederholbaren Kernpfad nachweisen.

**Entscheidung.**

- Die öffentliche Fach-API beginnt hinter dem Proxy mit `/api/v1`.
- `contracts/api.yaml` ist der kanonische Vertrag; Strapi bleibt zunächst die Host-Anwendung, Controller delegieren in testbare Dienste.
- Tokens werden vor jeder privaten Route validiert; der `sub`-Claim wird auf eine stabile interne Nutzer-ID abgebildet; fremde Ressourcen antworten wie nicht vorhanden.
- Offline-Schreibvorgänge tragen `Idempotency-Key` und stabile Client-ID; Fortschritt und Levelabschluss sind serverautoritativ.
- Identifikation ist ein persistenter asynchroner Job; der PlantNet-Mock ist nur ein Adapter hinter dem Jobvertrag.
- Alte `/api/*`-Mock-Routen sind keine Produktionsschnittstelle.

**Folgen (laut ADR).** Backend, Flutter und E2E migrieren gemeinsam auf v1; die generierte Dart-Bibliothek wird erst nach einem reproduzierbaren Codegen-Gate
aktualisiert, bis dahin kapselt die App HTTP-DTOs hinter Repository-Ports.

**Alternativen.** Nicht dokumentiert.

**Code-Befund.** Alle Punkte sind im Code nachweisbar (`services/platform/src/api/platform/routes/platform.js`, `jwt-validator.js`, `actor-service.js`, `ids.js`, `identification-queue.js`); Mock-Routen gibt es
nicht mehr. Der Zusatz zur Dart-Bibliothek gilt weiter: Die App nutzt die handgeschriebene `PlatformApiClient`-Schicht (siehe D-06). Die Teaching-Kommandos
(`/teaching/*`) sind nicht idempotent, was der Vertrag selbst vermerkt.

## Die ADR-Tabelle der Wissensbasis (K-001 bis K-009)

`knowledge/architecture/decisions.md` hält neun Entscheidungen als Tabelle fest. Kontext und Alternativen sind dort **nicht dokumentiert**; der Code-Befund ist hier ergänzt.

| ID | Entscheidung | Status laut Quelle | Code-Befund |
|---|---|---|---|
| K-001 | Flutter-Codebasis für Android, iOS und Web; Clean Architecture und vertikale Features | accepted | `apps/flutter/lib/features/*` mit den Schichten `domain`, `application`, `infrastructure`, `presentation` (nicht jedes Feature hat alle vier). Android, Web, Linux laufen; iOS wurde nicht gebaut (siehe [Projektstatus](../start/status.md)) |
| K-002 | Strapi CE + PostgreSQL für redaktionelle Inhalte und Admin | accepted | Strapi 4.25.10, PostgreSQL in Produktion. Entwicklungsvorgabe in `services/platform/config/database.js` ist SQLite (`DATABASE_CLIENT` Standard `sqlite`) |
| K-003 | Keycloak als zentraler IdP und Broker für OIDC/SAML/Social Login | accepted | Keycloak 24.0.4 als IdP. `identityProviders: []` – `validate-realm-security.mjs` verlangt das sogar; Social/SAML-Broker sind **nicht umgesetzt** |
| K-004 | App spricht über Fach-API; kein direkter Strapi-/PlantNet-Zugriff | accepted | umgesetzt, siehe [Überblick](index.md) |
| K-005 | S3-kompatibler Storage und asynchrone Worker/Queue | accepted | Queue: BullMQ auf Redis. **Kein S3:** `PrivateMediaStore` schreibt in ein Dateiverzeichnis auf einem Volume; die `S3_*`-Variablen im alten Dev-Compose liest kein Code |
| K-006 | Offline-Ereignisse idempotent; Content Releases atomar und versioniert | accepted | Idempotenz und Versionierung: ja. Atomare Aktivierung: nein (`retirePreviousReleases` ist nicht transaktional), und es gibt keinen Weg, ein Release aus Redaktionsänderungen zu erzeugen ([Datenflüsse](datenfluesse.md)) |
| K-007 | Isar Mobile hinter Port; Webadapter erst nach Spike | provisional | entschieden: `isar_plus` mit `IsarEngine.sqlite` und `isar_plus.wasm` aus der eigenen Origin (`apps/flutter/lib/core/storage/local_database.dart`) |
| K-008 | Monorepo für Produktcode; große offene Medien separat möglich | accepted | Monorepo; Medien (Fotos, 3D-Module) liegen im Repository |
| K-009 | Öffentlicher Fach-API-Vertrag unter `/api/v1`, idempotente Schreibvorgänge, serverautoritärer Fortschritt | accepted | = R-002 |

## Aus dem Code abgeleitete Entscheidungen

### D-01: Strapi als Host mit eigener Fach-API statt Content-API

**Kontext.** Redaktionelle Inhalte brauchen Entwurf/Veröffentlichung und ein Admin-UI; die App braucht dagegen einen stabilen Vertrag, Besitzprüfung und
serverseitige Regeln. Strapis generierte REST-API (`/api/ecosystems` usw.) liefert Datenbankmodelle samt Lösungsfeldern und kennt keine Besitzer.

**Entscheidung.** Strapi bleibt Host für Content-Types, Datenbank, Lifecycle-Hooks und Admin-UI. Die API der App ist **eine** Custom-Route-Datei
(`services/platform/src/api/platform/routes/platform.js`, alle `auth: false`), ein Controller (`services/platform/src/api/platform/controllers/platform.js`) und reine Services unter `services/platform/src/api/platform/services/core/`; Authentifizierung
macht `KeycloakJwtValidator`, nicht users-permissions. Die generierten Kernrouten bleiben bestehen, werden aber von Caddy nicht durchgereicht.

**Folgen.** Fachlogik ist ohne Strapi testbar (`node --test`, Fakes wie `services/platform/test/helpers/memory-entities.js`). `strapi-repositories.js` ist der einzige Ort mit Strapi-IDs.
Der Preis: Strapis Rechtemodell für die Kernrouten ist ungenutzt, und es gibt zwei „APIs“ im Prozess; wer neue Typen anlegt, bekommt automatisch eine Kernroute
(`createCoreRouter`), die nicht Teil des Vertrags ist.

**Alternativen (naheliegend).** Strapis Content-API mit users-permissions und Policies; ein eigener Node-Dienst neben Strapi (in `knowledge/architecture/backend-cms.md` als „schlanker TypeScript-Service“ erwogen, wenn
auch ohne Abwägung).

### D-02: Serverseitige Bewertung; Lösungen verlassen den Server nie

**Kontext.** Der Fortschritt schaltet Level und die Ökosystem-Trophäe frei; Clientergebnisse sind manipulierbar.

**Entscheidung.** `quiz.data.correctChoiceId` bleibt auf dem Server. `mapQuizItem` entfernt es, `LearningService.scoreAnswers` bewertet. Freischaltung (`requireLevelAccess`)
und Sammelregel (`requireCollectedPlants`, `getEcosystemProgress`) prüft der Server. Das steht auch in `AGENT.md` („Levelabschluss und PlantNet-Abgleich werden serverseitig validiert“).

**Folgen.** Ein Levelversuch braucht Netz für Start und Abschluss; Offline-Spiel ist nur für das Beantworten selbst möglich. Antworten müssen als `{quizItemId, choiceId}` an den Server.

**Alternativen (naheliegend).** Bewertung auf dem Gerät mit verschlüsselten Lösungen im Paket; verworfen wird das durch die Anforderung, Clientergebnisse nicht als autoritativ zu behandeln.

### D-03: Bestimmung als persistenter asynchroner Job mit Provider-Guard

**Kontext.** Pl@ntNet ist extern, langsam, mit Tageskontingent und kann ausfallen (HTTP 429/5xx).

**Entscheidung.** Die API legt in PostgreSQL einen `identification_job` an und antwortet sofort mit `202`. Ein BullMQ-Worker (Redis, Parallelität 2) ruft den Anbieter auf. Redis kann
unabhängig neu starten: Aufträge bleiben in PostgreSQL und werden alle 30 Sekunden wieder eingestellt. `RedisProviderGuard` schützt Kontingent und Anbieter mit Tageszähler,
Reserve und Circuit-Breaker.

**Folgen.** Die App pollt (`GET /identifications/{id}`), statt zu warten. Zustände und Fehlercodes sind Teil des Vertrags. Nach den Lesefunden gilt: Wiederholbare Fehler und
Abstürze im Zustand `processing` werden nicht automatisch wieder aufgenommen ([Datenflüsse](datenfluesse.md)).

**Alternativen (naheliegend).** Synchroner Aufruf im Request (R-002 legt stattdessen den „persistenten asynchronen Job“ fest); Queue ohne persistierte Aufträge.

### D-04: Idempotenz über gehashte Schlüssel, Client-IDs und Nutzlast-Digest

**Kontext.** Mobile Netze brechen ab; die App wiederholt Anfragen. Eine Wiederholung darf weder doppelte Funde noch doppelte Ereignisse erzeugen.

**Entscheidung.** Jede Schreiboperation kombiniert drei Dinge: (1) `Idempotency-Key` (oder Client-ID) wird zusammen mit Besitzer und Operation zu einem SHA-256 gehasht
(`scopedIdempotencyKey`), (2) die Client-ID ist pro Besitzer eindeutig (`ownerClientKey`), (3) der `requestDigest` über die kanonisch sortierte Nutzlast erkennt widersprüchliche Wiederholungen.

**Folgen.** Zwei Konten können dieselbe Client-ID nutzen, ohne zu kollidieren; fremde Schlüssel sind nicht rückrechenbar. Jede neue Schreiboperation braucht drei Spalten
(siehe [Datenmodell](datenmodell.md)) und einen Schema-Test.

**Alternativen (naheliegend).** Nur den Header speichern (Kollision über Konten hinweg); serverseitig erzeugte IDs ohne Client-ID (nicht offline-fähig).

### D-05: Isar plus Sync-Queue für Offline-Schreiben

**Kontext.** Funde entstehen draußen ohne Netz; ein Verlust beim Beenden der App wäre inakzeptabel.

**Entscheidung.** Lokaler Zustand wird zuerst geschrieben, dann ein Queue-Auftrag (`SyncQueueService`, Exponential-Backoff, `maxAttempts: 5`) mit stabiler Client-ID.
Die Queue-Speicher-Schnittstelle (`SyncQueueStore`) hat eine Isar- und eine In-Memory-Implementierung. Isar ist `isar_plus` (nativ: `IsarEngine.isar`, Web: `IsarEngine.sqlite` mit
`isar_plus.wasm` aus der eigenen Origin).

**Folgen und Grenzen.** Die Queue transportiert nur Herbarium-Beobachtungen; Beobachtungsdaten selbst liegen in `SharedPreferences`, Lernsitzungen ebenso. Foto-Upload und Bestimmung
sind online-only. Der Endpunkt `/sync` und `/content/changes` werden nicht genutzt. Abmelden leert die lokalen Daten nicht ([Sicherheit](sicherheit-datenschutz.md)).

**Alternativen (naheliegend).** IndexedDB/Drift-WASM im Web (in R-001 als Rückfall genannt); Hive; vollständige Offline-Datenbank mit Server-Sync (`/sync`, im Vertrag vorhanden, ungenutzt).

### D-06: OpenAPI-Vertrag mit generiertem Client als Konsistenz-Gate

**Kontext.** Vertrag, Server und Client sollen nicht auseinanderlaufen (R-002).

**Entscheidung.** `contracts/api.yaml` ist die Quelle. `tools/scripts/generate-api-client.sh` erzeugt per `openapi-generator-cli` (festgepinnte Image-Version mit Digest, Generator
`dart-dio`, `built_value`) das Paket `packages/api` (Paketname `openapi`). `tools/scripts/validate-api-contract.mjs` prüft: jede als `implemented` markierte Operation hat eine Server-Route und einen
Handler, jede Route ist dokumentiert (außer `GET /health`), `planned`-Operationen haben noch keine Route, und die Digests von Spec und generiertem Baum stimmen. CI läuft `git diff --exit-code -- packages/api`.

**Befund.** Die App importiert das Paket **nirgends** (`grep package:openapi` über `apps/flutter/lib`, `test`, `integration_test` ohne Treffer), obwohl es in `pubspec.yaml` als Abhängigkeit steht.
Stattdessen sprechen `PlatformApiClient` (Dio) und handgeschriebene DTO-Mapper mit der API; ihr Kommentar nennt den Grund: Die Mapper sollen einen unvollständigen Vertrag
„precisely“ melden. Der Nutzen der Generierung liegt damit im Gate (Vertrag ↔ Server), nicht in der App.

**Folgen.** Eine Vertragsänderung braucht Neugenerierung, aber auch Anpassung der Mapper von Hand. Der generierte Client ist ein ungenutzter, aber CI-geprüfter Artefakt-Baum.

**Alternativen (naheliegend).** Generierten Client direkt verwenden; Vertrag aus dem Server ableiten (Code-first).

### D-07: Unveränderliche Release-Pakete mit Prüfsumme

**Kontext.** Lerninhalte müssen offline und versioniert verteilt werden; die App soll ein Release erst aktivieren, wenn es vollständig und unverändert ist.

**Entscheidung.** Pro Release drei JSON-Pakete (`ecosystems`, `levels`, `plants`) mit SHA-256 und Größe in einem Manifest; die Bytes liegen Base64-kodiert in `content_releases.package_blobs`,
damit JSONB-Umsortierung die Prüfsumme nicht verändert. Der Server prüft beim Ausliefern erneut; die App prüft vor dem Schreiben und ersetzt ihren lokalen Bestand in **einer** Transaktion.

**Folgen und Grenzen.** Nur der Demo-Seed erzeugt Releases; ein redaktioneller Veröffentlichungsweg fehlt, eine Signatur ebenfalls. Weil `publicId` und `slug` in Strapi global eindeutig sind, können keine zwei
Versionen derselben Entität parallel existieren; der Seed überschreibt bekannte IDs in place ([Datenflüsse](datenfluesse.md)).

**Alternativen (naheliegend).** Delta-Sync über `/content/changes` (serverseitig vorhanden, ungenutzt); Releases als eigene Tabellen-Schnappschüsse; signierte Manifeste.

### D-08: CPU-projizierte 3D-Meshes statt Engine

**Kontext.** Die Lernwelt (Wald, Wiese, Alpen) soll dreidimensional wirken, auf Web, Android und Linux laufen und ohne zusätzliche Laufzeit-Abhängigkeit auskommen.

**Entscheidung.** Statt Flutter-3D-Engine, `three_js` oder GLB-Player werden Blender-Szenen in kompakte Mesh-Module exportiert (`tools/blender/export_forest_module.py`,
`create_ecosystem_modules.py`): JSON mit `meshes` (Vertices, Faces, Farbe, Bewegungsart), `slots` (sechs Level-Positionen je Modul), `lights`. Die App projiziert die Dreiecke selbst
(`SceneBuilder.build` in `world_scene.dart`): eine schiefe Parallelprojektion je Vertex, ein Tiefenschlüssel je Dreieck, ein numerisches Sortieren (Maler-Algorithmus) und Flächenbeleuchtung,
dann `ui.Vertices.raw` und `canvas.drawVertices`. Es werden höchstens das aktuelle Modul und seine Nachbarn aufgebaut (`modular_forest_view.dart`), Bilder je Animationsphase werden als
`ui.Picture` zwischengespeichert.

**Folgen.** Läuft überall, wo Flutter-Canvas läuft; die Assets sind klein (`forest_module.json` mit 264 Meshes). Kein GPU-Z-Buffer, keine Echtzeitschatten; die Optik bleibt einfacher
als das Blender-Referenzbild (so im Handover `knowledge/handovers/index-card-and-3d-world.md`). Die Leistung auf echten Mobilgeräten ist dort als offen vermerkt.
Mehr: [3D und Blender](../3d/index.md).

**Alternativen (naheliegend).** GLB-Player oder Engine (Flame, three_js, Filament); vorgerenderte Bilder oder Videos (nur zwei Dimensionen, keine Bewegung/Tageszeit).

### D-09: Caddy als Edge mit automatischem TLS

**Kontext.** Ein einzelner Server soll mehrere Hosts bedienen, mit Zertifikaten ohne Handarbeit, und nur ausgewählte Pfade nach außen geben.

**Entscheidung.** Caddy (`infra/production/compose.proxy.yaml`, Image `caddy:2.8.4-alpine`) im Host-Netzwerk, ACME HTTP-01 für alle Hosts, ein eigenes Compose-Projekt, damit der Proxy unabhängig vom
Stack neu gestartet werden kann. Pro Host stehen nur die erlaubten Pfade im `Caddyfile`; Keycloak und API sind per Pfadliste beschnitten.

**Folgen.** Die Dienste binden ausschließlich an `127.0.0.1`. Die Web-App-Dateien kommen als Verzeichnis (`WEB_ROOT`) in den Proxy-Container, nicht über ein Image. Ports von API und Keycloak
sind im `Caddyfile` fest verdrahtet. Das Caddyfile muss laut Runbook beim Austausch **in place** überschrieben werden, weil der Container sonst den alten Inode hält.

**Alternativen (naheliegend).** nginx mit certbot, Traefik. Die Begründung für Caddy ist im Repository nicht dokumentiert.

### D-10: Ein Container pro Dienst, getrennte Netze, gehärtet

**Kontext.** Dienste unterschiedlicher Vertrauensstufen (Datenbanken, Identität, Plattform, statische Webseiten) sollen sich gegenseitig nur das Nötigste sehen.

**Entscheidung.** `infra/compose.production.yaml` startet je Dienst einen Container; alle mit `no-new-privileges`. Statische Webcontainer sind zusätzlich `read_only` mit `tmpfs` und
`cap_drop: [ALL]`. Die Plattform läuft nicht als root (`USER plantini`, UID 10001). Netze: `edge`, `app` und `data` (beide `internal`), `provider`. Images werden als unveränderliche Referenzen erwartet
(„Deploy only immutable image references“), nichts wird aus dem Quelltext gebaut (`${…_IMAGE:?…}`).

**Folgen.** Klare Grenzen (siehe [Überblick](index.md)), aber mehr Betriebsaufwand: Jede Änderung braucht ein neues Image oder ein „Release-Overlay“ (`Dockerfile.release-overlay`).
Alle Daten liegen in benannten Volumes; Backups müssen Datenbanken und `private-media` getrennt sichern (`infra/production/backup.sh`).

**Alternativen (naheliegend).** Ein Prozess mit eingebetteter SQLite; Kubernetes (für einen einzelnen Host überdimensioniert).

### D-11: Studio und Portal als Framework-lose statische Webanwendungen

**Kontext.** Redaktion und Lehre sollen auf getrennten Hosts mit eigenen Rollen und kleiner Angriffsfläche arbeiten.

**Entscheidung.** `apps/editor` und `apps/teacher` bestehen aus HTML, CSS und JavaScript ohne Build-Schritt und Framework; nginx liefert sie mit strenger CSP (`script-src 'self'`). Beide führen den OIDC-Code-Flow mit
PKCE selbst aus und halten Tokens nur im Speicher. Eigene Keycloak-Clients (`plantini-editor-*`, `plantini-teacher-*`) mit Rollen-Scope-Mappings (D-13).

**Folgen.** Keine Abhängigkeitskette im Browser, kleine Images; dafür von Hand gepflegter Code für Escaping, Zustände und OIDC. Details: [Studio-Technik](../studio/studio-technik.md), [Portal-Technik](../studio/portal-technik.md).

**Alternativen (naheliegend).** Das Strapi-Admin-UI für die Redaktion (existiert, wird nicht öffentlich ausgeliefert); ein SPA-Framework.

### D-12: Server als Proxy für Kacheln und Fremdfotos

**Kontext.** Direkte Anfragen der App an Kachelserver oder Bildquellen würden IP-Adresse und angesehene Orte preisgeben (Kommentar in `tile-proxy.js`).

**Entscheidung.** Die Plattform holt Kacheln (OpenStreetMap) und Fremdfotos (Wikimedia/iNaturalist, nur optional) selbst, mit Host-Allowlist, ohne Weiterleitungen, mit Größen-, Zeit- und
Parallelitätslimits, und cached sie auf dem Volume. Die App sieht nur die Plattform.

**Folgen.** Die Plattform trägt die Last und die Nutzungsbedingungen der Quellen (User-Agent, Cache-Dauer). Kacheln und Fotos teilen sich das Volume mit privaten Fotos. Siehe [Datenflüsse](datenfluesse.md).

**Alternativen (naheliegend).** Direkte Kachel-Anfragen aus der App; eigener Kachelserver.

### D-13: Rollen nur über Client-Scope-Mappings im Token

**Kontext.** Redaktions- und Lehrrollen sollen nicht in Tokens der Lern-App auftauchen.

**Entscheidung.** Alle App-Clients haben `fullScopeAllowed: false`. Die Rollen `inhaltsredaktion`, `botanisches_review`, `systemadministration` bzw. `lehrende`, `systemadministration` sind nur für die Editor-
und Portal-Clients per `scopeMappings` sichtbar. Die API liest `realm_access.roles` und kennt nur eine feste Rollenliste.

**Folgen.** Ein Konto mit Redaktionsrolle muss sich zum Redigieren am Studio anmelden. Neue Rollen brauchen einen Realm-Eintrag, ein Scope-Mapping **und** einen Eintrag in `ALLOWED_ROLES`
(wie `forschende` zeigt: im Realm vorhanden, in der API ignoriert).

**Alternativen (naheliegend).** Rollen in allen Tokens und API-seitige Client-Prüfung (`azp`); Gruppen statt Rollen.

### D-14: IPv4 zuerst

**Kontext.** In den Betriebs- und Testumgebungen ist IPv6 nicht verlässlich (Kommentar in `plantnet-provider.js`: „The deployed environments have no usable IPv6 route“).

**Entscheidung.** Konsequent IPv4: `NODE_OPTIONS=--dns-result-order=ipv4first` in der Produktions-Compose, `dns.setDefaultResultOrder('ipv4first')` im PlantNet-Adapter, `family: 4` bei Kachel- und Foto-Downloads,
`127.0.0.1` statt `localhost` in E2E und Entwicklung, und `AppConfig` lehnt IPv6-Literale für API und Issuer ab.

**Folgen.** Stabile Tests und Verbindungen, aber IPv6-only-Umgebungen sind nicht unterstützt. Die genaue Ursache der IPv6-Probleme ist im Repository nicht belegt.

**Alternativen (naheliegend).** Dual-Stack mit Happy Eyeballs; IPv6-Fehler beheben.

## Wie neue Entscheidungen festgehalten werden

`knowledge/architecture/decisions.md` beschreibt das Verfahren: Eine ADR enthält Kontext, Optionen, Entscheidung, Konsequenzen, Sicherheits- und Datenschutzwirkung, Migrations- und
Rollbackweg, betroffene Anforderungen und beteiligte Rollen; eine bereits akzeptierte ADR darf nicht stillschweigend gebrochen werden. Ob dieses Verfahren bei Mitarbeit nach Absprache
fortgeführt wird, klärst du mit dem Projektkontakt (siehe [Projektstatus](../start/status.md)).

## Weiterführend

- [Architektur im Überblick](index.md) · [Datenflüsse](datenfluesse.md) · [Datenmodell](datenmodell.md) · [Sicherheit und Datenschutz](sicherheit-datenschutz.md)
- [Offline und Sync](../app/offline.md) · [API-Vertrag](../backend/api-vertrag.md) · [3D und Blender](../3d/index.md) · [Compose](../betrieb/compose.md)
- Quellen: `docs/adr/001-initial-architecture.md`, `docs/adr/002-api-v1-boundary.md`, `knowledge/architecture/decisions.md`, `knowledge/architecture/backend-cms.md`,
  `tools/scripts/validate-api-contract.mjs`, `tools/scripts/generate-api-client.sh`, `apps/flutter/lib/features/catalog/presentation/widgets/world_scene.dart`,
  `infra/compose.production.yaml`, `infra/production/Caddyfile`
