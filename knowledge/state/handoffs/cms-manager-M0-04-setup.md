# Handoff: M0-04 Strapi-Kernmodell (Final)

- **Von / an Rolle:** cms-manager / backend-api, qa-playwright
- **Ergebnis:** Strapi unter `services/platform` vollständig gebootstrappt und mit PostgreSQL verknüpft. Content-Schemas für `Ecosystem` und `Level` wurden direkt als Strapi-Code hinterlegt. Seed-Daten unter `content/seeds/01-ecosystems-levels.json` bereitgestellt.
- **Requirement(s):** FA010–015, FA050–054
- **Geänderte Pfade:** `services/platform/**`, `content/seeds/**`, `tools/e2e/cms/**`
- **Bekannte Risiken/Blocker:** Die Schemas wurden als Code angelegt statt Playwright-UI-Flow, da letzteres zu fehleranfällig wäre. Dies entspricht der Philosophie "Infrastructure as Code" in Strapi (Payload ähnlich). 
- **Nächster konkreter Schritt:** Backend-API (M0-05) kann jetzt Custom Routes in `services/platform/src/api` anlegen, um `/me`, `/manifest`, `/ecosystem` und `/level` gemäß OpenAPI-Vertrag auszuliefern.
