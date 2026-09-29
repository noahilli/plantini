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

Der Wald ist bewusst eine kleine Low-Poly-Spielzeuginsel mit wiederholten Kronen, Planken, Blüten und Stationen. Die sechs dargestellten Stationen sind Design-Platzhalter, keine Nutzerfortschritte. Wasserbewegung ist stilisierte Geometrieanimation, keine Fluidsimulation. Render und Modell sind **noch nicht** der Echtzeit-Renderer in Flutter. Nächste Schritte: gemeinsame Animations-Timeline/Instancing optimieren, echten Viewer und zugängliche Level-Overlays integrieren, Reduced Motion respektieren, dann Wiese/Alpen aus denselben Bausteinen entwickeln. Bestehende Level-Freischaltungen nicht durch Demo-Zustände ersetzen.
