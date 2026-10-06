# Performance: Befunde, Messung, Regeln

Der CPU-Renderer ist nur schnell genug, weil er fast nichts pro Frame tut: Projektion, Beleuchtung und Sortierung laufen
einmal, das Ergebnis wird als Bild abgespielt. Diese Seite erklärt, wo das gemessen und wo es gelöst wurde, welche
Werkzeuge es gibt und welche Regeln du beim Ändern der 3D-Ansichten beachten solltest.

!!! warning "Herkunft der Zahlen"
    Alle Millisekundenwerte stammen aus dem Handover `knowledge/handovers/herbarium-map-character-daytime.md`
    (Messung vom 01.10.2026, Linux-Profilbuild mit echter GPU). Sie sind für diese Seite **nicht nachgemessen** worden; es
    wurden keine Stacks gestartet und keine Apps gebaut. Zahlen im Code (Cache-Größen, Winkel, Zeiten) stammen dagegen aus
    dem Quelltext, und wo sie dem Handover widersprechen, gilt der Quelltext.

## Kostenmodell: was kostet pro Frame?

Ein Bild bei 60 fps darf 16,7 ms kosten (UI-Thread und Raster-Thread zusammen müssen sich darin ausgehen).

| Ansicht | Was passiert pro Frame | Kosten |
|---|---|---|
| Lernpfad, ruhend | Der `AnimationController` (6 s) tickt, `_frames.value++` feuert nur beim Wechsel der Phase (16 je Zyklus, also etwa 2,7 mal pro Sekunde); dann wird ein aufgenommenes `ui.Picture` abgespielt | sehr klein |
| Lernpfad, **erster Durchlauf** | Jede der 16 Phasen wird beim ersten Erreichen aufgenommen (`_record`): Projektion aller Vertices, Tiefenschlüssel, Sortierung, `ui.Vertices.raw` | Schwerpunkt der UI-Zeit |
| Lernpfad, **Ziehen** | `view.focus` und `view.yaw` stehen im Cache-Schlüssel; jeder Ziehschritt ist ein neuer Schlüssel, also wird neu aufgenommen | wie erster Durchlauf, aber in jedem Frame |
| Lernpfad, Wechsel von Tageszeit oder Figur | neuer Schlüssel: alle Phasenbilder werden verworfen | wie erster Durchlauf |
| Glühwürmchen (Wiese, abends/nachts) | eigene Ebene `_FireflyPainter`, bei **jedem** Tick neu gemalt; je sichtbarem Modul bis zu 16 Tiere | klein, aber nicht null |
| Vitrine, ruhend | gar nichts: eine Textur wird als Bild gezeichnet | ein Quad |
| Vitrine, schwingend (`animate: true`) | Wechsel zwischen etwa sieben gebackenen Winkeln, danach Ruhe | einmaliges Backen je Winkel |
| Porträt im Auswahlraster | gebackene Textur | ein Quad |
| `ExplorerStage` (große Vorschau) | **jedes Frame** Szene aus 1 000 bis 1 800 Dreiecken neu bauen, solange sie sich dreht oder wiegt | hier gibt es keinen Cache |

Größenordnung beim Aufnehmen des Lernpfads: bis zu drei Module sichtbar, im Wald also etwa 3 × 6 816 = 20 448 Dreiecke
(Meadow 3 × 6 267, Alpine 3 × 2 434). Die Puffer von `SceneBuilder` für diese Menge sind rechnerisch grob 1,4 MB
(Float64-Schlüssel, Float32-Positionen, Farben, Ausgabekopie); sie werden zwischen Aufrufen wiederverwendet.

## Befunde und Lösungen

### 1. Alles Unveränderliche vorberechnen

`WorldMesh` (`world_module.dart`) legt beim ersten Zugriff typisierte Listen an, danach nie wieder:

| Feld | Inhalt |
|---|---|
| `coords` | `Float32List`, x/y/z je Vertex |
| `triangles` | `Int32List`, drei Indizes je Fläche |
| `faceNormals` | `Float32List`, Einheitsnormale je Fläche |
| `_pathColors[phase]` | ARGB je Fläche je Tageszeit, einmal pro Phase berechnet |
| `_shadows[phase]` | Schattenpolygon je Phase |

Der Kommentar im Code nennt das Ziel: „so a frame never allocates per-vertex lists, never recomputes normals and never calls
pow()“. `pow` steckt in der Gamma-Korrektur von `WorldLighting.shade`. Das Vorher-Nachher dieser Umstellung ist in den
Quellen nicht mit Zahlen belegt.

Nebenwirkung: Die ursprünglichen Listen `vertices` und `faces` bleiben zusätzlich im Speicher (`_Fit` und Teile der Tests
brauchen sie). Wie viel das ausmacht, ist **nicht gemessen**.

### 2. Aufnehmen und abspielen: `PictureCache`

Der Lernpfad zeichnet nie direkt, sondern nimmt je Animationsphase ein `ui.Picture` auf und spielt es ab
(`PictureCache.obtain(key, slot, record)` in `world_scene.dart`). Ein neuer Schlüssel verwirft die gesamte Menge. Die
verworfenen Bilder werden erst **beim nächsten Aufruf** freigegeben (`_retired`), damit ein Layer, der noch darauf zeigt,
nicht betroffen ist.

### 3. Vitrinen: eine Textur statt vieler Ebenen

Der größte gemessene Gewinn. Laut Handover lag beim Scrollen der Startseite die Rasterzeit bei **p90 35 ms** (Spitzen 200 ms),
97 von 172 Bildern waren langsam. Ursache war die animierte Hero-Vitrine: Wand, Sockel mit unscharfem Schatten, Modell und
Glas wurden als getrennte Ebenen in jedem Bild neu gezeichnet. Das Modell als Bild oder Textur zu cachen änderte daran
nichts, weil die Ebenen selbst teuer sind. Die Lösung (`_BakedCasePainter` in `ecosystem_vitrine.dart`): Wand, Sockel,
Modell und Glas werden zu **einer** Textur je Winkel gebacken (`picture.toImageSync`) und als ein Rechteck gezeichnet.
Ergebnis laut Handover: **Raster p90 0,5 ms**, 5 langsame Bilder von 217 (nur die ersten Backvorgänge).

Der Code im Überblick:

```dart title="apps/flutter/lib/features/catalog/presentation/widgets/ecosystem_vitrine.dart (in _BakedCasePainter)"
  // At most twelve 1024px textures, rather than desktop-sized GPU surfaces.
  static const _maxImages = 12;
```

```dart title="apps/flutter/lib/features/catalog/presentation/widgets/ecosystem_vitrine.dart (im Build von EcosystemVitrine)"
final pixelRatio = math.min(
  MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0),
  1024 / size.longestSide,
);
```

- Texturgröße begrenzt: Pixeldichte höchstens 2 und so, dass die längste Seite höchstens 1 024 Pixel hat. Beispiel: eine
  Vitrine von höchstens 560 px Breite (`maxWidth: 560` in der `ConstrainedBox`) bekommt `min(2, 1024 / 560) = 1,83`,
  also eine Textur von 1 024 px Breite. Zwölf davon sind rechnerisch bis zu etwa 40 MB GPU-Speicher (1 024 × 819 × 4 Byte ×
  12; Schätzung, nicht gemessen).
- Der Schwenk besteht aus Schritten: `_swing = 0.15` rad, `_bucket = 0.045` rad (ca. 2,6°) – etwa sieben Winkel. Der
  Controller läuft 16 s und wiederholt zweimal (`repeat(count: 2)`), dann steht das Modell.
- Zeitmessung: `FrameStats.note('vitrine-bake', …)` um jedes Backen.

!!! warning "Widerspruch zwischen Handover und Code"
    Das Handover `knowledge/handovers/app-design-vitrine.md` beschreibt noch eine frühere Fassung: gecachte `ui.Picture`
    (höchstens 40) und Schwingen um ±0,2 rad. Im Code gilt heute: gebackene `ui.Image`-Texturen (`_maxImages = 12`) und
    `_swing = 0.15`. Die Zahl „zwei Durchläufe (32 s)“ stimmt noch. Verlass dich auf den Code.

### 4. Weitere Maßnahmen im Code

| Maßnahme | Wo |
|---|---|
| Ganze Meshes außerhalb des Bildes werden nicht projiziert (Bounding-Box), einzelne Flächen außerhalb verworfen | `SceneBuilder._outside`, `cullHeight`/`cullWidth` (der Lernpfad übergibt `size.height` und `size.width`) |
| `RepaintBoundary` um Welt, Glühwürmchen und Vitrine | `modular_forest_view.dart`, `ecosystem_vitrine.dart` |
| `isComplex: true, willChange: false` als Hinweis für den Raster-Cache | `CustomPaint` in der Vitrine und im Porträt |
| Animation aus bei `disableAnimations`, ohne Ticker (Tab nicht sichtbar) und per Pausenknopf | `_updateMotion` in `ModularForestView`, `_syncMotion` in der Vitrine |
| Stationsknöpfe außerhalb des Fensters nicht erzeugen | `_station` |
| Nur drei Module gleichzeitig | Schleife `center - 1 … center + 1` |
| Zwischenspeicher für Module (`WorldModule._cache`) | `WorldModule.load` |

### 5. Sortieren ohne Vergleiche

Gemessen am 06.10.2026, nachdem die Welten rund 60 bis 110 % mehr Dreiecke bekommen hatten (Props, siehe
[Überblick](index.md#zahlwerte-aus-den-json-dateien-06102026)): Die Aufnahme einer Lernpfad-Phase (`path-paint`) kostete im
Wald zunächst 11 ms statt 5,8 ms, und **8,3 ms davon waren `Float64List.sort`** (Stufe `scene-sort`, `FrameStats`).
Die Schlüssel sind kleine ganze Zahlen (Gruppe und 16-Bit-Tiefe, weniger als 2^20), also sortiert `SceneBuilder._sortKeys`
jetzt mit zwei **Zählpässen** (LSD-Radix, 2 × 10 Bit). Das ist stabil und liefert dieselbe Reihenfolge wie vorher.

| Zeit je Aufnahme beim Ziehen (Mittel, 10 s Ziehen, Chromium/Web, Desktop-CPU) | Wald | Wiese | Alpen |
|---|---:|---:|---:|
| A: Stand vor dem Umbau (Code und Welten alt) | 5,8–8,2 ms | 5,8 ms | 2,1 ms |
| B: neuer Code, alte Welten | 6,8 ms | 6,3 ms | 2,4 ms |
| C: neuer Code, neue Welten (mit Radix-Sortierung) | **3,6 ms** | **4,0 ms** | **1,9 ms** |
| C vor der Radix-Sortierung | 11 ms | 9,4 ms | 5 ms |

Der Rechner war bei den Läufen nicht leer (Load 7–8), die Werte schwanken um etwa ±20 %; die Größenordnung und die
Reihenfolge waren in drei Wiederholungen stabil. Auf echten Handys ist nichts gemessen. Gemessen wurde mit
`lib/dev/forest_preview.dart` und `--dart-define=PLANTINI_PERF_LOG=true` (siehe unten, `PERF-SPANS`).

Die Vitrinen und die Entdecker:innen-Bühne (`SceneBuilder.build`) profitieren von derselben Sortierung.

## Werkzeuge

### `FrameStats`: ein Log pro Sekunde

!!! note "Im Browser: `PERF-SPANS`"
    Der Browser meldet keine Frame-Zeiten. Auf dem Web gibt `FrameStats.install()` deshalb zusätzlich jede Sekunde eine
    Zeile `PERF-SPANS name n=… avg=…ms max=…ms | …` mit den benannten Abschnitten aus. Der Lernpfad meldet dort `path-paint`
    und, aufgeschlüsselt, `scene-prepare`, `scene-assemble`, `scene-sort`, `scene-order`, `scene-draw`. Die Vorschau
    `lib/dev/forest_preview.dart` ruft `FrameStats.install()` selbst auf; mit Playwright lässt sich die Konsole auslesen.

`apps/flutter/lib/core/diagnostics/frame_stats.dart`. Opt-in und im Normalbetrieb wirkungslos (`static const _enabled =
bool.fromEnvironment('PLANTINI_PERF_LOG')`). `main()` in `lib/main.dart` ruft `FrameStats.install()`.

```bash
cd <repo>/apps/flutter && flutter run --profile -d linux --dart-define=PLANTINI_PERF_LOG=true
```

Pro Sekunde erscheint eine Zeile über `debugPrint` mit diesem Aufbau:

```text
PERF <fps> fps ui avg=<ms> max=<ms> raster avg=<ms> max=<ms> slow(>20ms)=<n>/<frames> | <name> n=<anzahl> avg=<ms> max=<ms> | …
```

- `ui` ist `FrameTiming.buildDuration` (Build, Layout, Paint auf dem UI-Thread), `raster` ist `rasterDuration` (GPU-Thread).
- `slow(>20ms)` zählt Bilder, deren `totalSpan` über 20 ms liegt.
- Benannte Spannen kommen aus `FrameStats.note(name, duration)`. Es gibt zwei: `path-paint` (jeder `paint()` des
  Lernpfads, also Abspielen **und** Aufnehmen: `n` ist die Zahl der Zeichnungen, ein hoher `max` ist ein Aufnehmen) und
  `vitrine-bake` (nur das Backen einer Vitrinentextur).

### `integration_test/perf_walk_test.dart`: Gang durch die App

Läuft mit Fake-Daten (kein Netz, keine Anmeldung; `createWidgetFlowDependencies(extraLevels: 28)` aus
`apps/flutter/test/app_flow_widget_test.dart`, das ergibt für das Ökosystem `eco-wald` **30 Level**), geht durch Startseite,
Lernen, Lernpfad (Idle, Ziehen, alle vier Tageszeiten), Herbarium und Profil und druckt je Schritt UI- und Raster-Zeiten.
Zwei Aufrufe sind belegt, beide setzen ein Linux-Desktop mit Display voraus:

=== "Laut Kopf der Datei"

    ```bash
    cd <repo>/apps/flutter
    DISPLAY=:0 flutter test integration_test/perf_walk_test.dart -d linux --profile
    ```

=== "Laut Handover"

    ```bash
    cd <repo>/apps/flutter
    DISPLAY=:0 flutter drive --profile -d linux \
      --driver=test_driver/integration_test.dart \
      --target=integration_test/perf_walk_test.dart
    ```

Beide Dateien existieren (`apps/flutter/integration_test/perf_walk_test.dart`, `apps/flutter/test_driver/integration_test.dart`);
keiner der beiden Aufrufe wurde für diese Seite ausgeführt. Mit `--dart-define=ONLY_HOME=1` bricht der Lauf nach den beiden Startseiten-Schritten ab
(`String.fromEnvironment('ONLY_HOME')`).

Stolpersteine des Tests:

- Messwerte sind **nur im Profilbuild** sinnvoll (Kommentar im Kopf: Debug sei um ein Vielfaches langsamer).
- Die Pfad-Schritte sind in `if (card.evaluate().isNotEmpty)` eingepackt: Findet der Test die Karte
  `ecosystem-card-eco-wald` nicht, werden sie **stillschweigend übersprungen** und fehlen im Bericht.
- Der Test schaltet mit `DayClock.pin(phase)` durch alle vier Phasen und ruft am Ende `DayClock.pin(null)`.
- Schwellwerte im Bericht: „slow“ ab 16,7 ms, „>33“ ab 33 ms `totalSpan`; die `FrameStats`-Zeile benutzt dagegen 20 ms.

### `lib/dev/world_bench.dart`: synthetischer Benchmark

Eigener Einstiegspunkt, nicht im Router. Zeigt nacheinander je 9 Sekunden: Lernpfad Wald, Wiese, Alpen, animierte Hero-Vitrine,
drei statische Vitrinen, Scrollen mit einfachen Kästen (Vergleichswert), Scrollen mit Vitrinen („home-like“) und eine leere
Seite als Grundrauschen. Zwischen den `PERF`-Zeilen steht `BENCH <name>`, am Ende `BENCH done`, dann beendet sich der Prozess
(`exit(0)`).

```bash
cd <repo>/apps/flutter && flutter run --release -d linux -t lib/dev/world_bench.dart --dart-define=PLANTINI_PERF_LOG=true
```

Das Programm importiert `dart:io` und läuft deshalb nicht im Browser. Der Vergleich „scrolling-plain-boxes“ gegen
„home-like-scrolling“ ist der direkte Test für die Vitrinen-Lösung.

### Web: Chromium mit CPU-Drosselung

Das Handover beschreibt eine Messung im Browser mit echter GPU (`--use-angle=gl`) und gedrosselter CPU
(`Emulation.setCPUThrottlingRate`). **Dafür gibt es im Repo kein Skript**; sie wird hier nur als Methode beschrieben, ohne
Befehl. Zum Ausliefern der Web-App für solche Messungen existiert `tools/serve-flutter-review.py`
(`--directory`, Standard `apps/flutter/build/demo-review`; `--port`, Standard 3000; bindet an `127.0.0.1`).

## Den Messbericht lesen

Beispiel für das Format einer Berichtszeile (Platzhalter statt echter Zahlen):

```text
home scroll                  frames= NNN ui p50=A p90=B max=C | raster p50=D p90=E max=F | slow>16.7=G >33=H
```

| Frage | Wo du schaust | Was es bedeutet |
|---|---|---|
| Ist die Grafik der Engpass? | `raster p90` | hohe Rasterzeit bei ruhender Szene deutet auf viele Ebenen, Verläufe, Weichzeichner oder Clips pro Frame |
| Ist es die Dart-Seite? | `ui p90`, `max` | Projektion und Sortierung (Aufnehmen), Aufbau der Widgets |
| Ruckelt es? | `slow>16.7`, `>33` | Zahl der Bilder über einem bzw. zwei Vsync-Intervallen |
| Ist es einmalig oder dauerhaft? | `p50` gegen `max` | einzelne hohe `max`-Werte bei niedrigem `p50` sind Anlaufkosten (Backen, erstes Aufnehmen) |

Die berichteten Werte (Handover, Stand 01.10.2026, **für diese Seite nicht nachgemessen**):

| Szenario | Wert |
|---|---|
| Startseite scrollen, vorher | Raster p90 35 ms, Spitzen 200 ms, 97 von 172 Bildern langsam |
| Startseite scrollen, nachher | Raster p90 0,5 ms, 5 von 217 Bildern langsam (Backvorgänge) |
| Lernliste, Lernpfad ruhend / beim Ziehen / bei jedem Tageszeitwechsel, Herbarium, Profil | alle Raster p90 ≤ 1,1 ms |
| Nach dem Hinzufügen der Nachtlichter | Raster p90 unverändert ≤ 1,1 ms |
| Web, CPU 4-fach gedrosselt | 60 fps, UI-Spitzen bis 28 ms durch das Aufnehmen der Lernpfad-Bilder (`path-paint`, ca. 10 ms je Aufnahme) |

Wichtig für die Lesart: „Raster p90 0,5 ms beim Scrollen“ betrifft die **Startseite mit Vitrinen**, nicht den Lernpfad.

## Regeln für Änderungen

1. **Nichts Teures pro Frame.** Alles, was nur von Daten abhängt (Normalen, Farben je Phase, Hüllen), gehört als `late final`
   oder `putIfAbsent` auf das Mesh. Ein Aufruf von `math.pow` oder eine neue `List` pro Vertex im Frame ist ein Rückschritt.
2. **Statische Ansichten backen.** Eine Ansicht, die sich nicht bewegt, wird zur Textur (`toImageSync`), nicht zu einer
   Schleife aus `drawVertices`, Verläufen und Weichzeichnern. Nach demselben Muster arbeiten `_BakedCasePainter` und
   `_PortraitPainter`.
3. **Cache-Schlüssel vollständig halten.** Jede neue Eingabe, die das Bild ändert, kommt in den Schlüssel (Lernpfad:
   `_ForestPainter.paint`; Vitrine/Porträt: der Zeichenkettenschlüssel).
4. **Cache-Größe begrenzen und bewusst freigeben.** Neue Texturcaches brauchen ein Maximum (`_maxImages`) und müssen
   ausgemusterte `ui.Image`/`ui.Picture` mit einem Frame Verzögerung `dispose()`n, wie `_retired` es vormacht.
5. **Dauerschleifen vermeiden.** Animationen enden (Vitrine: zwei Durchläufe), stehen bei `disableAnimations`
   und ohne Ticker still. Begründung im Code: spart Akku und lässt `pumpAndSettle` in Widget-Tests zur Ruhe kommen.
6. **Neue Geometrie budgetieren.** Siehe [Blender-Pipeline](blender-pipeline.md#meshes-budgetieren): der Pfad malt das Dreifache
   eines Moduls; Figuren unter 2 000 Dreiecke (Test).
7. **Messen im Profilbuild**, mit den obigen Werkzeugen, und Zahlen immer mit Gerät und Modus festhalten.

## Offene Punkte

- **Echte Android-Geräte sind nicht gemessen** (der Emulator hat laut Handover keine brauchbare GPU). Die Zahlen gelten für
  einen Desktop-Rechner. Auf schwachen Handys ist die UI-Zeit der Lernpfad-Aufnahmen (16 Phasen nach jedem Ziehen oder
  Tageszeitwechsel) der wahrscheinlichste Engpass.
- Die Zeit der **ersten Aufnahme je Winkel** einer Vitrine auf Handys ist nicht gemessen (`knowledge/handovers/app-design-vitrine.md`, Abschnitt „Offen“).
- Beim **Ziehen** nimmt der Lernpfad in jedem Frame neu auf, weil `focus` im Schlüssel steht. Ob das auf schwachen Geräten
  ruckelt, ist offen; eine Lösung (etwa Aufnahme mit Puffer über das Fenster hinaus und Verschiebung) existiert nicht.
- Die **16 Phasen** sind die Obergrenze für Animationen: Flügelschlag und Windmühle springen alle 0,375 s weiter. Mehr
  Phasen kosten Speicher und Aufnahmen; die Frequenzen der Props sind deshalb auf höchstens 3 je Durchlauf begrenzt.
- Die **Animationen der Props** (`coordsAt`) rechnen je Phase einmal alle Eckpunkte um und halten das Ergebnis im Speicher
  (64 Stufen je animiertem Mesh); wie viel das auf einem Handy ausmacht, ist nicht gemessen.
- Speicherverbrauch der JSON-Listen neben den typisierten Listen: nicht gemessen.

## Weiterführend

- [3D & Blender – Überblick](index.md) · [Blender-Pipeline](blender-pipeline.md) · [Tageszeit und Licht](tageszeit-licht.md) ·
  [Charaktere](charaktere.md) · [Tests und CI](../mitmachen/tests-ci.md)
- Quellpfade: `apps/flutter/lib/core/diagnostics/frame_stats.dart`, `apps/flutter/integration_test/perf_walk_test.dart`,
  `apps/flutter/test_driver/integration_test.dart`, `apps/flutter/lib/dev/world_bench.dart`,
  `apps/flutter/lib/features/catalog/presentation/widgets/world_scene.dart`,
  `apps/flutter/lib/features/catalog/presentation/widgets/ecosystem_vitrine.dart`,
  `knowledge/handovers/herbarium-map-character-daytime.md`, `knowledge/handovers/app-design-vitrine.md`
