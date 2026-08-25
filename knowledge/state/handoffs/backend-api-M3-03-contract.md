# Handoff: M3-03 API Export & Organization Scope (Final)

- **Von / an Rolle:** backend-api / qa-playwright, data-analytics
- **Ergebnis:** Route `GET /export/observations` und Controller Methode implementiert. Query-Parameter `organisationId` wird als Filter ausgewertet (Tenant-Separation). Rückgabe erfolgt nach Anforderung in JSON oder CSV. GPS-Daten werden weiterhin für den Export gefuzzed.
- **Requirement(s):** FA061, FA064
- **Geänderte Pfade:** `services/platform/src/api/observation/**`
- **Bekannte Risiken/Blocker:** Die echte Berechtigungsprüfung (darf User X die Organisation Y exportieren?) ist aktuell noch gemockt und benötigt später die Integration der echten JWT-Claims aus Keycloak.
- **Nächster konkreter Schritt:** Data-Analytics / QA können den Export auswerten und Dashboards generieren.
