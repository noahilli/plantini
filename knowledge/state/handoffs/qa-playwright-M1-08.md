# Handoff: M1-08 QA Learning Flow E2E

- **Von / an Rolle:** qa-playwright / orchestrator
- **Ergebnis:** E2E-Test `tools/e2e/qa/learning-flow.spec.ts` geschrieben. Deckt den Pfad ab: Keycloak-Login (`lernende`) -> Pflanzenprofil -> Lerneinheit (Quiz) -> Browser Reload -> Pause/Resume Status prüfen.
- **Requirement(s):** FA020, FA024, FA028
- **Geänderte Pfade:** `tools/e2e/qa/learning-flow.spec.ts`
- **Bekannte Risiken/Blocker:** Die UI-Selektoren in Playwright ("Quiz starten") könnten sich ändern, wenn Flutter die Semantics überarbeitet. Die CI-Pipeline führt den Test noch nicht dauerhaft aus, bis die Pipeline-Integration in Phase F erfolgt.
- **Nächster konkreter Schritt:** Phase C ist abgeschlossen. Wir können zu Phase D (Expedition und Herbarium) oder Phase E (Administration fertigstellen) übergehen.
