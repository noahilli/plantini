# Plantini: Lernkarten-Inhalt und Quellenübergabe

## Umfang und Aufbau

Die Datei `services/platform/src/api/platform/services/core/content/demo-content.de.json` enthält drei Expeditionen mit jeweils zehn bestehenden Pflanzenprofilen und 30 Quizfragen. Jedes der 30 Profile hat jetzt drei editierbare `learningCards`, jeweils in der Reihenfolge seiner drei vorhandenen Quizze. Alle Arten-/Quiz-Slugs bleiben erhalten; eine falsche Hornklee-Antwort wurde zusammen mit dem Profil korrigiert.

Eine Karte vermittelt einen gezielten Aspekt in kurzen eigenen Sätzen, etwa Rinde, Knospen oder Frucht. Die zunächst schematisch wiederholten Beschreibungen wurden im Review verworfen und alle 90 Kartentexte individuell überarbeitet. Die öffentliche App erhält `heading` und `text`; `question` und die vier Antwortfelder werden im implementierten CMS-Komponentenformular gepflegt und für Quiz-Entwürfe kompiliert.

Die drei Einstiege führen ausdrücklich zu einer geführten Beobachtungsexpedition: Quiz lösen und drei Pflanzenfunde fotografisch dokumentieren. Es geht nie um Sammeln, Ausgraben, Kosten oder das Anfassen geschützter beziehungsweise empfindlicher Pflanzen.

## Didaktische Referenz

Als Strukturimpuls wurde die öffentlich zugängliche Seite [BANini25 der Universität Ulm](https://www.uni-ulm.de/einrichtungen/garten/gruenes-klassenzimmer/banini-artenkenntnis/banini-arten-datenbank/banini25/) herangezogen (Abruf: 2026-09-22). Sie verbindet Artenname und Familie mit Standort, sichtbaren Merkmalen sowie Verwechslungs- oder Beobachtungshinweisen. Genau dieses Muster wurde für die Lernkarten übernommen: erst sehen, dann im Standort einordnen, anschließend vorsichtig vergleichen.

Die Texte und alle Bildideen der Seite wurden nicht übernommen. Die Lernkarten sind eigene deutsche Kurztexte aus dem bereits im Datensatz vorhandenen, quellenverlinkten Profilwissen. Aus BANini25 abgeleitete Formulierungen bleiben weit unter 200 Wörtern insgesamt; übernommen wurde vor allem die didaktische Gliederung, nicht die Darstellung oder der Wortlaut.

## Quellenqualität: Grenzen und Nacharbeit

Die vorhandenen `sources` sind weiterhin Profil-Referenzen, nicht das Ergebnis einer vollständigen heutigen Fachredaktion. Die BANini25-Seite ist ein pädagogisches Vorbild und teilweise eine Art-Referenz, aber keine Vollabdeckung aller 30 Profile.

- Direkt passend auf der BANini25-Seite auffindbar sind unter anderem Rotbuche, Stiel-Eiche, Berg-Ahorn, Hasel und Spitzwegerich. Das bestätigt die gewählte Lernstruktur für diese Beispiele, ersetzt aber keine Einzelprüfung der Datensatzbehauptungen.
- Mehrere Quellen sind generische Einstiegsseiten, etwa Floraweb-Namenssuche oder allgemeine Grünlandseiten. Sie belegen nicht automatisch jede Detailaussage eines einzelnen Profils.
- Der unpassende Eichenartikel bei Winter-Linde und generische Quellen bei Hasel/Wurmfarn wurden durch direkte InfoFlora-Artprofile ersetzt. Andere breit wiederverwendete Quellen, etwa Feuchtwald-/Klimawandel-Artikel bei Esche, müssen weiter pro Aussage überprüft werden.
- Wiederkehrende Aussagen zu Schutzstatus, Verzehr, Giftigkeit, Standort, Phänologie, Artgruppen und Verwechslungsgefahr sind nicht mit dieser Änderung neu verifiziert. Die Karten verstärken keine neuen botanischen Behauptungen, sondern verwenden die bestehenden Angaben.

### Konkret nachgeprüft und korrigiert

- **Hornklee:** Das untere Paar gehört zu den fünf Teilblättchen, es sind nicht
  zwei große Nebenblätter. Beschreibung, Lernkarte, Frage, Antwortoption und
  Erklärung wurden gemeinsam korrigiert. Direkte Referenz:
  [InfoFlora – Lotus corniculatus aggr.](https://www.infoflora.ch/de/flora/lotus-corniculatus-aggr.html)
  und [Artprofil](https://www.infoflora.ch/de/flora/lotus-corniculatus.html).
- **Silberdistel:** Die im vorhandenen Quiz verwendete Angabe „besonders
  geschützt“ für Deutschland wurde im
  [FloraWeb-Artprofil Carlina acaulis](https://www.floraweb.de/php/artenhome.php?name-use-id=1306)
  bestätigt. Daraus folgt keine Freigabe anderer Schutz-/Gefährdungsangaben.

## Redaktionelle Freigabe-Checkliste

1. Jede Art einzeln gegen eine primäre oder institutionelle Fachquelle prüfen; generische Suchseiten durch direkte Artenprofile ersetzen.
2. Den behaupteten Schutzstatus nach Bundesland, Schutzgebiet und aktuellem Recht getrennt prüfen; keine pauschale Übertragung aus einer Region vornehmen.
3. Sicherheits- und Verzehrhinweise durch eine botanisch qualifizierte Redaktion gegenlesen lassen.
4. Bei Aggregaten und schwer trennbaren Gruppen (zum Beispiel Margerite, Schafgarbe, Flockenblumen) die App-Texte ausdrücklich als Lernniveau, nicht als abschließende Feldbestimmung kennzeichnen.
5. Nach jeder Faktenkorrektur Karte, Profilbeschreibung und alle drei zugehörigen Quizfragen zusammen prüfen, damit die Lernprogression konsistent bleibt.
