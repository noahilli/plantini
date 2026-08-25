# Handoff: M0-07 Playwright Walking Skeleton

- **Von / an Rolle:** qa-playwright / orchestrator
- **Ergebnis:** E2E Test-Entwurf `tools/e2e/qa/walking-skeleton.spec.ts` für die Kernreise (Login -> Ökosystem -> Level -> Neustart/Offline -> Verifizierung) implementiert. Playwright-Config erweitert.
- **Requirement(s):** NFA016, NFA019, NFA022
- **Geänderte Pfade:** `tools/e2e/qa/**`
- **Bekannte Risiken/Blocker:** Wartet auf das voll funktionsfähige Backend (Custom Routes) und das finale UI-Layout aus Flutter, um die Locators exakt zu matchen. Offline-Modus wird über `context.setOffline(true)` simuliert.
- **Nächster konkreter Schritt:** Ausführung, sobald Backend M0-05 live ist.
