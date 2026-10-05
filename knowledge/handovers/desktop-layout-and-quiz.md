# Desktop-Ansichten und bestätigbare Quizantworten

Stand: 05.10.2026. Nutzerauftrag DESIGN-11 / FA020–FA026, NFA018.

## Umsetzung

- Ökosystem-Galerie: zentrierte responsive Karten in ein bis drei Spalten.
- 3D-Lernwelt: maximal 920 × 760 logische Pixel, weiterhin Kapitel, Slider,
  Ziehen und jetzt vertikale Mausradnavigation.
- Ökosystem-Vitrine: Galerie-Sockel und Glasrahmen, maximal 560 Pixel breit.
  Texturen höchstens 1024 Pixel pro Kante, Pixeldichte höchstens 2 und LRU-Cache
  mit zwölf Einträgen statt unbeschränkter Desktop-/HiDPI-Aufblähung.
- Charakterauswahl: maximal 1100 Pixel, Desktop-Vorschau neben neun Figuren;
  schmale Fenster und große Schrift verwenden eine scrollbar angeordnete
  Variante. Material-Auswahl ist tastaturbedienbar, die Beschreibung ungekürzt.
- Herbarium: begrenzte Museumsansicht, ruhiger Regalhintergrund und maximal
  fünf größere Sammlungsfächer je Reihe; auf Mobilgeräten weiter zwei Spalten,
  soweit Textgröße und Platz reichen.
- Quiz: maximal 760 Pixel breit; die vorangestellte Pflanzenlektion maximal
  1040 Pixel. Auswahl bleibt lokal und änderbar bis „Weiter“ bzw.
  „Level abschließen“. Entwürfe erzeugen keine Lernereignisse.

Erst die Bestätigung speichert eine Antwort und erzeugt ein Lernereignis.
Die korrekte Bewertung erfolgt unverändert ausschließlich serverseitig beim
Levelabschluss. Eine schon begonnene, noch nicht beantwortete Abschlussanfrage
wird mit identischen Antworten und bestehendem Idempotenzschlüssel wiederholt;
ihre Antworten sind nicht mehr editierbar. Entwürfe vor der Bestätigung werden
nicht dauerhaft gespeichert. Beim Wiederaufnehmen alter Sitzungen kann die
aktuelle Antwort vor einer erneuten Bestätigung korrigiert werden; ältere
bestätigte Fragen bleiben unverändert.

## Prüfung und Grenzen

Keine neuen Testdateien geschrieben. Gezielte Analyse der geänderten Module
fehlerfrei; 19 vorhandene Lernfluss-/Charakter-/Weltbeleuchtungstests grün.
Die vorhandene vollständige lokale Web-Kernreise bestand mit echtem Keycloak
und Mock-PlantNet (zwei Tests). Der erste kalte Headless-Lauf lief beim Start
in einen Timeout; der Wiederholungslauf war grün. Separate Browserprüfung:
1440 × 1000 sowie 390 × 844, wechselbare Antworten vor Bestätigung, keine
Eventübertragung beim Auswählen und abschließender Serverscore 100 %.

Bekannte nicht geänderte Alt-Testprobleme: drei Katalogtests erwarten noch
`LevelGateCard` statt der vorhandenen 3D-Stationen; ein Herbarium-Detailtest
sucht ein nicht vorhandenes editierbares Textfeld (`herbarium_ui_test.dart:130`).
Diese Tests wurden nicht umgeschrieben; keine vollständige Suite als grün
ausgewiesen. Die globale Design-Abnahme DESIGN-09 bleibt offen.

Der lokale Web-Container verwendet den neu gebauten Stand unter
`http://127.0.0.1:3000`. Keine Produktionsausrollung in diesem Änderungsschritt.
Vorhandene Datenbanken und Zugangsdaten blieben erhalten. Synthetische lokale
Prüfkonten wurden jeweils exakt entfernt; private Produktionsdaten unberührt.
