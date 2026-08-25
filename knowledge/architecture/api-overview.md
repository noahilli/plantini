# API-Übersicht

Basis ist `/api/v1`. Schreibende Offline-Aufrufe tragen `Idempotency-Key` oder stabile Client-ID. Fehler verwenden ein RFC-7807-artiges Problem-JSON mit stabilem Code, nutzergeeigneter Nachricht, Trace-ID und Feldfehlern.

## App und Synchronisation

| Methode | Pfad | Zweck |
|---|---|---|
| GET/PATCH | `/me` | Profil, Organisation, Locale, Rollen, Einwilligung; änderbare Fachfelder |
| GET | `/content/manifest` | Version, Pakete, Hashes, Größen, Mindest-App-Version, Rückzüge |
| GET | `/content/changes?since=` | Delta und Löschmarken ab Cursor |
| GET | `/ecosystems` | veröffentlichte Ökosysteme und Paketstatus |
| GET | `/ecosystems/{id}` | Detail und Levelreferenzen |
| GET | `/levels/{id}` | Struktur, Voraussetzungen, Blöcke, Quizmix, Abschlussregel |
| GET | `/plants/{id}` | lokalisierter Steckbrief, Medien, Warnungen, Quellen |
| GET | `/quiz-items?levelId=` | Fragen oder signiertes Offline-Paket |
| POST | `/learning-events:batch` | idempotenter Eventbatch |
| GET | `/progress` | autoritativer Stand, optional seit Cursor/je Level |
| POST | `/level-attempts` | Start/Resume und Attempt-ID |
| POST | `/level-attempts/{id}:complete` | servervalidierter Abschluss |
| GET | `/achievements` | erreichte und nächste Erfolge |
| POST | `/sync` | optional kombinierter kleiner Sync |

## Feld, Identifikation und Herbarium

| Methode | Pfad | Zweck |
|---|---|---|
| POST | `/media/uploads` | privaten Upload initialisieren/validieren |
| POST | `/identifications` | Auftrag erzeugen; `202` + Job-ID |
| GET | `/identifications/{jobId}` | Status, Kandidaten, Score, Modell/Quote, Zielabgleich |
| POST | `/identifications/{jobId}:retry` | kontrollierter Retry |
| GET/POST | `/observations` | eigene Liste bzw. idempotent anlegen |
| GET/PATCH/DELETE | `/observations/{id}` | eigenes Detail, versionsgesichert ändern, löschen |
| POST | `/observations/{id}:export` | Einzelfundexport, GPS standardmäßig vergröbert |

## Administration, Datenschutz und Forschung

| Methode | Pfad | Zweck |
|---|---|---|
| POST | `/admin/content-releases` | validiertes Manifest erzeugen |
| POST | `/admin/imports` | Dry-run/Import für Pflanzen, Quiz, Übersetzungen |
| GET | `/admin/dashboard` | aggregierte Nutzungs-/Qualitätsmetriken |
| GET | `/admin/users` | berechtigte Suche ohne Passwörter |
| POST | `/admin/users/{id}:suspend` | Konto sperren und Sitzungen widerrufen |
| POST | `/privacy/exports` | Gesamtdatenkopie anfordern |
| POST | `/privacy/deletions` | Kontolöschung anfordern/statusieren |
| GET | `/research/exports/{id}` | genehmigten pseudonymisierten Export laden |

Der erste OpenAPI-Seed liegt in `contracts/openapi-seed.yaml`. Er ist ein Startvertrag, kein Ersatz für fachlich geprüfte Schemas und Fehlerfälle.
