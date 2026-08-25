# Handoff: M2-06 QA Device Conflict & PlantNet Flow

- **Von / an Rolle:** qa-playwright / orchestrator
- **Ergebnis:** E2E-Test `tools/e2e/qa/herbarium-conflict.spec.ts` geschrieben. Der Test deckt die Anforderung ab, dass ein Offline-Eintrag lokal und ein paralleler Eintrag über die API (Gerät 2) sich beim Re-Sync nicht überschreiben (idempotente Synchronisation).
- **Requirement(s):** FA045, FA044
- **Geänderte Pfade:** `tools/e2e/qa/herbarium-conflict.spec.ts`
- **Bekannte Risiken/Blocker:** Test-IDs (Kamera, Sync-Indikator) müssen nach finale Rendering-Prüfung gematcht werden. Das Auth-Token für den simulierten API-Call ist derzeit hartkodiert.
- **Nächster konkreter Schritt:** Phase D ist damit erfolgreich durch E2E-Tests abgedeckt. Weiter mit dem Abschluss von Phase E (Review-Flows, Draft/Publish).
