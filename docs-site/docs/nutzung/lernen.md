# Lernen

Von der Anmeldung bis zum ersten Stern. Alles in diesem Kapitel ist in wenigen Minuten durchspielbar.

## 1. Anmelden

Die App zeigt einen Startbildschirm mit der Schaltfläche **Anmelden**. Sie öffnet die Anmeldeseite des Identitätsdienstes (Keycloak) im Browser; die App selbst sieht dein Passwort nie. Nach erfolgreicher Anmeldung springt der Browser zurück in die App.

<div class="pl-gallery" markdown>

<figure markdown="span">
  ![Startbildschirm der App mit Schaltfläche Anmelden](../assets/shots/app-login.png){ .pl-phone }
  <figcaption>Startbildschirm.</figcaption>
</figure>

<figure markdown="span">
  ![Anmeldeseite des Identitätsdienstes mit Feldern für Benutzername und Passwort](../assets/shots/app-keycloak-login.png){ .pl-phone }
  <figcaption>Anmeldeseite des Identitätsdienstes.</figcaption>
</figure>

</div>

!!! tip "Schülerkonten"
    Kinder melden sich mit dem Benutzernamen an, den die Lehrperson vergeben hat – eine E-Mail-Adresse ist nicht nötig. Beim ersten Login verlangt Keycloak ein **neues, eigenes Passwort**. Wie Lehrende Konten anlegen, steht im [Lehrendenportal](lehrende.md).

## 2. Forscher:in wählen

Beim ersten Start stellt sich die Frage „Wer erkundet mit dir?“. Es gibt **neun feste Begleitfiguren** (drei Frauen, drei Männer, drei diverse Figuren), alle im Forschungs- und Entdeckerstil. Ein Tipp wählt, **Ich bin …** bestätigt.

![Animation: zwei Figuren werden nacheinander ausgewählt](../assets/anim/anim-charakter.gif){ .pl-phone }

Die Wahl lässt sich später im **Profil** über „Charakter wechseln“ ändern. Wie die Figuren entstehen, beschreibt [Charaktere](../3d/charaktere.md).

## 3. Home und Profil

Auf **Home** siehst du die nächste Expedition mit Sternenstand und einen Vorschlag für den nächsten Schritt („Weiter“). Im **Profil** wählst du deine Figur und die **Tageszeit der Ökosysteme**. Die Kacheln „Sprache“, „Datenschutz“, „Daten exportieren“ und „Hilfe & Feedback“ sind in der aktuellen Version nur Anzeigen ohne Funktion (`_ProfileTile` in `lib/app/router.dart` hat keinen Tipp-Handler).

<div class="pl-gallery" markdown>

<figure markdown="span">
  ![Home mit Expeditionskarte und Kennzahl 0 von 30 Sternen](../assets/shots/app-home.png){ .pl-phone }
  <figcaption>Home: nächster Schritt und Ökosysteme.</figcaption>
</figure>

<figure markdown="span">
  ![Profil mit Figur, Tageszeit-Auswahl und Einstellungs-Kacheln](../assets/shots/app-profil.png){ .pl-phone }
  <figcaption>Profil &amp; Datenschutz.</figcaption>
</figure>

</div>

### Tageszeit der Ökosysteme

Die 3D-Welten wechseln das Licht. Im Profil stehen **Automatisch** (folgt der Uhrzeit des Geräts), **Morgen**, **Mittag**, **Abend** und **Nacht** zur Wahl. Abends und nachts leuchten Hütten und Laternen, auf der Wiese tanzen Glühwürmchen.

![Animation: derselbe Lernpfad im Wechsel Morgen, Mittag, Abend, Nacht](../assets/anim/anim-pfad-tageszeit.gif){ .pl-phone }

Technisch erklärt das [Tageszeit und Licht](../3d/tageszeit-licht.md).

## 4. Ökosystem und Lernpfad

Unter **Lernen** wählst du ein Ökosystem – etwa den Alpenraum. Der **Lernpfad** ist eine 3D-Landkarte mit nummerierten Stationen; gesperrte Level zeigen ein Schloss, das aktuelle Level ist hervorgehoben. Du kannst die Welt ziehen und erkunden. Über „Alle Pflanzenkarten · endlos lernen“ kommst du zu einem freien Übungsmodus.

<div class="pl-gallery" markdown>

<figure markdown="span">
  ![Liste der Ökosysteme mit Alpenraum und Wiese](../assets/shots/app-lernen.png){ .pl-phone }
  <figcaption>Ökosystem wählen.</figcaption>
</figure>

<figure markdown="span">
  ![Lernpfad im Alpenraum mit Stationen, Fluss und Bergen](../assets/shots/app-pfad.png){ .pl-phone }
  <figcaption>Der Lernpfad.</figcaption>
</figure>

<figure markdown="span">
  ![Lerneinheit Level 1 mit den drei Schritten Pflanze entdecken, 3 Fragen spielen, Stern verdienen](../assets/shots/app-level.png){ .pl-phone }
  <figcaption>Level 1: drei Schritte.</figcaption>
</figure>

</div>

## 5. Steckbrief lesen

Jedes Level hat drei Schritte: **Pflanze entdecken** (Steckbrief), **3 Fragen spielen**, **Stern verdienen**. Der Steckbrief zeigt Foto, Merkmale, Standort, Naturschutzhinweise und Quellen. Am Ende steht „Jetzt 3 Fragen beantworten“.

<div class="pl-gallery" markdown>

<figure markdown="span">
  ![Steckbrief Alpen-Edelweiß mit Foto und Merkmalen](../assets/shots/app-steckbrief.png){ .pl-phone }
  <figcaption>Steckbrief mit Foto und Merkmalen.</figcaption>
</figure>

<figure markdown="span">
  ![Ende des Steckbriefs mit Hinweis zu geschützten Pflanzen und Schaltfläche für die Fragen](../assets/shots/app-steckbrief-ende.png){ .pl-phone }
  <figcaption>Ende: Schutzhinweis und Start des Quiz.</figcaption>
</figure>

</div>

## 6. Quiz spielen

Drei Fragen mit je vier Antworten. Du darfst jederzeit zum Steckbrief zurück („Steckbrief nachschlagen“). Ein Level gilt ab **67 %** als bestanden – bei drei Fragen also mit **zwei richtigen Antworten**.

![Animation: Quizfragen werden beantwortet, am Ende das Ergebnis](../assets/anim/anim-quiz.gif){ .pl-phone }

<div class="pl-gallery" markdown>

<figure markdown="span">
  ![Quizfrage mit vier Antwortmöglichkeiten](../assets/shots/app-quiz.png){ .pl-phone }
  <figcaption>Eine Frage, vier Antworten.</figcaption>
</figure>

<figure markdown="span">
  ![Ergebnisseite Fast geschafft mit 33 Prozent und Schaltflächen zum erneuten Versuch](../assets/shots/app-quiz-ergebnis.png){ .pl-phone }
  <figcaption>Nicht bestanden: Steckbrief lesen, erneut versuchen.</figcaption>
</figure>

</div>

!!! note "Wer bewertet?"
    Die Antworten gehen an die Plattform; sie bewertet und schaltet das nächste Level frei. Eine Manipulation in der App ändert daran nichts. Technisch: [Daten- und Prozessflüsse](../architektur/datenfluesse.md) und [Idempotenz](../backend/idempotenz-fehler.md).

## Häufige Fragen

??? question "Ich habe einen Versuch abgebrochen. Ist er weg?"
    Der Versuch gilt als nicht abgeschlossen. Du kannst jederzeit neu starten; mehrere Versuche zählen nicht doppelt.

??? question "Die App hat mich plötzlich abgemeldet, nachdem ich länger offline war."
    Das kann vorkommen: Das Anmelde-Token ist nur kurz gültig und lässt sich ohne Netz nicht erneuern. Gespeicherte Funde bleiben erhalten und werden nach dem erneuten Anmelden weiter synchronisiert. Hintergrund: [Offline-Fähigkeit](../app/offline.md#was-offline-nicht-geht).

??? question "Warum ist ein Level gesperrt?"
    Level werden der Reihe nach freigeschaltet. Das Schloss verschwindet, sobald das Level davor bestanden ist.
