# Handoff: M1-03 API Contract & Routes (Plants, Quizzes & Media)

- **Von / an Rolle:** backend-api / flutter-frontend, qa-playwright
- **Ergebnis:** `contracts/api.yaml` um `/plants`, `/quizzes`, `/media` erweitert. Strapi Custom Controllers implementiert, die das standardmäßige `{ data: [] }` Format von Strapi umgehen und saubere OpenAPI-Arrays/Objekte liefern.
- **Requirement(s):** FA013, FA021, FA022, FA023, FA015
- **Geänderte Pfade:** `contracts/api.yaml`, `services/platform/src/api/**`
- **Security/Privacy/Auswirkung:** Die Content-Read-Endpunkte sind public (`auth: false`), sodass die App sie ohne Keycloak-Token für den Offline-Sync ziehen kann.
- **Bekannte Risiken/Blocker:** Keine. API liefert `[]`, da die DB noch leer ist.
- **Nächster konkreter Schritt:** Flutter (M1-06) regeneriert den Client. QA (M1-08) füllt Testdaten in Strapi ab und testet den Flow.
