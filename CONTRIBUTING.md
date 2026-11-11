# Mitmachen bei Plantini

Schön, dass du helfen willst. Plantini ist ein kleines, ehrenamtliches Projekt in einem frühen Stand. Diese Seite erklärt kurz, wie ein Beitrag aussehen soll. Ausführlich steht alles im Handbuch unter `docs-site/docs/mitmachen/`.

## Bevor du anfängst

- Lies `README.md` und, für größere Änderungen, `AGENT.md` (Grenzen des Systems, Befehle, Fallstricke).
- Such dir ein offenes Issue oder eine Aufgabe aus `todos.md`, oder eröffne erst ein Issue und beschreib, was du vorhast. Das spart beiden Seiten Arbeit.
- Sicherheitslücken **nicht** als Issue melden, sondern wie in `SECURITY.md` beschrieben.
- Für den Umgang miteinander gilt `CODE_OF_CONDUCT.md`.

## Lizenz und Herkunft deines Beitrags

Mit einem Beitrag stellst du ihn unter die Lizenzen des Projekts: Code unter **AGPL-3.0-or-later**, Lerninhalte (Texte, Quizfragen, 3D-Modelle, Handbuch) unter **CC BY-SA 4.0** (siehe `NOTICE`). Du behältst das Urheberrecht an deinem Beitrag.

Bestätige mit jedem Commit, dass du den Beitrag einreichen darfst (Developer Certificate of Origin, <https://developercertificate.org>). Das geht mit `git commit -s`; es fügt diese Zeile an:

```
Signed-off-by: Vorname Nachname <mail@example.org>
```

Fotos, Texte und Modelle von Dritten nur mit geklärter, kompatibler Lizenz und vollständigen Angaben (Urheber, Quelle, Lizenz, Alt-Text). Keine ungeprüften KI-generierten Fachinhalte.

## Lokal starten

```sh
tools/scripts/start-local-demo.sh          # frischer Stack, App unter http://127.0.0.1:3000
```

Voraussetzungen und Einzelschritte: `docs-site/docs/mitmachen/setup.md`. Alle Prüfungen lokal: `tools/scripts/ci-check.sh`.

## Branches

`<art>/<ID>-<kurzname>`, zum Beispiel `change/AUTH-06-registration-e2e` oder `bugfix/APP-10-image-cache`. Die ID ist die Aufgaben-ID aus `todos.md` oder die Issue-Nummer (`bugfix/123-login-loop`).

## Commit-Nachrichten

```
<präfix> (<ID>) <beschreibung>

<optional: warum, nicht was – in ganzen Sätzen>

Signed-off-by: Vorname Nachname <mail@example.org>
```

- **Präfix:** `change` (Normalfall: neue Funktion oder Änderung), `bugfix`, `test`, `docs`, `wip` (Zwischenstand, nicht für `main`). `featre` steht in älteren Commits für frühe Features (die Schreibweise ist historisch so festgelegt); für neue Arbeit `change` verwenden.
- **ID:** Aufgaben-ID aus `todos.md` (`AUTH-06`, `MEDIA-10` …) oder Issue-Nummer (`#123`).
- **Beschreibung:** Englisch, klein geschrieben, ohne Punkt am Ende, Imperativ oder knappe Zusammenfassung.
- Keine Werkzeug- oder Co-Author-Zeilen von KI-Assistenten.

Beispiele aus der Historie:

```
change (WORLD-11) floating models instead of the glass case, 30 frames per second
bugfix (QUIZ-06) confirm editable answer drafts only on next
docs (DOCS-01) add MkDocs handbook for contributors, operations and moderation
```

Eine Vorlage liegt in `.gitmessage`; aktivieren mit `git config commit.template .gitmessage`.

## Pull Requests

- Ein Thema pro Pull Request, möglichst klein.
- Die Vorlage (`.github/pull_request_template.md`) füllt sich beim Öffnen automatisch aus; bitte die Prüfliste ehrlich abhaken.
- Änderungen an `contracts/api.yaml` immer zusammen mit neu erzeugtem Client (`tools/scripts/generate-api-client.sh`), Tests und Doku.
- Kein Code, der Secrets, echte Nutzerdaten oder exakte Fundorte enthält – auch nicht in Tests oder Screenshots.
- Ein Merge entscheidet der Maintainer. Ein Merge heißt nicht, dass die Änderung sofort ausgerollt wird.

## Issues

Es gibt Vorlagen für **Fehler**, **Wünsche** und **Inhalte** (Art fehlt, Fehler im Steckbrief, Foto mit falscher Zuordnung). Bitte keine personenbezogenen Daten, Passwörter oder genauen Fundorte in Issues schreiben.
