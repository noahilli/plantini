# Handoff: M1-04 Flutter: Ecosystem Nav & Plant Profiles

- **Von / an Rolle:** flutter-frontend / backend-api, qa-playwright
- **Ergebnis:** Flutter Screens für Ökosystem-Liste, Level-Auswahl und Pflanzensteckbriefe wurden unter `apps/flutter/lib/features/` implementiert. Das Design System (M1-01) wird konsequent angewendet.
- **Requirement(s):** FA011, FA012, FA013, FA015
- **Geänderte Pfade:** `apps/flutter/lib/**`
- **Bekannte Risiken/Blocker:** Die Screens nutzen aktuell statische Mocks für die Anzeige, da das Backend (M1-03) noch in der Entwicklung ist. Echte Daten-Integration steht aus.
- **Nächster konkreter Schritt:** Sobald M1-03 (Backend API) abgeschlossen ist, muss Flutter die Mocks durch echte API-Aufrufe (`packages/api`) ersetzen.
