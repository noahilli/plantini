# Handoff: M1-06 Flutter Progress & Resume

- **Von / an Rolle:** flutter-frontend / qa-playwright
- **Ergebnis:** API-Client neu generiert (nun mit `/plants`, `/quizzes`, `/media`). UI-Mocks durch echte API-Aufrufe ersetzt. `ProgressService` implementiert lokale Persistenz über Isar (Pause/Resume, bestandene Quizzes, Levelabschluss) über Collections `QuizProgress` und `LevelProgress`.
- **Requirement(s):** FA028, FA029
- **Geänderte Pfade:** `apps/flutter/lib/**`, `packages/api/**`
- **Bekannte Risiken/Blocker:** Keine kritischen Blocker. Die echte Datensynchronisation (Delta-Sync) ans Backend zum Abgleich mehrerer Geräte fehlt noch (kommt in späteren Phasen).
- **Nächster konkreter Schritt:** QA Playwright (M1-08) kann den gesamten Lernpfad (Login -> Navigation -> Level -> Quiz Pause/Resume) durchspielen.
