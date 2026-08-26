# Testdaten und Testkonten (E2E & Entwicklung)

Dieses Dokument spezifiziert die standardisierten Testkonten, Rollen und den synthetischen Referenzdatensatz für lokale Entwicklungs- und E2E-Testumgebungen.

---

## 1. E2E-Testkonten

Für automatisierte und manuelle Tests stehen folgende Standardkonten im Keycloak-Realm `plantini` zur Verfügung:

| E-Mail-Adresse | Rolle / Berechtigung | Verwendungszweck |
|---|---|---|
| `e2e-learner@plantini.test` | Lernende | App-Login, Lernpfade, Quizzes, Herbarium, Offline-Sync |
| `e2e-teacher@plantini.test` | Lehrende | Schul-/Klassenübersichten, Level-Zuweisung |
| `e2e-editor@plantini.test` | Redaktion (Inhaltsredaktion) | CMS-Inhaltspflege, Entwurfserstellung, Taxonomie |

### Standardpasswort
- **Passwort (für alle Testkonten):** `Test1234!`
- *Hinweis:* Dieses Passwort gilt ausschließlich für lokale Entwicklungs- und CI/E2E-Testumgebungen und darf niemals in produktiven Umgebungen verwendet werden.

---

## 2. Synthetischer Referenzdatensatz

Für konsistente Testläufe wird ein minimaler, deterministischer Referenzdatensatz bereitgestellt:

- **Ökosysteme (3):**
  1. *Wald* (z. B. Mitteleuropäischer Laubwald)
  2. *Wiese* (z. B. Fettwiese / Blumenwiese)
  3. *Gewässer* (z. B. Uferzone / Stillgewässer)
- **Levels:** Je Ökosystem mindestens 1 Demo-Level (Level 1 für Einsteiger).
- **Arten/Pflanzen:** Je Ökosystem mindestens 2 Beispielpflanzen mit vollständigen Profilen (Habitus, Merkmale, Quizfragen).

---

## 3. Seed-Dateien & Provisionierung

- **Inhalts-Seeds:**
  - Datei: `content/seeds/01-ecosystems-levels.json`
  - Enthält die strukturierte Definition von Ökosystemen, Demo-Levels und zugeordneten Beispielarten für den Strapi-/API-Import.
- **Keycloak-Bootstrap:**
  - Script: `infra/scripts/keycloak-bootstrap-e2e.sh`
  - Automatisiertes Anlegen und Konfigurieren der E2E-Testbenutzer im Keycloak-Container.

---

## 4. Status und Nachweisgrenze

- Die Spezifikation dieser Daten ist in `STATUS_REGISTRY.csv` unter `STATUS-06` und im Blocker `B-TESTDATA-01` hinterlegt.
- Die tatsächliche Bereitstellung auf einer laufenden Instanz muss im Rahmen der jeweiligen Testausführung separat nachgewiesen werden (siehe `knowledge/state/EVIDENCE.md` -> `E-STATUS-06`).
