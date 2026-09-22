# Steckbriefe und generierte Lernpfade – 22. September 2026

## Ziel und Neubewertung

Der Nutzer priorisiert spielerische Level und fertige, lesbare Pflanzenlektionen
gleichrangig. Vor jeder Fragerunde steht ein Steckbrief, der die Antworten
vermittelt. Vorbild ist die didaktische Gliederung von
[BANini25, Universität Ulm](https://www.uni-ulm.de/einrichtungen/garten/gruenes-klassenzimmer/banini-artenkenntnis/banini-arten-datenbank/banini25/):
Art/Familie, Erkennen, Standort, Verwechslungen und Naturbeziehungen.
Keine Übernahme von Bildern oder vollständigen Fremdtexten. Bestehende Artenauswahl
bleibt erhalten, BANini25 deckt insbesondere die Alpenarten nicht vollständig ab.

## Implementierter Stand

- Drei Ökosystem-Beschreibungen als Expedition; 30 Arten mit jeweils drei
  eigenen Lernkarten, an den 90 bestehenden Quizfragen ausgerichtet.
- 30 Level pro Ökosystem bleiben drei Runden über zehn Arten. Entdeckerpfad,
  Spurensuche und Forscherfinale markieren die Missionen. Wiederholungen werden
  ausdrücklich benannt; Antwortpositionen wechseln deterministisch.
- Feldnotizbuch mit Familie, Beschreibung, Karten, Sicherheit und Quellen;
  Kapitel-/Sternstand auf der Karte. Finale weiterhin erst nach allen Leveln
  und drei passenden fotografischen Herbarium-Funden, auch früh gesammelten.
- Additives API-Feld `Plant.profileCards: [{heading, text}]`, offline in Web und
  Isar gespeichert. Alte Antworten ohne Feld bleiben lesbar. Keine Lösungs-IDs
  in dieser Projektion; CMS-interne `learningCards` sind private.
- Demo-Inhaltsrelease `2026.09.22-de.1`; Pflanzen-, Level- und Quiz-UUIDs der
  September-Reise bleiben erhalten. Vorhandene Funde werden nicht gelöscht.
  Noch laufende Versuche einer alten Inhaltsversion sind kein Beleg für einen
  erfolgreichen Versionswechsel; dieser muss in der App abgenommen werden.

## Wie Redaktion ohne Dateiupload funktioniert

Die Basis ist **strukturierter Inhalt, nicht ein hochgeladenes Layout und nicht
ungeprüfter KI-Text**. Flutter rendert die Darstellung aus dem API-Modell.
Strapi verwendet seine normalen Component-/Content-Manager-Formulare.

1. Unter **Plant** die Beschreibung, Sicherheitshinweise und Quellen pflegen.
   Unter `learningCards` drei Komponenten **Lernkarte mit Quiz** ausfüllen:
   `heading`, `text`, `question`, `correctAnswer`, `wrongAnswer1` bis `3`.
2. Jede Karte vermittelt genau die Antwort ihrer Frage. Der Compiler fordert
   vier verschiedene Antworten und den Lösungstext im Lerntext (Großschreibung
   und mehrfacher Leerraum sind irrelevant). Das ist eine formale Konsistenzregel,
   keine automatische fachliche Prüfung.
3. Unter **Lernpfad-Generator** Titel, ASCII-Slug, Release-Version und Ökosystem
   setzen. Zehn verschiedene Pflanzen über **Pflanzenstation** anordnen; genau
   drei als `collectionTarget` markieren. Die bestehenden Ökosystem-/Pflanzen-
   Pflichtfelder inklusive öffentlicher UUID müssen vorhanden sein.
4. `generateDrafts` aktivieren und speichern. Nach Neuladen steht in
   `generationReport`, ob 30 Level und 90 Quizdatensätze erzeugt wurden.
   `generationState` muss `ready` sein, nicht `generating` oder `failed`.
5. Generierte Einträge bleiben unveröffentlicht, Quizstatus `draft`. Erst
   botanisch/redaktionell prüfen. Der Generator aktiviert **kein** Release und
   veröffentlicht keine Einträge. Ein atomarer Publish-Assistent bleibt offen.

Die Antwortoptionen und Ablenkantworten werden bewusst fachlich vorgegeben.
Der Compiler erzeugt IDs, Reihenfolge, Freischaltungen, Fragedatensätze und
Abschlussregeln. Er erfindet keine Fakten und benötigt keinen KI-Schlüssel.
Eine spätere KI-Unterstützung darf nur Vorschläge als Entwürfe liefern.

## Schutz vor Überschreiben und Grenzen

- Kein öffentlicher CRUD-Router für den Lernpfad-Generator; Bedienung über
  vorhandene Strapi-Admin-Rechte. Kein zusätzlicher ungeschützter Generator-Endpunkt.
- Inhaltssignatur erzeugt reproduzierbare IDs. Identische Generierung lässt
  vorhandene Datensätze unangetastet; geänderte Eingaben ergeben neue Entwürfe.
  Alte Entwurfsserien werden nicht automatisch gelöscht oder veröffentlicht.
  `generatedFromBlueprint` und `generationFingerprint` an Leveln/Quizzes erlauben
  ihre eindeutige Zuordnung und Filterung in der Redaktion.
- Validierung aller Stationen vor Schreibbeginn. Ein Datenbankfehler kann
  Teilentwürfe hinterlassen, aber keine veröffentlichten Level. Erneut speichern
  setzt die Generierung fort; Meldung beachten. Kein transaktionaler Release.
  Die Serie wird erst nach vollständiger Erzeugung `ready`. Publizieren eines
  generierten Levels wird vorab blockiert, wenn die aktuelle Serie nicht fertig
  ist oder Ökosystem, Pflanzen oder eine der drei Pflichtfragen nicht fachlich
  freigegeben/veröffentlicht bzw. nicht in derselben Inhaltsversion vorliegen.
  Beziehungen zunächst als Entwurf speichern, erst danach veröffentlichen.
- Nach Veröffentlichung eines CMS-Steckbriefs nicht unkontrolliert die zugrunde
  liegenden Fakten ändern: Strapi-v4-Pflanzen sind noch keine unveränderlichen
  Inhaltssnapshots. Kopie/neue Revision und fachlicher Review erforderlich.
- Bei manueller Veröffentlichung mehrerer generierter Serien im selben
  Ökosystem würden deren Level gemeinsam erscheinen. Deshalb keine direkte
  Massenveröffentlichung; Serienauswahl/Archivierung gehört zum offenen Publish-
  Assistenten (CMS-10). Der Generator allein ist noch kein Redaktions-Abnahmebeleg.

## Verbleibende Prioritäten

1. Neue UI und Cache-Upgrade live abnehmen; Gesamtfluss bis Ökosystem-Finale.
2. Direkte Quellen je Art prüfen und fragwürdige Referenzen ersetzen; siehe
   `plant-profiles-content.md`. Ausgefüllte Lektionen sind nicht fachlich freigegeben.
3. Redaktionsvorschau, Versionsauswahl und atomare Freigabe ohne Dateiupload.
4. Zusätzliche geprüfte Fakten für tatsächlich unterschiedliche Vergleichsfragen
   in den späteren Runden; lizenzierte Pflanzenbilder ergänzen.

Neue Tests werden auf ausdrücklichen Nutzerwunsch nicht geschrieben. Bereits
vorhandene WIP-Tests bleiben unberührt. Build-/Schema-Prüfungen ersetzen weder
eine botanische Prüfung noch einen vollständigen Benutzerdurchlauf.

## Entwicklungsprüfungen

- Backend-Lint und Syntaxprüfung erfolgreich; keine neue Testsuite geschrieben.
- Strapi lädt alle neuen Content- und Component-Schemas im vorhandenen Node-20-
  Containerimage. Lokales Strapi-Register war wegen eines bereits fehlenden
  nativen Sharp-Moduls blockiert, daher Prüfung im bestehenden Containerimage.
- Isolierte CMS-Datenbankprüfung in einem wegwerfbaren Container: zehn Pflanzen
  mit Karten gespeichert; Anlegen eines Generator-Eintrags löste den Lifecycle
  aus und erzeugte 30 Level, 90 Quizdatensätze und **null veröffentlichte Level**.
  Nur der CMS-Bootstrap lief; Identifikationsworker waren dabei deaktiviert.
  Das ist ein Persistenznachweis, kein Browser-/Rollen-/Gesamtstack-E2E.
- Nach dem Review zusätzlich im isolierten CMS nachgewiesen: Wiederholung
  derselben Generierung bleibt bei 30/90 Einträgen; vorzeitige Level-
  Veröffentlichung wird abgewiesen; nach Freigabe/Veröffentlichung aller
  Abhängigkeiten lässt sich das Level publizieren. Öffentliche Steckbriefkarten
  enthalten ausschließlich `heading` und `text`.
- Linux-Release mit lokalen IPv4-API/OIDC-Defines erfolgreich gebaut.
- Web-Release ebenfalls erfolgreich, absichtlich separat unter
  `/tmp/plantini-web-review.kIaXZQ` erzeugt, damit die laufende Web-Demo nicht
  während der Arbeit neue Frontend-Dateien gegen den alten Backend-Stand lädt.
- Laufender Demo-Stack und seine Datenbank wurden nicht neu gestartet oder
  gelöscht. Die Backend-Erweiterung ist damit noch nicht im laufenden Demo-
  Container verfügbar; Schema/Seed benötigen einen regulären Neuaufbau.
