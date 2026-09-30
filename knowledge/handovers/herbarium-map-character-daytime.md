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

## Charakter

- Blender: `tools/blender/create_character_parts.py` (`blender -b -P …`; `--no-render` lässt die Vorschau weg, `-- --front` rendert frontal) baut 25 Teile aus Primitiven (Körper, 4 Oberteile, 3 Unterteile, 3 Schuhe, 6 Frisuren, 4 Hüte, 3 Brillen, Rucksack) und exportiert `apps/flutter/assets/characters/parts.json` (102 KB); Kontaktbogen in `artifacts/3d/character-kit/`. **Der Blender-MCP-Socket (127.0.0.1:9876) lief nicht**; gebaut wurde headless mit demselben Skriptansatz wie die Weltmodule.
- Daten: `Character` im Vertrag (`v`, `gender`, `skin`, je Teil `style` + `color`), im Profil (`PATCH /me`, `profiles.character` als JSON), serverseitige Whitelist in `profile/character-schema.js` (ein Test vergleicht sie mit `parts.json`), Gerätecache mit „dirty“-Markierung für Offline-Änderungen (`character_store.dart`).
- Ablauf: nach dem Login lädt die App den Charakter (Bootbild währenddessen); hat der Server keinen, öffnet sich `/character` (nur beim ersten Login). Ohne Serverantwort und Cache wird ein Starter gezeigt, niemand wird durch eine tote Verbindung in den Editor gezwungen. Profil: „Charakter ändern“. Der Charakter ersetzt den Ranger auf Lernpfad und in den Vitrinen.
- Grenzen: nur eine Kopfgröße/Körperhöhe, Geschlecht verändert nur die Körperbreite; Kleidung ist frei kombinierbar; keine Animation der Figur.

## Tests

Neu: `test/core/image_service_test.dart`, `test/features/catalog/world_lighting_test.dart`, `test/features/character/character_test.dart`, Backend `tile-proxy.test.js`, `character-schema.test.js`. Flutter: 127 bestanden, dieselben **13 Fehler wie vor den Änderungen** (Stand `ba6919e`: Level-Gate-, Researcher-Path-, Plant-Detail-, Router- und Herbarium-Detail-Tests sowie ein Kompilierfehler in `game05_herbarium_bottles_test.dart` – Altlasten, nicht angefasst). Backend: 45 Tests, 41 bestanden, 4 übersprungen (Redis).

## Ausrollen (Reihenfolge, nicht ausgeführt)

1. Platform-Image bauen und laden (Schema-Migration legt `species_cards` und `profiles.character` an, `production-deploy.md`), `up -d platform`.
2. Web-App bauen (`--no-web-resources-cdn`, Produktions-Defines) und nach `/opt/plantini/web` kopieren.
3. APK neu bauen (`flutter build apk` ohne `--no-pub`, neue Abhängigkeit flutter_map).
4. Von außen prüfen: Foto im Herbarium, `/api/v1/tiles/5/17/10` mit Token, Charakter-Editor beim ersten Login.
