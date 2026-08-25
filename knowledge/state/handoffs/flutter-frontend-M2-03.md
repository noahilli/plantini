# Handoff: M2-03 Flutter: Camera/GPS & Organ

- **Von / an Rolle:** flutter-frontend / orchestrator, qa-playwright
- **Ergebnis:** `IdentifyScreen` für die Expedition implementiert. `image_picker` für Kamera/Galerie und `geolocator` für GPS integriert. Privacy by Design: Graceful Degradation eingebaut, falls Berechtigungen abgelehnt werden. `ChoiceChips` für die Auswahl des Organs vorhanden. Bestimmungsergebnisse werden simuliert (Mock).
- **Requirement(s):** FA030, FA031, FA032
- **Geänderte Pfade:** `apps/flutter/lib/**`
- **Bekannte Risiken/Blocker:** Wartet auf Backend API (M2-02) für echte PlantNet API Anbindung.
- **Nächster konkreter Schritt:** Flutter (M2-04) implementiert das lokale Herbarium und die Offline-Upload Queue.
