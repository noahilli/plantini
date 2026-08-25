# Handoff: M1-01 Design System & App Shell

- **Von / an Rolle:** ux-accessibility / flutter-frontend
- **Ergebnis:** Zentrale Flutter-Themes (`app_colors.dart`, `app_typography.dart`, `app_theme.dart`) unter `apps/flutter/lib/core/theme/` erstellt. WCAG 2.2 AA konform (Kontrast, 48x48 Minimum Touch-Ziele, skalierbare Schriften). In `main.dart` integriert.
- **Requirement(s):** FA014, NFA017 (Accessibility)
- **Geänderte Pfade:** `apps/flutter/lib/core/theme/**`, `apps/flutter/lib/main.dart`
- **Bekannte Risiken/Blocker:** Farben könnten nach realen Bild-Inhalten noch mal ein Tuning benötigen (Dark Mode Support später).
- **Nächster konkreter Schritt:** Flutter Frontend (M1-04) kann dieses Design-System nun nutzen, um Screens für Ökosystem-Navigation und Pflanzensteckbriefe umzusetzen.
