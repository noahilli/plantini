# App-Design: Vitrine, Schrift, Lernkarten-Optik — 30.09.2026

Owner: Flutter-Frontend / UX. Ziel des Nutzers: moderner, einladender für Schüler:innen, Hintergrundbilder durch ein Mini-Modell des Ökosystems in einer Vitrine ersetzen. Vorlage: `knowledge/references/design/plantini-mobile-app-design/` (Organic-System, Variante „Home · Terrarium wächst mit“). Erste Scheibe (Slice 1); Quiz, Feldaufgabe, Kamera, Abschluss-Feier und Profil sind noch nicht überarbeitet.

## Befund vor der Änderung

- `AppTypography` benannte `Caprasimo` und `Figtree`, **keine der Schriften war gebündelt** (kein `fonts:`-Abschnitt in `pubspec.yaml`). Die App lief in Roboto; auf Web holt CanvasKit Ersatzschriften von einem CDN.
- Kacheln und Hero nutzten generische Weltbilder (`assets/worlds/*.png`, Herkunft der Bilder nicht dokumentiert).

## Umgesetzt

- **Schriften** (`assets/fonts`, SIL OFL 1.1, Lizenzdateien liegen daneben, `NOTICE` ergänzt): Caprasimo (ein Schnitt, allen Gewichten 400–900 zugeordnet, sonst verschmiert Flutter ein künstliches Fett), Figtree Regular/SemiBold/Bold als statische Instanzen aus der Variablenschrift (`fonttools instancer`, kein Reserved Font Name deklariert). Lesegrößen um 1 pt erhöht (`app_typography.dart`), AppBar-Titel in Figtree.
- **`EcosystemVitrine`** (`features/catalog/presentation/widgets/ecosystem_vitrine.dart`): Glasvitrine mit Walnuss-Sockel, Messingschild und Messingleiste, darin dasselbe Blender-Modul wie der Lernpfad. Eigene Fit-to-bounds-Projektion (die des Pfads erzwingt ≥ 52 px Maßstab), Stationsgeometrie (`slot != null`) weggelassen, Ranger an Station 1, Licht fest zum Betrachter, keine Gammakorrektur (sonst ausgewaschen).
- **Leistungsmodell:** Projektion, Beleuchtung und Sortierung laufen einmal je (Welt, Winkel-Bucket, Größe) und werden als `ui.Picture` gecacht (max. 40). Statische Vitrinen zeichnen nie neu. Nur Home-Hero und Login wiegen das Modell ±0,2 rad, **zwei Durchläufe (32 s), danach Ruhe**; kein Wiegen bei `disableAnimations` oder wenn kein Ticker läuft. Ohne Endlosanimation kommen Widget-Tests mit `pumpAndSettle` zur Ruhe.
- **Modulparser** aus `modular_forest_view.dart` nach `world_module.dart` (`WorldModule.load`, gecacht) verschoben; `EcosystemWorld.shortName` (Wald/Wiese/Alpen).
- **Screens:** Home (Hero-Vitrine, Sterne-Chip aus echten Level-Daten, Ökosystem-Kacheln als Mini-Vitrinen), Lernen/Ökosystemliste (Vitrinenkarten, Titel und Etikett per `Wrap`, damit „Alpenraum“ bei 320 px nicht mitten im Wort bricht), Herbarium (Vitrine je Ökosystem mit „n von m Arten im Regal“ aus Katalog und eigenen bestätigten Funden), Login (Vitrine statt Bild; Inhalt scrollbar, sonst Überlauf bei 600 px Höhe).
- Keine Zahlen aus dem Entwurf übernommen („42 %“, „12 von 25 Arten“, Schichtbalken): nur echte Daten (Level, Sterne, Katalog, Funde).

## Nachweise

- `flutter analyze lib` sauber; `flutter analyze` (mit `test/`) unverändert 1 Fehler + 2 Hinweise in `test/game05_herbarium_bottles_test.dart` (bestehend).
- `flutter test`: **12 Tests rot vor und nach der Änderung, dieselben** (Abgleich per JSON-Reporter). Ein Test (`redirects to /login when unauthenticated`) war zwischenzeitlich durch die Login-Vitrine (Endlosanimation, dann Überlauf) rot und wurde durch endliches Wiegen und scrollbaren Login wieder grün. Keine neuen Tests (GAME-QA pausiert).
- Web-Build im Chromium (390×844 und 320×640) mit angemeldetem Test-Lernenden durchgeklickt: Home, Lernen, Lernpfad, Lerneinheit, Herbarium, Expedition, Profil, Login. Screenshots nur lokal (Scratchpad), nicht im Repo.
- `tools/serve-flutter-review.py` liefert jetzt die App-Shell für jede SPA-Route (Deep-Link-Tests).

## Offen / beobachtet

- Nutzer-Abnahme der Optik, Leistung auf echten Handys (Bildzeit der ersten Bildaufnahme je Winkel nicht gemessen), 200-%-Schrift nicht geprüft, Quiz/Feldaufgabe/Kamera/Abschluss-Feier/Profil noch im alten Stil.
- **Beobachtung, Ursache nicht untersucht:** Ein Deep-Link auf `/ecosystems/<id>` nach dem Neuladen landet nach dem Boot auf `/home` (Route wird nicht wiederhergestellt; APP-04).
- Die Weltbilder unter `assets/worlds/*.png` werden nicht mehr für Home/Liste verwendet, liegen aber noch im Repo; Herkunft/Rechte klären, bevor sie öffentlich gezeigt werden.
