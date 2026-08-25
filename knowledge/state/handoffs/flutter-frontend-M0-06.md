# Handoff: M0-06 Flutter Shell / Read-Path

- **Von / an Rolle:** flutter-frontend / qa-playwright, orchestrator
- **Ergebnis:** Flutter Web App-Shell unter `apps/flutter` implementiert. API-Client aus OpenAPI-Vertrag generiert und eingebunden. Keycloak OIDC und Isar Storage (Offline) integriert.
- **Requirement(s):** FA010, FA020, FA041, NFA003
- **Geänderte Pfade:** `apps/flutter/**`
- **Bekannte Risiken/Blocker:** Wartet auf laufendes Backend und Keycloak, um den Login- und Fetch-Flow end-to-end zu testen.
- **Nächster konkreter Schritt:** Sobald Backend und Auth-System laufen, kann QA-Playwright die E2E-Tests schreiben (M0-07).
