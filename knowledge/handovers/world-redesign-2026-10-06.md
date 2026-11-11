# 3D-Ökosysteme: verspielteres Design und Licht, das hinter Bäumen bleibt (06.10.2026)

Stand: Branch `main`, Commits `a38b90c` (Dart) und `7f2cec5` (Welten und Skripte). Aufgabe: `WORLD-11` (bleibt offen,
Nutzerabnahme fehlt; **nicht** ausgerollt, **nicht** auf einem Handy gesehen).

## Anlass

Auftrag: „Ökosysteme verspielter, mehr Elemente, schöneres Licht, das auch tatsächlich richtig funktioniert (nicht durch
Bäume durch)“. Fehlerbild vor dem Umbau (Vorschau `lib/dev/forest_preview.dart`, 390 × 800, Nacht): der Schein einer Lampe
lag **über** einer Baumkrone, und in den Alpen leuchtete die Hütte durch den Berg. Ursache:
`paintLightHalos` lief nach `drawVertices` und malte additiv über alles.

## Was sich geändert hat

| Thema | Änderung | Wo |
|---|---|---|
| Licht hinter Bäumen | `SceneBuilder.paintScene` zerlegt den Dreieckspuffer und setzt `SceneMarker` in die Tiefenordnung (Schein an der Tiefe der Lampe, Lichtpfütze nach dem Flachen und vor dem Aufrechten). Pfad und Vitrine. | `world_scene.dart`, `world_lighting.dart` (`paintLightPool`, `paintLightOrb`), `modular_forest_view.dart`, `ecosystem_vitrine.dart` |
| Lampenlicht auf Flächen | Flächen, die einer Lampe zugewandt sind (≤ 2,4 Radien), werden warm; große Flächen und der Spieler ausgenommen | `WorldMesh._lampLight`, `WorldLighting.shade(lamp:)` |
| Rundung, Dunst, Wolken | Helligkeit je Eckpunkt (0,78 Fuß … 1,12 Spitze), Dunst nach hinten, sechs Wolken unter der Insel | `WorldMesh.vertexShade`, `_assemble`, `paintClouds` |
| Schatten | ein Schatten je Baum (Pivot) bzw. `shadow`-Kennung, plus weicher Fußfleck | `WorldModule.shadowPieces`, `WorldMesh.contactOf` |
| Animationen | `spin`, `flap`, `bob`, `hop`, `orbit`; `day`-Wesen nachts weg | `WorldMesh.coordsAt` |
| Varianten | Modul `m` zeigt die Props der Variante `m % 2` (Wiederholung alle 10 Einheiten vermeiden) | `WorldMesh.variant`, `WorldModule.lightsOf` |
| Inhalte | Zeltlager mit Feuer, Pilzhaus, Feenring, Windmühle, Bienen, Brunnen, Gnome, Kapelle, Kühe, Steinbock, Adler, Schmetterlinge u. a. | `tools/blender/add_playful_props.py`, `world_kit.py` |
| Sortierung | zwei Zählpässe statt `Float64List.sort` | `SceneBuilder._sortKeys` |

Reihenfolge der Skripte: `create_ecosystem_modules.py` (nur wenn Wiese/Alpen neu gebaut werden) → `add_playful_props.py` →
`add_night_lights.py`. Der Wald aus Blender wird nie neu erzeugt, nur ergänzt. Beschreibung: Handbuch,
`docs-site/docs/3d/blender-pipeline.md`.

## Belege

- **Licht-Fix:** Vorher/Nachher bei identischer Kamera (Vorschau, Nacht), Wald und Alpen: kein Lichtfleck mehr auf der Krone,
  kein Leuchten durch den Berg; die Laterne zeigt jetzt ihr Glas statt eines überstrahlten Klotzes, Steine und Blumen daneben
  sind warm beleuchtet. (Aufnahmen im Scratchpad der Sitzung, nicht im Repo; Wiederholung:
  `flutter build web --release -t lib/dev/forest_preview.dart`, dann `?world=alpine&daytime=night&levels=31`.)
- **Messung** (`--dart-define=PLANTINI_PERF_LOG=true`, Chromium/Web, 10 s Ziehen, Mittel von `path-paint`; Rechner nicht leer,
  etwa ±20 %): Wald 5,8–8,2 ms → 3,6 ms, Wiese 5,8 → 4,0 ms, Alpen 2,1 → 1,9 ms (alter Stand gegen neuen, jeweils mit den
  Welten ihres Standes). Ohne die neue Sortierung wären es 11, 9,4 und 5 ms gewesen; `scene-sort` allein war 8,3 ms.
  Auf Handys **nicht gemessen**.
- **Dreiecke je Modul:** Wald 6 816 → 10 518/10 998, Wiese 6 267 → 9 237/9 003, Alpen 2 434 → 4 713/4 977. Dateien zusammen
  0,65 → 1,6 MB.
- `flutter analyze lib` ohne Befund. `flutter analyze` (ganz) meldet 3 Treffer in `test/game05_herbarium_bottles_test.dart`
  (vorher vorhanden, nicht angefasst). `flutter test`: **128 grün, 13 rot; dieselben 13 sind auch auf `HEAD` vor den Änderungen
  rot** (Vergleich der Listen im Worktree). Neue Tests wurden nicht geschrieben (GAME-QA pausiert).
- Vitrinen: eigene Vorschau `lib/dev/vitrine_preview.dart` (Tag, Abend, Nacht) gesichtet; die Vitrine im echten Home-Screen
  wurde **nicht** gesehen.

## Offen / nicht untersucht

- Nutzerabnahme (Geschmack: „verspielt“). Bei Bedarf sind Props, Dichte und Farben in `add_playful_props.py` schnell
  änderbar; die Dart-Seite bleibt gleich.
- Handy-Performance (Aufnahme je Phase, Speicher der animierten Koordinaten), Lesbarkeit der Nacht auf echten Geräten.
- Lampenlicht prüft nur die Zuwendung der Fläche, keine Verdeckung durch Körper dazwischen.
- Die Screenshots und das GIF des Lernpfads im Nutzungsteil des Handbuchs (`docs-site/docs/nutzung/`) zeigen noch den **alten**
  Stand der Welten und müssten neu aufgenommen werden (`docs-site/scripts/capture-app.cjs`, braucht den Stack mit neuem
  Web-Build).
- Glühwürmchen bleiben eine Ebene über dem Bild (nur Wiese, `world_lighting_test.dart` erlaubt `fireflies` nur dort).
