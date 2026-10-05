# Qualität und Lizenzen

Diese Seite sammelt die Kriterien, nach denen Inhalte für Plantini verfasst und geprüft werden: Steckbriefe, Lernkarten, Quizfragen, Bilder, Sprache und Datenschutz. Am Ende steht eine Checkliste zum Ausdrucken.

!!! note "Was das Studio erzwingt und was nicht"
    Das Studio prüft nur Formales (Pflichtfelder, Längen, `https://`-Quellen, drei Lernkarten, vier Quizantworten). **Ob Aussagen stimmen, ob Quellen sie belegen und ob Bilder rechtlich nutzbar sind, kann keine Software entscheiden.** Das ist Aufgabe von Redaktion und Review. Wo diese Seite eine Regel nennt, steht dabei, ob sie technisch erzwungen ist oder eine redaktionelle Vorgabe.

    Die Regeln sind keine Rechtsberatung. Im Zweifel bei Bildern und Texten: nicht verwenden und nachfragen.

## Pflanzen-Steckbriefe

### Anforderungen

| Anforderung | Technisch erzwungen? | Hinweis |
| --- | --- | --- |
| Wissenschaftlicher und deutscher Name | ja (Pflicht) | Schreibweise gegen eine Flora prüfen. |
| Beschreibung | ja (Pflicht, bis 20 000 Zeichen) | In **eigenen Worten**; keine Textübernahme aus Quellen. |
| Mindestens eine Quelle mit `https://` | ja | Qualität der Quelle nicht. |
| Sicherheitshinweis | **nein** (optional) | Redaktionell Pflicht bei jeder Art mit Risiko, siehe „Giftpflanzen- und Verzehrhinweise“. |
| Drei Lernkarten | ja | Details im Abschnitt „Lernkarten und Quizfragen“. |

### Quellen

- Verlinke die **direkte Artenseite** (z. B. einer Flora, eines Naturschutzportals, einer Hochschule), nicht eine allgemeine Namenssuche oder Übersichtsseite.
- Eine Quelle belegt nur, was sie wirklich sagt. Prüfe, ob sie die Art (nicht nur die Gattung oder Artengruppe) und die konkrete Aussage abdeckt.
- Mehrere Aussagen brauchen unter Umständen mehrere Quellen: Merkmale, Schutzstatus, Giftigkeit und Verwendung stehen selten auf derselben Seite.
- Ein Wikipedia-Link ist als Einstieg brauchbar, aber kein Ersatz für eine Fachquelle bei Giftigkeit, Schutzstatus oder Verzehr.
- Notiere bei Unsicherheit im Review-Kommentar, was du **nicht** geprüft hast. „Nicht geprüft“ ist eine gültige Aussage.

### Keine erfundenen Angaben

Erfinde keine Merkmale, Zahlen, Standorte oder Verwendungen. Besonders sorgfältig sind zu prüfen: Schutzstatus (hängt von Bundesland, Schutzgebiet und aktuellem Recht ab und darf nicht pauschal übertragen werden), Giftigkeit und Verzehr, Verwechslungsarten, Blüte- und Fruchtzeit, Höhe und Größe. Bei Artengruppen und schwer trennbaren Aggregaten (z. B. Margerite, Schafgarbe) kennzeichne die Texte als Lernniveau, nicht als abschließende Feldbestimmung.

Ein reales Beispiel aus der Projektarbeit (`knowledge/handovers/plant-profiles-content.md`): Bei einer Pflanze stimmte die Beschreibung der Blattteile nicht. Beschreibung, Lernkarte, Quizfrage, Antwortoption und Erklärung mussten **gemeinsam** korrigiert werden. Ändert sich ein Fakt, prüfe deshalb immer Steckbrief, alle drei Lernkarten und zugehörige Quizfragen zusammen.

!!! warning "Aktueller Stand der Demo-Inhalte"
    Die 30 Demo-Arten sind laut `todos.md` (Aufgabe CONTENT-10) **noch nicht** vollständig botanisch geprüft; viele Quellen sind allgemeine Einstiegsseiten. Behandle vorhandene Texte nicht als freigegeben, nur weil sie im System stehen.

## Lernkarten und Quizfragen

### Lernkarten (technisch geprüft)

Jede Pflanze hat **genau drei** Lernkarten. Jede Karte besteht aus Überschrift, Steckbrief-Text, Frage, einer richtigen und drei falschen Antworten. Der Server verlangt:

- alle sieben Felder gefüllt,
- vier **verschiedene** Antworten (Groß-/Kleinschreibung und Leerraum zählen nicht),
- die richtige Antwort steht **wörtlich im Steckbrief-Text** der Karte.

Die letzte Regel sichert nur die Form: Der Text muss die Antwort enthalten, nicht automatisch erklären. Das prüfst du im Review.

### Gute Fragen (redaktionelle Kriterien)

- **Genau eine richtige Antwort.** Nicht zwei vertretbare, keine „Teile davon stimmen“-Fälle.
- **Plausible Ablenker.** Falsche Antworten sollen typische Irrtümer abbilden (z. B. ähnliche Merkmale anderer Arten), nicht offensichtlich absurd sein, aber klar falsch bleiben.
- **Gleiche Form und ähnliche Länge.** Die richtige Antwort darf nicht durch Länge oder Wortwahl auffallen.
- **Keine Negationen und keine Sammelantworten** wie „Alle genannten“ oder „Keine der Antworten“.
- **Ein Merkmal je Frage.** Eine Karte vermittelt einen gezielten Aspekt (Rinde, Knospen, Frucht).
- **Passende Schwierigkeit.** Frühe Level fragen auffällige Merkmale ab, spätere Unterscheidungen ähnlicher Arten. Die Reihenfolge der Level (Feld „Reihenfolge“) und die Abschlussregel (`minimumScore` von 0 bis 1) sollen dazu passen.
- **Quiz und Karte widersprechen sich nie.**

Beispiel (aus dem Demo-Datensatz): Frage „Wie sehen die Winterknospen der Rotbuche typischerweise aus?“ mit der richtigen Antwort „Lang, schmal und spitz“ und den Ablenkern „Kurz, rund und schwarz“, „Grün und klebrig“, „Unter Blattstielresten verborgen“. Der Karten-Text nennt die richtige Antwort wörtlich.

### Quizfragen (technisch geprüft)

Ein Quiz hat genau vier Antworten mit verschiedenen Kennungen und Texten und eine gültige `correctChoiceId`. Das gilt für alle vier Fragetypen (`multiple-choice`, `flashcard`, `identification`, `feature-match`). Wie die App die Typen darstellt, ist hier nicht Thema.

## Bilder und Lizenzen

### Regel

Bilder dürfen nur verwendet werden, wenn sie unter einer freien Lizenz stehen **und** alle Angaben vorliegen:

| Lizenz | Zulässig? |
| --- | --- |
| CC0 / gemeinfrei (Public Domain) | ja |
| CC BY | ja, mit Namensnennung |
| CC BY-SA | ja, mit Namensnennung und Weitergabe unter gleichen Bedingungen |
| CC BY-NC, CC BY-ND und Varianten (NC = nicht kommerziell, ND = keine Bearbeitung) | **nein** |
| keine Lizenzangabe, „alle Rechte vorbehalten“, unbekannt | **nein** |

Pflichtangaben je Bild: **Urheber:in**, **Lizenz** (mit Link zum Lizenztext), **Quelle** (Link auf die Originalseite) und ein sinnvoller **Alt-Text**.

Belege für diese Regel:

- Die Seite „Bildnachweise“ der Homepage (`apps/homepage/bildnachweise/index.html`) nennt als Maßstab: „… stehen unter freien Lizenzen (CC0, gemeinfrei, CC BY oder CC BY-SA)“, verweist auf die Originalseite für Urheber:in und exakte Lizenz und weist auf Verkleinerung und Beschnitt hin.
- `AGENT.md` führt „ungeklärte Bildrechte“ als **Stop-Bedingung**: Dann wird nicht weitergearbeitet, sondern der Blocker dokumentiert.
- `todos.md` (CONTENT-12): „BANini-Bilder nicht ohne Nutzungsrecht übernehmen“. Die Lernkarten dürfen sich an der didaktischen Gliederung orientieren, **nicht** an Bildern oder Wortlaut fremder Seiten.

### Technischer Stand: Das System erzwingt die Lizenzregel nicht

Das Medien-Modell (`services/platform/src/api/media/content-types/media/schema.json`) verlangt `license`, `author` und `altText` als Pflichtfelder; die Lifecycle-Hooks (`lifecycles.js`) lehnen leere Werte ab. Ob die Lizenz **frei** ist, prüft nichts. Eine Positivliste (CC0 / BY / BY-SA) gibt es im Code nicht.

Bei den **automatisch zugeordneten Pflanzenfotos** (`services/platform/src/api/platform/services/core/content/wikimedia-photo-source.js`) ist das gelebter Stand:

- Es werden Fotos von Wikimedia Commons und iNaturalist verwendet; die Zuordnung zur Art wird über Wikidata bzw. iNaturalist-Taxon geprüft, die **Lizenz aber nicht gefiltert**. Fehlt eine Lizenz, steht dort `Unverified (internal testing)`.
- Der Alt-Text ist automatisch und generisch („… automatisch zugeordnetes Wikimedia-Foto“ bzw. „… iNaturalist Foto (internes Testing)“).
- Laut `knowledge/handovers/editorial-cards-and-practice.md` (Stand 29.09.2026) verteilen sich die 251 Demo-Bilder so: cc-by-nc 128, „Unverified“ 34, cc-by 29, cc-by-sa 25, cc-by-nc-sa 19, cc-by-nc-nd 7, pd 4, cc0 3, cc-by-nd 2. Nach der Regel oben wären nur **61 von 251** (cc-by, cc-by-sa, pd, cc0) zulässig. Das Handover nennt die übrigen Bilder „nicht für eine öffentliche Weitergabe freigegeben“.

!!! warning "Konsequenz"
    Solange das so ist, sind die automatisch geladenen Fotos nur für die interne Demo gedacht. Im Studio gibt es keine Bildverwaltung; vorhandene Bilder werden nur aufgelistet (Titel, Lizenz). Verlasse dich nicht darauf, dass ein angezeigtes Bild rechtlich in Ordnung ist. Vor jeder Weitergabe müssen Bilder ohne Lizenz und mit NC/ND-Lizenz entfernt oder durch geprüfte Bilder ersetzt werden.

### Alt-Texte

Beschreibe, was auf dem Bild zu erkennen ist und wozu es dient: „Glatte, weißgraue Rinde einer Rotbuche mit Moosbewuchs am Stammfuß“ statt „Rotbuche“ oder „Foto“. Maximal ein bis zwei Sätze, keine Wiederholung der Bildunterschrift.

### Namensnennung (Beispiel)

> Foto: [Name der Urheberin] ([Lizenz, z. B. CC BY 4.0]), Quelle: [Link zur Originalseite]

## Sprache und Inklusion

Diese Kriterien sind redaktionelle Empfehlungen; sie werden nicht automatisch geprüft.

- Schreibe **klar und kurz**, in der Du-Form wie die übrigen App-Texte. Erkläre Fachbegriffe beim ersten Gebrauch.
- Vermeide Redewendungen, Ironie und doppelte Verneinungen.
- Beschreibe Merkmale **ohne Abhängigkeit von Farbe allein**: nenne zusätzlich Form, Größe oder Position.
- Jedes Bild braucht einen Alt-Text (siehe oben).
- Prüfe, ob Lernende ohne Vorwissen die Frage verstehen; teste schwierige Formulierungen mit einer fachfremden Person.
- Verzichte auf Wertungen („einfach“, „natürlich“, „jeder weiß“).

## Datenschutz

- **Keine personenbezogenen Daten in Inhalten**: keine Namen von Schüler:innen, Lehrenden oder Dritten, keine Fotos von Personen, keine Fundorte oder Adressen von Privatpersonen.
- Exakte Fundorte sind im Projekt privat (`AGENT.md`): Sie gehören nicht in Steckbriefe oder Beispiele. Gib Lebensräume und Regionen allgemein an.
- Quellenlinks dürfen nicht auf Seiten mit persönlichen Daten führen.
- Kommentare im Review („Verlauf“) sind für das Team sichtbar; schreibe keine Namen Dritter oder Gesundheitsdaten hinein.

## Giftpflanzen- und Verzehrhinweise

Das Projekt behandelt Sicherheit als Pflichtthema: Die Anforderung FA040 („Sicherheits- und Schutzinformation“, `knowledge/features/requirements-catalog.md`) verlangt Hinweise zu Giftigkeit, Allergien, Schutzstatus, Sammelverboten und naturverträglichem Verhalten. Die Lern-Expeditionen sind ausdrücklich **Beobachtungsexpeditionen**: Quiz lösen und Funde fotografieren, nie Sammeln, Ausgraben, Probieren oder Anfassen empfindlicher oder geschützter Pflanzen (`knowledge/handovers/plant-profiles-content.md`).

Vorgaben für den **Sicherheitshinweis** (Feld „Sicherheitshinweis“, technisch optional):

1. **Immer setzen** bei giftigen, hautreizenden oder allergenen Arten, bei gefährlichen Verwechslungen und bei geschützten Arten.
2. Klar und handlungsorientiert formulieren: Was soll man **nicht** tun (verzehren, berühren, sammeln, probieren)?
3. Gefährliche Verwechslungsarten **benennen**, wenn belegt.
4. Nie Verzehr oder Heilwirkung empfehlen. Bestimmungen in der App sind keine Verzehr- oder Heilmittelempfehlung.
5. Schutzstatus nicht pauschal verallgemeinern; „in Schutzgebieten nichts pflücken oder ausgraben“ gilt immer.
6. Hinweise von einer botanisch qualifizierten Person gegenlesen lassen (so auch in der Freigabe-Checkliste des Projekts).

Beispiele aus dem Demo-Datensatz (`services/platform/src/api/platform/services/core/content/demo-content.de.json`):

> Früchte und andere Pflanzenteile nicht verzehren; Beobachtung zur Bestimmung genügt.

> Nicht sammeln oder probieren. Lebensgefährliche Verwechslungen mit Maiglöckchen, Herbstzeitlose und Aronstab sind möglich; Geruch allein ist kein sicherer Bestimmungsbeleg.

> Wildpflanzen nur beobachten und fotografieren. In Schutzgebieten nichts pflücken, ausgraben oder beschädigen. Bestimmungen dienen nicht als Verzehr- oder Heilmittelempfehlung.

!!! warning "Im Zweifel zurückweisen"
    Fehlt bei einer Art mit Risiko der Hinweis oder ist er unbelegt, weise die Änderung mit Begründung zurück ([Review-Prozess](review.md)). Ein fehlender Warnhinweis ist schwerer zu verantworten als eine verzögerte Veröffentlichung.

## Checkliste zum Ausdrucken

!!! tip "Drucken"
    Diese Seite lässt sich im Browser über „Drucken“ ausgeben; die Checkliste ist so gebaut, dass sie auf einer Seite Platz hat.

**Änderung:** ______________________  **Typ / Slug:** ______________________  **Geprüft von / Datum:** ______________________

| Nr. | Prüfpunkt | In Ordnung | Notiz |
| --- | --- | --- | --- |
| 1 | Namen (wissenschaftlich und deutsch) und Familie stimmen | ☐ | |
| 2 | Beschreibung in eigenen Worten, ohne erfundene Angaben | ☐ | |
| 3 | Mindestens eine `https://`-Quelle; direkte Artenseite; belegt die Aussagen | ☐ | |
| 4 | Sicherheitshinweis vorhanden und belegt (Verzehr, Berühren, Sammeln, Verwechslung, Schutzstatus) | ☐ | |
| 5 | Genau drei Lernkarten; je eine richtige und drei plausible falsche Antworten | ☐ | |
| 6 | Richtige Antwort steht im Karten-Text und wird dort erklärt | ☐ | |
| 7 | Quizfrage: genau eine richtige Antwort, vier verschiedene Antworten | ☐ | |
| 8 | Karten, Steckbrief und Quizfragen widersprechen sich nicht | ☐ | |
| 9 | Schwierigkeit, Reihenfolge und Abschlussregel (`minimumScore` 0 bis 1) sinnvoll | ☐ | |
| 10 | Sprache klar, fehlerfrei, ohne Wertungen; Fachbegriffe erklärt | ☐ | |
| 11 | Bilder (falls vorhanden): CC0, gemeinfrei, CC BY oder CC BY-SA | ☐ | |
| 12 | Bilder: Urheber:in, Lizenz, Quelle und Alt-Text vorhanden; keine NC/ND, keine unbekannte Lizenz | ☐ | |
| 13 | Keine personenbezogenen Daten, keine exakten Fundorte | ☐ | |
| 14 | Slug klein, eindeutig; Bezüge (Ökosystem, Level, Pflanzen) vorhanden | ☐ | |
| 15 | Nicht Geprüftes im Kommentar vermerkt | ☐ | |

Entscheidung: ☐ fachlich freigeben ☐ zurückweisen (Begründung 3 bis 2000 Zeichen)

## Weiterführend

- [Studio-Handbuch](studio-handbuch.md) – Felder, Grenzen und Fehlermeldungen
- [Review-Prozess](review.md) – Freigeben, zurückweisen, Konflikte
- [Einstieg Moderation](index.md) – Rollen und Glossar
- Quellpfade: `services/platform/src/api/platform/services/core/content/lesson-cards.js`, `services/platform/src/api/platform/services/core/content/wikimedia-photo-source.js`, `services/platform/src/api/media/content-types/media/schema.json`, `apps/homepage/bildnachweise/index.html`, `AGENT.md`, `knowledge/handovers/plant-profiles-content.md`, `knowledge/handovers/editorial-cards-and-practice.md`
