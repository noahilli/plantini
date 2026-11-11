# Spielbare Plantini-Reise – Entwicklungsstand 2026-09-07

> Fortsetzung vom 22. September: siehe `lesson-authoring.md`. Neue strukturierte
> Steckbriefe, Missionsdarstellung und CMS-Entwurfs-Generator sind ergänzt;
> Demo-Release `2026.09.22-de.1`. Dieser ältere Handoff beschreibt die Basis.
> Die hier unten erwähnte Backend-Assertion wurde bereits mit `933b02e` korrigiert;
> die übrigen Test-/Abnahmegrenzen bleiben bestehen.

## Auftrag und Umsetzung

Die ausdrückliche neue Nutzervorgabe ersetzt die frühere Sammelpflicht je Level.
Die drei Demo-Ökosysteme erhalten jeweils 30 sequenzielle Level mit einer kurzen
Pflanzenlektion, drei Fragen und einem Stern nach serverseitig bestätigtem
Bestehen. Zwei von drei richtigen Antworten reichen. Wiederholen verbraucht
keine Sterne und verschlechtert einen zuvor erreichten Levelabschluss nicht.

Die vorhandenen zehn Pflanzen und ihre jeweils drei Fragen je Ökosystem werden
in den Runden Kennenlernen, Wiederholen und Festigen verwendet. Insgesamt sind
das 90 spielbare Level und 270 versionierte Quizinstanzen, keine 270 neu
recherchierten Fragen. Wiederholungen sind im Lernziel ausdrücklich benannt.

Die Weltkarte zeigt einen gewundenen Pfad mit Wald-, Wiesen- oder Bergkulisse,
nummerierten Stationen, aktuellem Wanderer, Sternen und gesperrten Stationen.
Zehn Level bilden einen Abschnitt; Abschnittstasten erlauben Vor- und Zurück.
Der Spielbutton führt zum nächsten offenen Level, frühere Level sind wiederholbar.
Die Level-Vorschau öffnet die Pflanzeneinleitung; nach jeder Antwort geht es
ausdrücklich mit Weiter zur nächsten Frage. Die letzte Antwort führt zur
serverseitigen Auswertung und danach zur Wiederholung, nächsten Station oder Karte.
Die Auswahlrückmeldung behauptet keine lokale Richtig-/Falsch-Bewertung.

Die drei vorgegebenen Zielarten stehen nur in der Abschlussregel der letzten
Station. Sie können vor, während oder nach den Quizleveln fotografiert und im
Herbarium bestätigt werden. Das separate authentifizierte GET
`/api/v1/ecosystems/{id}/progress` entscheidet über die Ökosystem-Trophäe.
Auch das letzte Quiz kann ohne die Funde bestanden werden. Die Zielgläser sind
jederzeit über Sammelziel und nochmals am Kartenende erreichbar. Fehlender
Online-Abgleich wird nicht als bestätigter Ökosystem-Abschluss dargestellt.

Das Herbarium zeigt alle veröffentlichten Arten in Regalen nach Ökosystem.
Die Gläser sind eigene skalierbare Vektorzeichnungen mit Korken, Reflexionen und
stilisierten Pflanzen; keine 3D-Dateien oder botanisch exakten Bestimmungsmodelle.
Ein passender bestätigter Fund füllt das Glas; mehrere Funde derselben Art ergeben
ein Glas. Leere Gläser öffnen die Bestimmung dieser Zielart. Persönliche Fotos,
Notizen, Suche, Filter und Löschung bleiben im Bereich Beobachtungen erhalten.
Die Sammlung lädt alle Beobachtungsseiten, nicht nur die neuesten 20 Funde.

## Integration und Daten

Backend/API: siehe `game-backend.md`. Release `2026.09.07-de.1` wird durch den
bestehenden Opt-in-Bootstrap `PLATFORM_SEED_DEMO_CONTENT=true` importiert. Für
die neuen Level müssen Backend und App mit diesem Entwicklungsstand neu gebaut
und gestartet werden. Die lokale Datenbank muss dafür nicht gelöscht werden.
Alte Demo-Level/Fragen werden nur aus der Veröffentlichung zurückgezogen;
Beobachtungen und alte Versuche bleiben gespeichert. Frühere Drei-Level-Versuche
werden nicht als dreißig neue Level angerechnet. Die Demo-Migration ist ein
Bootstrap-Vorgang und keine atomare Online-Publikation.

Native Katalogabfragen holen Ökosysteme und Level online vor dem lokalen
Fallback, damit ein neuer Inhaltsrelease oder frisch freigeschaltetes Level
nicht vom alten Isar-Stand verdeckt wird. Der endgültige Ökosystem-Abschluss wird
nicht aus einem lokalen Cache behauptet. Abschlusswiederholungen verwenden
dieselbe Idempotenzkennung, falls eine erfolgreiche Serverantwort verloren geht.

## Nachweise und WIP

- `flutter analyze --no-pub lib`: ohne Befund.
- Web- und Linux-Release-Build wurden erstellt; kein Live-Stack/GUI-Durchlauf
  dieses gesamten integrierten Ablaufs in diesem Schritt.
- Der Backend-Agent hatte vor dem Test-Stopp Prüfungen ausgeführt; dessen
  Ergebnisse und Grenzen stehen im Backend-Handoff. Sie sind kein Nachweis für
  den nachträglich integrierten Gesamtstand.
- Auf ausdrücklichen Nutzerwunsch wurden neue Testentwicklung und weitere
  Testläufe gestoppt. Bereits entstandene Tests bleiben als separater
  `wip: tests ecosystem journeys and specimen bottles`-Commit erhalten.
- Bekannte WIP-Stellen: `game-journeys.test.js` erwartet noch eine Beschreibung
  im Lernziel; dieses enthält jetzt nur den Hinweis zur jeweiligen Runde.
  `game05_herbarium_bottles_test.dart` verwendet in der Größenprüfung noch
  `await tester.view.reset()` (void). Bestehende Karten-/Quiz-/E2E-Assertions
  beziehen sich teilweise auf die alte Sammelpflicht und Darstellung.
  Ein vollständiges `flutter analyze` inklusive Tests ist deshalb nicht grün.
- Vorbestehende fremde Änderungen an `offline_herbarium_repository.dart`,
  `herbarium_ui_test.dart`, `catalog_widget_test.dart`, `field_widget_test.dart`
  und das Designreferenzpaket wurden nicht in die eigenen Commits aufgenommen.

## Ownership

Backend-Agent: isolierter Worktree `/tmp/plantini-game-backend`; Quellcode und
vorhandene Tests wurden nach Review getrennt übernommen. Quiz- und Herbarium-
Agents wurden durch Nutzungslimits gestoppt; ihre erhaltenen Änderungen aus
`/tmp/plantini-game-quiz` und `/tmp/plantini-game-herbarium` wurden vom Orchestrator
integriert. Orchestrator: Karte, Level-Vorschau, Fortschrittsadapter, Integration,
kleine Ablaufkorrekturen und Dokumentation. Keine Veröffentlichung oder Push.

## Commits im Haupt-Checkout

- `c9c9a16` – `wip: tests ecosystem journeys and specimen bottles`
- `4682bba` – `change (GAME-03) build thirty-level ecosystem journeys`
- `af8c20c` – `change (GAME-04) add playable world maps and specimen bottles`
