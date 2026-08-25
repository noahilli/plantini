# Handoff: M1-02 Strapi Models (Plants, Quiz, Media)

- **Von / an Rolle:** cms-manager / backend-api, qa-playwright
- **Ergebnis:** Contentmodelle **Plant**, **Quiz** und **Media** als direkte Schema-Dateien (`services/platform/src/api/`) angelegt. **Level** Modell mit Relationen aktualisiert. Strapi-Container neu gestartet, Modelle erfolgreich geladen.
- **Requirement(s):** FA050, FA051
- **Geänderte Pfade:** `services/platform/src/api/**`
- **Bekannte Risiken/Blocker:** Keine. 
- **Nächster konkreter Schritt:** Backend-API (M1-03) kann nun Custom Routes oder Controller-Overrides bauen, um diese Daten OpenAPI-konform (`contracts/api.yaml`) bereitzustellen. QA Playwright (M1-08) kann Testdaten gegen diese Modelle erzeugen.
