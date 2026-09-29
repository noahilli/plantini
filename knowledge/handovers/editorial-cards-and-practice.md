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

## Vollständiger Bildabruf: noch nicht vollständige Bildabdeckung

`node tools/prefetch-plant-photos.mjs` liest die Pflanzenliste aus dem aktiven öffentlichen Änderungsfeed (ohne Cursor), ruft jedes Pflanzenprofil ab und lädt jede gleiche-Origin-Bildantwort vollständig. Der vorhandene Backend-Cache wird dadurch gefüllt. Keine CMS-Medien überschrieben, keine privaten Daten berührt. Sequentieller Abruf, IPv4-Loopback; fremde Medienhosts werden nicht ungeprüft nachgeladen.

Ergebnis: **30 geprüft, 6 tatsächlich bebildert, 24 ohne geliefertes Foto**. Bericht mit einzelnen Pflanzen, Status und Lizenzmetadaten unter `artifacts/content/plant-photo-coverage.json`. Eine gezielte Anbieterdiagnose für Quercus robur ergab `PHOTO_SOURCE_HTTP_429`, gefolgt von der vorgesehenen Abkühlpause. Ein fehlendes API-Bild beweist nicht, dass es grundsätzlich kein geeignetes Foto gibt. Keine aggressiven Wiederholungen oder Umgehung. Nach Abklingen der Anbietersperre erneut abrufen; alternativ redaktionell lizenzierte Bilder im CMS hinterlegen. Geräteseitige Offline-Bilddateien weiterhin offen.

## Lernmodus

Separater Agent implementierte den disjunkten Teil in eigenem Worktree; Main reviewte und integrierte `9bf2edb`. Pfad `/ecosystems/:ecosystemId/practice`, Einstieg „Karteikarten üben“ in der Ökosystemansicht.

Veröffentlichte Pflanzen freigeschalteter Level werden dedupliziert geladen. Pro Pflanze Karte ansehen, dann kurze Erinnerungsfrage aus der Überschrift des ersten vollständigen Merkmalsabschnitts. Aufdecken zeigt den unveränderten Originaltext, „Gewusst“ / „Noch üben“ sind ausdrücklich Selbsteinschätzung. Abschluss zählt diese Angaben; schwierige oder alle Karten wiederholbar. Ein Doppeltipp darf nicht zwei Karten weiterschalten. Sitzung wird beim Verlassen verworfen. Keine Quizlösungsschlüssel an Client, keine automatische Richtig/Falsch-Bewertung, keine Punkte oder vorgetäuschten Levelabschlüsse.

## Nachweise / offene Abnahme

- `flutter analyze --no-pub lib`, Linux-Releasebuild und Web-Releasebuild erfolgreich; `git diff --check` sauber.
- Karten mit echten öffentlichen Rotbuche-/Alpenrose-Daten und Backend-Fotos auf Desktop und Mobilformat visuell kontrolliert. Vergrößerung öffnet sich. Fehlendes Foto und 200-%-Schrift im schmalen Layout geprüft.
- Screenshots unter `artifacts/3d/plant-card-*.png`.
- Regulär angemeldete Web-Laufzeitprüfung erfolgreich: Login über Keycloak → Alpen-Übungsmodus mit zwei tatsächlich freigeschalteten Pflanzen → Karte verdecken → Text aufdecken → einmal „Noch üben“, einmal „Gewusst“ → Zusammenfassung „1 von 2“ → Wiederholungsrunde mit genau einer Pflanze. Keine Lern-/Abschlussmutation. Screenshots `practice-card-review.png`, `practice-recall-review.png`, `practice-summary-review.png`. Dies ist gezielte Bedienprüfung, keine vollständige Kernreise und keine neu geschriebene Testsuite.
- Nutzer-Abnahme der Gestaltung, komplette Bildabdeckung, native Mobilgeräte und vollständiger Lern-/Quiz-/Herbarium-Spielablauf bleiben offen.

Der einfache Python-Dateiserver unterstützte `/auth/callback` nicht (404). Für die reguläre angemeldete Web-Abnahme gibt es deshalb `python tools/serve-flutter-review.py --directory apps/flutter/build/demo-review`: IPv4-Port 3000, Index-Fallback ausschließlich für beide Auth-Rückleitungen, keine Request-URL-Logs. Keine Änderung an Keycloak oder den bestehenden CORS-Regeln. Entwicklungswerkzeug, kein Produktionsserver.
