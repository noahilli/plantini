# Pflanzenkartei und echte 3D-Welt — 29.09.2026

## Karten-Vorlage

`PlantIndexCard` ist die gemeinsame Flutter-Vorlage für Steckbrief vor dem Quiz und Pflanzendetail. Registerlasche, Papierfläche, Titel/lateinischer Name/Familie, Bild und Quellenangaben, strukturierte Faktenabschnitte und Sicherheitshinweis. Ab 680px und bei moderater Schriftvergrößerung zweispaltig; sonst untereinander. Keine feste Kartenhöhe, keine erfundenen botanischen Angaben. Alle Inhalte stammen aus `Plant`/`profileCards` und damit aus dem CMS. Die BANini25-Seite dient als Strukturvorbild, keine kopierten Bildassets oder erfundenen Angaben.

Nachweise: `flutter analyze --no-pub lib`, Linux-Releasebuild erfolgreich, App neu gestartet. Keine neuen Tests. Vollständige visuelle Abnahme durch den Nutzer steht aus.

## Blender-Prototyp

Über den lokalen Blender-MCP-Socket `127.0.0.1:9876` erstellt. Neue eigene Szene `Plantini • Waldlichtung`; vorhandene Szene bleibt erhalten. Originale prozedurale Geometrie und einfache Materialien, keine externen Texturen oder Assetdienste. Reproduzierbarer Builder: `tools/blender/create_forest_world.py`. Er verweigert das Überschreiben eines vorhandenen Blend-Artefakts; für einen neuen Entwurf den Ausgabeordner versionieren.

Artefakte unter `artifacts/3d/forest-20260929-v1/`:

- `plantini-forest.png`: tatsächlich gerendertes Cycles-Bild, 1600×1200, visuell geprüft.
- `plantini-forest.blend`: editierbare Szene mit 120 Frames bei 24fps; Baum-Pivots wiegen sich, Wasserreflexe bewegen sich.
- `plantini-forest.glb`: exportierte Geometrie und Animationen; 248 Nodes, 215 Meshes, 28 Animationsspuren. Alle 28 Spuren gemeinsam abspielen, nicht nur den ersten Clip.

Der ursprüngliche Wald ist eine kleine Low-Poly-Spielzeuginsel mit wiederholten Kronen, Planken, Blüten und Stationen. Die sechs Stationen im ursprünglichen Render sind Design-Platzhalter. Wasserbewegung ist stilisierte Geometrieanimation, keine Fluidsimulation.

## Modulare Flutter-Integration

`tools/blender/export_forest_module.py` exportiert aus der geöffneten Szene `Plantini • Waldlichtung` ein anschließbares Waldsegment nach `apps/flutter/assets/worlds/forest_module.json`. In Blender ausführen; der Ausgabe-Repositorypfad steht im Skript. Originalgeometrie bleibt unverändert. 239 Meshes / 6512 Dreiecke; Modul-Länge 10 Welteinheiten, sechs Level-Slots. Bach und Weg treffen an beiden Modulenden auf identische Anschlusskoordinaten. Slot-Geometrie wird im unvollständigen letzten Modul ausgeblendet.

`ModularForestView` projiziert echte Mesh-Geometrie mit Flutter Canvas (CPU-Projektion, Dreieckssortierung, einfache Flächenbeleuchtung; kein GLB-Player und kein Screenshot-Hintergrund). Jeweils nur aktuelles Modul und beide Nachbarn werden aufgebaut. Modulanzahl = aufgerundete Levelanzahl / 6. Die Länge ist damit nicht auf 30 Level begrenzt. Bäume und Wasserreflexe bewegen sich; die 3D-Figur steht am ersten offenen Level. Pause, System-Reduced-Motion und TickerMode werden berücksichtigt. Seitliches Ziehen dreht die Ansicht, vertikales Ziehen bzw. Slider und Pfeile bewegen durch die Module.

`ResearcherPathView` verwendet den Renderer für Ökosystem-Slugs mit `laubwald`. Levelstatus, IDs und Klick-Callbacks kommen unverändert aus dem Katalog; gesperrte Level bleiben gesperrt. Das bestehende Finale wird am letzten Modul eingeblendet. Wiese und Alpen behalten vorerst ihre vorhandene Ansicht. Keine Änderung an Authentifizierung, API oder Fortschrittsspeicherung.

### Nachweise und Grenzen

- `flutter analyze --no-pub lib`, Web-Vorschau-Releasebuild, Linux-App-Releasebuild und `git diff --check` erfolgreich.
- Separate `lib/dev/forest_preview.dart` dient ausschließlich als klar beschriftete Designvorschau; nicht im App-Router. Ihre Fortschritte sind synthetisch, kein Nachweis eines authentifizierten Lernablaufs.
- Manuelle Browser-Laufzeitprüfung mit Chromium: 31 Level → sechs Module, mit echten Pointer-Klicks bis Modul sechs; dort genau die letzte Station sichtbar. Bewegung verändert das Bild, Pause hält es stabil. Desktop und Mobilansicht visuell kontrolliert; Screenshots unter `artifacts/3d/modular-forest-*.png`.
- Dabei Layoutfehler korrigiert: Stack muss die verfügbare Fläche ausfüllen, sonst konnte die Welt nach dem Ausblenden außerhalb liegender Stationen auf null Größe schrumpfen.
- Flutter-Semantik-Overlay verhindert teilweise Playwright-Locator-Klicks; echte Mauskoordinaten funktionieren. Keine neuen Tests geschrieben, vorhandene fremde Teständerungen unangetastet.
- Offen: angemeldeter kompletter Lernablauf mit dieser Ansicht, Performance auf echten Mobilgeräten, Wiesen-/Alpenmodule. Renderer bewusst einfach: keine Echtzeitschatten, keine Flüssigkeitssimulation und kein GPU-Z-Buffer. Das Cycles-Referenzrender bleibt optisch hochwertiger als dieser portable Echtzeit-Renderer.
