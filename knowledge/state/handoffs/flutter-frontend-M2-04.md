# Handoff: M2-04 Flutter: Offline Queue & Herbarium UI

- **Von / an Rolle:** flutter-frontend / qa-playwright
- **Ergebnis:** API-Client neu generiert (nun mit `/observations`). `OfflineQueueService` mit Isar (`OfflineObservation`) implementiert, puffert Bilder und Metadaten offline. `HerbariumScreen` implementiert (Listenansicht, Suche, Organ-Filter, Notizen bearbeiten, Löschen). Bestimmungen landen nach Fotoaufnahme in der Queue/im Herbarium.
- **Requirement(s):** FA036, FA037, FA043
- **Geänderte Pfade:** `apps/flutter/lib/**`, `packages/api/**`
- **Bekannte Risiken/Blocker:** Keine. 
- **Nächster konkreter Schritt:** QA Playwright (M2-06) testet Konflikte (zwei Geräte, Offline-Sync) und den gesamten PlantNet Upload-Flow.
