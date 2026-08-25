# Handoff: M1-07 Auth Roles & Admin Access

- **Von / an Rolle:** auth-manager / backend-api, qa-playwright
- **Ergebnis:** Administrative Keycloak-Rollen (`lernende`, `lehrende`, `inhaltsredaktion`, `botanisches_review`, `organisationsadministration`, `systemadministration`) wurden im Realm angelegt. Standardrolle `lernende` gesetzt. SMTP-Verbindung zu `mailpit` konfiguriert für Einladungen.
- **Requirement(s):** FA006, FA007
- **Geänderte Pfade:** `services/identity/realm/plantini-realm.json`, `tools/e2e/auth/**`
- **Bekannte Risiken/Blocker:** SMTP Mock-Server läuft, echte E-Mail-Konfiguration muss vor Beta erfolgen (OQ-08).
- **Nächster konkreter Schritt:** Backend-API (M1-03) kann die Rollen nun verwenden, um API-Routen granular zu schützen. QA Playwright kann rollenspezifische E2E Tests bauen.
