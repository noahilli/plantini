# Editorial-Pflanzenkarten und Lernmodus — 29.09.2026

## Scope / Ownership

DESIGN-10 / MEDIA-10 / LEARN-12, Flutter-Frontend. Gemeinsame Kartenvorlage, Bildgalerie, Designvorschau, Abruf bestehender öffentlicher Bildendpunkte und eigener Lernmodus. Keine Änderungen an Fach-API, Datenbankschema, Authentifizierung oder Level-Abschlussregeln. Fremde Herbarium-/Teständerungen bleiben unangetastet. Keine neuen Tests gemäß Nutzerwunsch.

## Gestalterische Referenzen

- [Uni Ulm BANini25](https://www.uni-ulm.de/einrichtungen/garten/gruenes-klassenzimmer/banini-artenkenntnis/banini-arten-datenbank/banini25/): visuell angesehen; Artname, Familie, Pflanzenbild und kompakte Merkmale als zusammengehöriges Blatt.
- [RHS: Make your own herbarium specimens](https://www.rhs.org.uk/education-learning/school-gardening/resources/gardening-club/make-your-own-herbarium-specimens): beschriftete Pflanzenbelege auf Papier als konzeptionelle Referenz.
- Kew-Pflanzenporträts recherchiert, aber die visuelle Seite war durch eine Bot-Prüfung gesperrt; kein behaupteter visueller Vergleich.

Eigenständige Flutter-Gestaltung, keine fremden Layoutgrafiken oder Pflanzenfotos kopiert. Redaktionelle Inhalte werden unverändert dargestellt; keine neuen botanischen Aussagen aus Bildfarbe oder Pflanzennamen abgeleitet.

## Umsetzung

`PlantIndexCard`: warmer Papiergrund, Masthead, große Titelhierarchie, wissenschaftlicher Name, Familienetikett, ruhiger Lesetext, nummerierte Feldnotizen und separater Sicherheitsbereich. Ab 720px zweispaltiger Bild-/Textbereich, bei großer Schrift einspaltig. Quellen weiter ausklappbar und auswählbar.

`PlantPhotoGallery`: ein Hauptbild mit gerundeten tatsächlichen Bildkanten, vollständig sichtbar mit `BoxFit.contain`, Thumbnail-Auswahl bei mehreren Fotos und vergrößerbare Ansicht. Keine automatische Freistellung: diese könnte botanische Merkmale entfernen. Transparente Originalbilder werden unverändert unterstützt. Urheber/Lizenz und Kennzeichnung automatisch zugeordneter, nicht redaktionell geprüfter Fotos bleiben sichtbar; vollständige Quellen-/Lizenz-URLs ausklappbar.

Eine lokale 32×32-Farbstichprobe des angezeigten Fotos bestimmt nur die hellen dekorativen Flächen. Lesetext bleibt dunkel, nicht automatisch eingefärbt. Maximal 64 Paletten im Speicher; Listener werden entfernt, asynchrone Ergebnisse gegen Szenenwechsel gesichert. Ausfälle der Farbanalyse fallen auf die neutrale Salbeipalette zurück. Kein Upload, keine externe Design-API und keine Bildmanipulation.

`lib/dev/card_preview.dart` ist eine getrennte Designvorschau mit veröffentlichten öffentlichen Daten vom lokalen Backend, nicht im Produkt-Router. `?plant=<id>`, `?photos=none`, `?scale=2`. Wegen der bestehenden CORS-Konfiguration über `http://127.0.0.1:3000` ausliefern. Kein Aufweichen der API-CORS-Regeln.

## Bildabruf und Mehrfach-Galerie (Stand 29.09.2026, MEDIA-10)

`node tools/prefetch-plant-photos.mjs` liest die Pflanzenliste aus dem aktiven öffentlichen Änderungsfeed (ohne Cursor), ruft jedes Pflanzenprofil ab und lädt jede gleiche-Origin-Bildantwort vollständig. Der Backend-Cache wird dadurch gefüllt. Keine CMS-Medien überschrieben, keine privaten Daten berührt. Sequentieller Abruf, IPv4-Loopback.

**Backend:** Ein Pflanzenprofil liefert bis zu 10 Fotos, redaktionelle CMS-Medien zuerst, danach automatisch zugeordnete (`ContentService.getPlant`, `WikimediaPhotoSource.findMany`). Quellen: das bisherige Wikimedia-/iNaturalist-Einzelfoto plus weitere iNaturalist-Fotos des exakten Taxons (`lookupInaturalistPhotos`: kuratierte `taxon_photos` aus `GET /v1/taxa/{id}`, nur bei weniger als zwei Kandidaten kleine Beobachtungsliste). Jedes Bild hat eigene ID, Urheber, Lizenz und Quelle und wird über `GET /api/v1/plants/{id}/photo?photoId=…` gleicher Origin ausgeliefert. `photoId` ist im Vertrag (`contracts/api.yaml`) dokumentiert; unbekannte ID → 404, zu lange/mehrfache ID oder unbekannter Query-Parameter → 400.

**Fehler, der dabei auffiel und behoben wurde:** Die erste Fassung fragte iNaturalist-Beobachtungen mit `per_page=30` ab. Die Antwort ist je nach Art > 1 MiB (z. B. Anemone nemorosa 1,18 MB) und überschreitet das Antwortlimit von `getJson` (`PHOTO_SOURCE_TOO_LARGE`). Die Zusatzfotos wurden dann still verworfen und die verkürzte Galerie 24 Stunden gecacht; elf Pflanzen hatten deshalb nur ein Bild. Jetzt kommen die Zusatzfotos aus dem kleinen Taxon-Datensatz (~63 KB); eine durch Anbieterfehler verkürzte Galerie wird nur 5 Minuten gecacht.

**Flutter:** `PlantPhotoGallery` zeigt Zähler „n / N“, Thumbnail-Leiste, Vergrößerung und horizontales Wischen (zyklisch). Die Kartenfarbe bleibt am ersten Bild verankert und flackert beim Blättern nicht.

**Ergebnis Abruf (29.09., nach dem Fix):** 30 Pflanzen geprüft, **28 mit Fotos, 251 Bilder, alle 251 abrufbar**, 16 Pflanzen mit 10 Bildern, Minimum 3 (Werte: 10× 16, 9× 4, 8× 4, 7× 2, 6× 1, 3× 1). Bericht unter `artifacts/content/plant-photo-coverage.json`. Ohne Foto bleiben *Wiesen-Margerite* (`Leucanthemum vulgare agg.`) und *Gewöhnliche Schafgarbe* (`Achillea millefolium agg.`): iNaturalist kennt den Namen mit Zusatz „agg." nicht, und eine stillschweigende Zuordnung zur Einzelart wäre eine unbelegte Taxonannahme. Redaktionelle Entscheidung oder CMS-Bild nötig.

**Lizenzen – offene Abnahme, nicht erledigt:** Lizenzverteilung der 251 Bilder: cc-by-nc 128, „Unverified (internal testing)“ 34 (iNaturalist liefert dort keine Lizenz, also vermutlich alle Rechte vorbehalten), cc-by 29, cc-by-sa 25, cc-by-nc-sa 19, cc-by-nc-nd 7, pd 4, cc0 3, cc-by-nd 2. Alle sind als „automatisch zugeordnet, botanisch nicht redaktionell geprüft“ gekennzeichnet. Für eine öffentliche Veröffentlichung sind die 34 Bilder ohne Lizenz und die NC/ND-Bilder rechtlich nicht freigegeben (`AGENT.md`: ungeklärte Bildrechte sind eine Stop-Bedingung; siehe CONTENT-12). Für die interne Demo genügt es, dafür nicht. Empfehlung: vor jeder Weitergabe Bilder ohne Lizenz herausfiltern oder durch CMS-Bilder ersetzen. Geräteseitige Offline-Bilddateien bleiben offen (Bilder werden weiter aus dem Backend geladen). Anbieter-Limits (Wikimedia 429) bleiben ein möglicher Ausfallfall.

## Lernmodus

Separater Agent implementierte den disjunkten Teil in eigenem Worktree; Main reviewte und integrierte `9bf2edb`. Pfad `/ecosystems/:ecosystemId/practice`, Einstieg „Karteikarten üben“ in der Ökosystemansicht.

Auf ausdrücklichen Nutzerwunsch inzwischen **alle veröffentlichten Pflanzen der Ökosystem-Level**, unabhängig von deren Freischaltung. IDs werden dedupliziert; auch Karten ohne Merkmalsnotizen bleiben sichtbar. Einstieg „Alle Pflanzenkarten · endlos lernen“ ist unabhängig vom Levelstatus aktiv. Vorherige/nächste Karte sind jederzeit erreichbar; Fragen können beim reinen Anschauen übersprungen werden.

Nach der letzten Karte beginnt automatisch die nächste Runde mit der ersten Karte. Keine Endseite oder begrenzte Wiederholungsmenge. Der Speicher bleibt auf die vorhandene Pflanzenliste und höchstens eine Bewertung je Pflanze der laufenden Runde begrenzt. Erinnerungsfragen wechseln pro Runde durch vorhandene vollständige Merkmalsabschnitte; ohne solche Abschnitte dient die Beschreibung als Erinnerungshilfe, ohne Beschreibung bleibt reines Blättern möglich. Aufdecken zeigt unveränderten Originaltext; „Gewusst“ / „Noch üben“ bleibt Selbsteinschätzung. Ein Doppeltipp auf die Bewertung darf nicht zwei Karten weiterschalten. Sitzung wird beim Verlassen verworfen. Keine Quizlösungsschlüssel, automatische Richtig/Falsch-Bewertung, XP oder Spiel-Freischaltungen.

## Nachweise / offene Abnahme

- `flutter analyze --no-pub lib`, Linux-Releasebuild und Web-Releasebuild erfolgreich; `git diff --check` sauber.
- Karten mit echten öffentlichen Rotbuche-/Alpenrose-Daten und Backend-Fotos auf Desktop und Mobilformat visuell kontrolliert. Vergrößerung öffnet sich. Fehlendes Foto und 200-%-Schrift im schmalen Layout geprüft.
- Screenshots unter `artifacts/3d/plant-card-*.png`.
- Historischer Nachweis vor der Endlos-Erweiterung: regulär angemeldeter Ablauf mit zwei freigeschalteten Alpenpflanzen bis Zusammenfassung/Wiederholung geprüft. Die Screenshots `practice-card-review.png`, `practice-recall-review.png`, `practice-summary-review.png` zeigen diesen älteren Stand, nicht mehr den aktuellen Endlosmodus.
- Aktueller Endlosmodus regulär angemeldet geprüft: Alpen zeigt alle 10 Pflanzen statt der zwei zuvor freigeschalteten. Zehn reale Weiter-Klicks führen zu „Runde 2 · Karte 1 von 10“; Zurück führt zur zehnten Karte. Mobilansicht 390×844 visuell kontrolliert. Screenshots `practice-unlimited-review.png` und `practice-unlimited-mobile.png`. Analyse, Web- und Linux-Releasebuild erfolgreich; keine neuen Tests geschrieben.
- Mehrfach-Galerie (29.09.): Web-Vorschau mit Chromium geprüft, Rotbuche 1/10 → Wischen links 2/10 → dreimal rechts von 3/10 zyklisch 10/10, Kartenfarbe stabil. Screenshot `artifacts/3d/plant-gallery-swipe-2of10.png`. `flutter analyze lib` und Formatprüfung sauber, generierter Client 247 Tests grün, Redocly-Lint und `validate-api-contract.mjs` grün. Live-Aufrufe des Foto-Endpunkts: gültige `photoId` 200 image/jpeg, unbekannte 404, überlang/doppelt/fremder Parameter 400. Keine neuen Tests geschrieben.
- Nutzer-Abnahme der Gestaltung, Lizenzfreigabe der Fotos, Wischen auf echten Touch-Geräten, native Mobilgeräte und vollständiger Lern-/Quiz-/Herbarium-Spielablauf bleiben offen.

Der einfache Python-Dateiserver unterstützte `/auth/callback` nicht (404). Für die reguläre angemeldete Web-Abnahme gibt es deshalb `python tools/serve-flutter-review.py --directory apps/flutter/build/demo-review`: IPv4-Port 3000, Index-Fallback ausschließlich für beide Auth-Rückleitungen, keine Request-URL-Logs. Keine Änderung an Keycloak oder den bestehenden CORS-Regeln. Entwicklungswerkzeug, kein Produktionsserver.
