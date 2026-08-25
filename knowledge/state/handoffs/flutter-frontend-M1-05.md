# Handoff: M1-05 Flutter: Quiz UI & Learning Flow

- **Von / an Rolle:** flutter-frontend / backend-api, qa-playwright
- **Ergebnis:** UI für `LearningFlowScreen` (geführte Einheiten) und `QuizScreen` (Multiple-Choice, Bilderkennung, Artennamen-Texteingabe) implementiert. Unmittelbares visuelles Feedback (richtig/falsch) mit barrierefreien Farben integriert. Button "Lerneinheit Starten" in Pflanzen-Profilen verknüpft.
- **Requirement(s):** FA020, FA021, FA022, FA023, FA024
- **Geänderte Pfade:** `apps/flutter/lib/**`
- **Bekannte Risiken/Blocker:** Vollständig auf Mock-Daten basierend. Wartet auf Backend-API (M1-03) für echte Fragen und Lösungsüberprüfung. Logik zur serverseitigen Bewertung (FA024) fehlt im Client naturgemäß.
- **Nächster konkreter Schritt:** Frontend (M1-06) baut Fortschritt (Progress & Resume) auf dieser UI auf. Backend muss die M1-03 API liefern, damit QA die E2E Tests (M1-08) auf echten Quizfragen schreiben kann.
