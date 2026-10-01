# Herbarium-Fotos, Karte, Artkarten, Tageszeit, Charakter — 30.09.2026

Commits: `07c578e`, `dca4fbd`, `370f3e4` (Fotos, Cache, Fehler), `df8fcf7` (Karte, Artkarten, Quoten), `b10d9b4` (Tageszeit), `67c55b5` (Charakter). **Nichts davon ist auf dem Produktivserver ausgerollt.**

## Ursache „Fundfoto nicht verfügbar“

Die App schickte beim Speichern eines Fundes nur `identificationJobId`, nie `mediaId`; die API hatte weder ein Feld im Fund noch einen Endpunkt zum Abrufen privater Fotos. Jetzt: `herbarium-service.js` leitet `mediaId` aus dem Bestimmungsauftrag ab (nur wenn das Foto noch `uploaded` ist; Speichern scheitert nie am Foto), ältere Funde bekommen es beim Lesen aus dem Auftrag, `GET /media/{id}/content[?width=320|720|1280]` liefert das Foto nur dem Besitzer (404 für andere, 401 ohne Token; `Cache-Control: private, immutable`, ETag; Verkleinerungen werden auf dem Server gespeichert). Gegen den echten e2e-Stack geprüft (200/404/401, 156 185 Byte Original, 8 856 Byte bei `width=320`).

## Bild-Cache

- Server: öffentliche Pflanzenfotos werden höchstens wöchentlich neu von der Quelle geholt (`public-photo-cache.js`: `REFRESH_MS` 7 Tage, `MAX_FILES` 4096 statt 256, bei Quellenfehler wird die alte Kopie geliefert); Galerielisten der Wikimedia-Suche werden 7 Tage im Metadatenspeicher gehalten. Foto-URLs mit `photoId` sind `immutable`.
- App: `lib/core/images/` (`ImageService`: Speicher → Platte → Netz, Native: Dateien unter `getApplicationSupportDirectory()/images`, **ohne Größenobergrenze**; Web: nur Speicher + Browser-Cache). URLs mit `/media/` oder `photoId` werden nie neu geladen, alle anderen nach 7 Tagen, bei Netzfehler wird die alte Kopie gezeigt. Fund: der erste Fehler war `whenComplete(() => map.remove(k))` (gibt das eigene Future zurück → wartet ewig); `test/core/image_service_test.dart` deckt das ab.

## Ladeanimation und Fehler-Popups

`field_capture_screen.dart`: `AnalysisProgress` (Foto mit Scan-Strahl, Ring, drei echte Schritte hochladen/warten/vergleichen, Tipps) und `field_problem.dart` (`FieldProblem.fromFailure/fromJob`, Dialog mit Ursache, Hinweis, „Erneut versuchen“ wiederholt genau den gescheiterten Schritt, bei abgelaufener Sitzung „Anmelden“). `RateLimitedFailure` (HTTP 429) neu.

## Karte, Artkarten, Quoten

- Karte: dritter Reiter „Karte“ im Herbarium (`herbarium_map_view.dart`, flutter_map + `PlantiniTileProvider`). Kacheln nur über `GET /tiles/{z}/{x}/{y}` (Server lädt `tile.openstreetmap.org`, 14 Tage Cache unter `<PRIVATE_UPLOAD_DIR>/map-tiles`, nur angemeldet, Zoom ≤ 18). Hinweis: OSM-Nutzungsbedingungen (User-Agent nennt nur die Projekt-URL, Cache 14 Tage; Anfragen laufen durch eine Warteschlange mit höchstens 6 gleichzeitigen Abrufen) bei Last prüfen.
- Artkarten: `species-card` (Strapi-Inhaltstyp, neue Tabelle `species_cards`): für bestätigte Arten **außerhalb** des Katalogs, Wikipedia-Kurztext (Wikidata-P225-Prüfung, CC BY-SA) und Foto, wöchentlich neu geprüft; nie in Ökosystemen/Leveln. Foto über `GET /species/{key}/photo` (Server-Cache). Im e2e ohne Internetzugang für Wikipedia blieb der Text leer (Foto und Karte wurden angelegt, Wiederholung nach einer Stunde vorgesehen); mit echtem Netz **nicht getestet**.
- Quoten: `GET /stats/collection` (Anteil der Konten mit bestätigtem Fund; `label` „12 %“, unter 1 % „3 ‰“, unter 0,5 ‰ „<1 ‰“; 10 min Cache; erst ab 20 Konten). In Pflanzenkarte und Fund angezeigt. Bei zu wenigen Konten zeigt die App nichts.
- Datenschutz: siehe `architecture/security-and-privacy.md` (Fundort kommt jetzt an die besitzende Person zurück).

## Tageszeit

`world_lighting.dart`: `DayPhase` (05–10 Morgen, 10–16 Mittag, 16–21 Abend, sonst Nacht), `WorldLighting` (Sonnenrichtung, Sonnen-/Umgebungsfarbe, Himmel, Sonnen-/Mondglühen, Sterne, Laternen), `DayClock` (folgt der Uhr, im Profil pinnbar; Startparameter `--dart-define=PLANTINI_DAYTIME=night`). Lichtformel `Basis·(ambient + sun·n·l)` je Farbkanal; Baum- und Figurenschatten als konvexe Hülle entlang des Lichts (eine Fläche je Objekt); Stationen leuchten abends/nachts. Bilder werden je Phase gecacht. Kein Timer: Aktualisierung beim Start und beim Zurückkehren in die App.

## Lichtquellen am Abend und in der Nacht (01.10.2026)

`tools/blender/add_night_lights.py` (reines Python, idempotent, **nach jeder Neuerzeugung der Module erneut ausführen**, weil `create_ecosystem_modules.py` Wiese und Alpen von Grund auf neu baut) ergänzt die Module: kleine Hütte im Wald (2,3 / −4,4) und in den Alpen (2,8 / 3,6; Steinwände, Schneedach), Laternen am Weg in Wald (4) und Wiese (5), dazu `lights` (x, y, z, Radius) und für die Wiese `fireflies`. Die Plätze werden gegen die vorhandene Geometrie geprüft (nicht im Bach, auf dem Weg oder im Baum). Meshes mit `motion: glow` (Fenster, Laternenglas) sind tagsüber blass und abends/nachts warmes Licht; um jede Lichtquelle zeichnet die App einen weichen Schein und einen Lichtfleck am Boden (`paintLightHalos`, additiv, in den gecachten Bildern). Glühwürmchen (`FireflyField`, 16 Punkte, nahtlose 6-s-Schleife) fliegen als eigene leichte Ebene über der Wiese (nachts alle, abends 40 %); in den Vitrinen erscheinen einige als Standbild. Tagsüber sind Hütten und Laternen als Kulisse sichtbar. Messlauf nach der Änderung unverändert (Raster p90 ≤ 1,1 ms). Grenze: Der Schein liegt über allem, auch über Baumkronen, die vor einer Hütte stehen.

## Charakter (Stand 01.10.2026: festes Set statt Designer)

Der Charakter-Designer (frei kombinierbare Teile, `67c55b5`) ist entfernt. Stattdessen gibt es **neun feste Entdecker:innen**, alle im Forscher-Stil (Westen, Fernglas, Notizbuch, Safari-/Ranger-Hut), bewusst unterschiedlich in Hautton, Alter, Haaren, Kopfbedeckung, Statur und Mobilität:

| Gruppe | Figuren |
|---|---|
| Frauen | Amara (dunkle Haut, Afro-Puffs, Fernglas), Mei (Bob, Eimerhut, Brille, Notizbuch), Samira (Hijab, langer Mantel, Rucksack) |
| Männer | Heinrich (älter, grauer Bart, Rangerhut), Mateo (Locken, Kappe, Kamera), Arjun (Turban, Vollbart, Rucksack) |
| Divers | Robin (Regenmantel, Undercut, runde Brille), Nia (Rollstuhl, Locs, Safarihut), Kai (Bandana, Zopf, Poncho) |

- Blender: `tools/blender/create_explorer_characters.py` (`blender -b -P …`; `-- --front` rendert frontal, `-- --no-render` ohne Vorschau) baut die neun Modelle aus Primitiven (je 1 000–1 800 Dreiecke, Farben fest eingebacken) und exportiert `apps/flutter/assets/characters/explorers.json` (282 KB); Kontaktbogen in `artifacts/3d/explorers/`. **Der Blender-MCP-Socket lief nicht**, gebaut wurde headless. Der Painter-Sortierung zuliebe dürfen Teile keine deckungsgleichen Flächen haben (Taschen/Riemen stehen 5 mm vor der Weste).
- Daten: `Character` im Vertrag ist nur noch `{v: 2, id}` mit einer von neun IDs (`profiles.character`, `PATCH /me`, Whitelist in `profile/character-schema.js`, ein Test vergleicht sie mit `explorers.json`). Alte Designer-Datensätze (`v: 1`) werden nicht mehr ausgeliefert; die App zeigt dann die Auswahl.
- App: `lib/features/character/` – `ExplorerRoster`/`PlayerLook` (Modelle, Spielerwahl), `CharacterStore` (Laden nach Login, Gerätecache `explorer_v2` mit „dirty“-Markierung für Offline-Wahl, Standardfigur `kai` ohne Serverantwort), `CharacterSelectorScreen` (große drehbare Vorschau + 3×3-Raster, Porträts als einmal gebackene Texturen), im Profil „Charakter wechseln“. Erste Anmeldung ohne Wahl → `/character`. Die Figur ersetzt den Ranger auf dem Lernpfad und in den Vitrinen.
- Grenzen: Nia sitzt im Rollstuhl (kein Gehen-Animation, auf dem Pfad steht sie wie die anderen an der Station); keine weiteren Figuren/Teile auswählbar.

## Leistung (Messung 01.10.2026)

Messwerkzeug: `integration_test/perf_walk_test.dart` (`DISPLAY=:0 flutter drive --profile -d linux --driver=test_driver/integration_test.dart --target=integration_test/perf_walk_test.dart`; `--dart-define=ONLY_HOME=1` nur Startseite). Läuft die App mit Fake-Daten über Home, Lernen, Lernpfad (30 Level, vier Tageszeiten), Herbarium, Profil und gibt UI-/Raster-Zeiten je Schritt aus. Web: Chromium mit echter GPU (`--use-angle=gl`) und `Emulation.setCPUThrottlingRate`.

- **Befund:** Beim Scrollen der Startseite lag die Rasterzeit bei p90 35 ms (Spitzen 200 ms), 97 von 172 Bildern waren langsam. Ursache war die animierte Hero-Vitrine: Wand, Sockel mit unscharfem Schatten, Modell und Glas wurden als getrennte Ebenen jedes Bild neu gezeichnet (Modell als 19 000-Dreiecke-Bild oder Textur ändert daran nichts, die Ebenen selbst kosten).
- **Behebung:** Jede Vitrine – auch die schwingende – ist jetzt immer **eine** gebackene Textur je Winkel (`_BakedCasePainter`); beim Schwingen wechselt sie zwischen etwa sieben Winkeln (Schritt 2,6°, ±8,6°). Danach: Raster p90 0,5 ms, 5 langsame Bilder von 217 (nur die ersten Backvorgänge).
- Weitere Schritte unauffällig (Linux-Profil, echte GPU): Lernliste, Lernpfad im Ruhezustand/beim Ziehen/bei jedem Tageszeitwechsel, Herbarium, Profil – alle p90 Raster ≤ 1,1 ms. Web mit 4-fach gedrosselter CPU: 60 fps, einzelne UI-Spitzen bis 28 ms durch das Neuaufnehmen der Lernpfad-Bilder (`path-paint`, ca. 10 ms je Aufnahme bei Drossel 4).
- **Nicht gemessen:** echte Android-Geräte (der Emulator hat keine brauchbare GPU). Die Zahlen gelten für einen Desktop-Rechner; auf Handys ist die UI-Zeit der Lernpfad-Aufnahmen (alle 16 Phasen nach jedem Ziehen/Wechsel der Tageszeit neu) der wahrscheinlichste Engpass.

## Tests

Neu: `test/core/image_service_test.dart`, `test/features/catalog/world_lighting_test.dart`, `test/features/character/explorer_test.dart`, Backend `tile-proxy.test.js`, `character-schema.test.js`. Flutter: 123 bestanden, dieselben **13 Fehler wie vor den Änderungen** (Stand `ba6919e`: Level-Gate-, Researcher-Path-, Plant-Detail-, Router- und Herbarium-Detail-Tests sowie ein Kompilierfehler in `game05_herbarium_bottles_test.dart` – Altlasten, nicht angefasst). Backend: 46 Tests, 42 bestanden, 4 übersprungen (Redis).

## Ausrollen (Reihenfolge, nicht ausgeführt)

1. Platform-Image bauen und laden (Schema-Migration legt `species_cards` und `profiles.character` an, `production-deploy.md`), `up -d platform`.
2. Web-App bauen (`--no-web-resources-cdn`, Produktions-Defines) und nach `/opt/plantini/web` kopieren.
3. APK neu bauen (`flutter build apk` ohne `--no-pub`, neue Abhängigkeit flutter_map).
4. Von außen prüfen: Foto im Herbarium, `/api/v1/tiles/5/17/10` mit Token, Charakter-Editor beim ersten Login.
