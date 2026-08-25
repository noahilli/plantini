# Vollständiger Anforderungskatalog

Dieser Katalog ist aus `plantini-anforderungen v1.2` abgeleitet. Die CSV ist die maschinenlesbare Arbeitsansicht; bei Unklarheiten gilt die normative Formulierung im referenzierten PDF, bis Product Manager und Orchestrator eine dokumentierte Änderung freigeben.

## Konto, Anmeldung und Berechtigungen

### FA001 · Klassische Registrierung und Anmeldung

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Nutzer:innen können ein Konto mit E-Mail-Adresse und Passwort anlegen, E-Mail bestätigen, sich anmelden und das Passwort zurücksetzen. Zugangsdaten werden ausschließlich durch den Identity-Provider verarbeitet.
- Abnahme: Ein neu angelegtes und bestätigtes Konto kann sich auf Android, iOS und Web anmelden; nicht bestätigte oder gesperrte Konten erhalten eine verständliche Fehlermeldung.
- Querbezüge: FA004;FA008;NFA009;NFA013

### FA002 · Google- und Apple-Anmeldung

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Google und Apple werden als externe Identitätsanbieter über OpenID Connect/OAuth eingebunden. Konten mit gleicher verifizierter E-Mail werden nicht automatisch ohne sichere Verknüpfung zusammengeführt.
- Abnahme: Beide Provider funktionieren im Release-Build; Abbruch, verweigerte E-Mail-Freigabe und bereits vorhandenes Konto sind getestet.
- Querbezüge: FA003;FA004;NFA009

### FA003 · Schul- und Hochschul-SSO

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Der zentrale Identity-Provider kann weitere OIDC- und SAML-2.0-Anbieter als Identity Broker anbinden. Institutionen werden über freigegebene Domains oder explizite Provider-Konfiguration zugelassen.
- Abnahme: Eine Testinstitution kann sich über OIDC oder SAML anmelden, erhält die konfigurierte Organisationszuordnung und kann ohne App-Update ergänzt werden.
- Querbezüge: FA006;FA007;FA061;NFA002

### FA004 · Kontoprofil und Identitätsverknüpfung

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Nutzer:innen verwalten Anzeigename, bevorzugte Sprache und verknüpfte Anmeldewege. Botanische Beobachtungen referenzieren eine interne stabile Nutzer-ID, nicht E-Mail oder Provider-ID.
- Abnahme: Änderung der E-Mail oder Verknüpfung eines Providers verliert weder Fortschritt noch Herbarium; sicherheitsrelevante Änderungen erfordern erneute Authentifizierung.
- Querbezüge: FA001;FA002;FA009

### FA005 · Einwilligungen und Altersfluss

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Registrierung erfasst notwendige Zustimmungen getrennt von optionaler Forschung und Kommunikation. Für Minderjährige wird ein konfigurierbarer alters- und institutionsabhängiger Zustimmungsfluss unterstützt.
- Abnahme: Zeitpunkt, Textversion, Zweck und Widerruf werden nachweisbar gespeichert; optionale Einwilligungen sind nicht vorausgewählt und ohne Funktionsverlust widerrufbar.
- Querbezüge: FA073;NFA012;NFA013

### FA006 · Rollen und Berechtigungen

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Mindestens die Rollen Lernende, Lehrende, Inhaltsredaktion, botanisches Review, Organisationsadministration und Systemadministration werden mit getrennten Rechten unterstützt.
- Abnahme: Eine Rollenmatrix ist implementiert; jeder geschützte API-Aufruf wird serverseitig geprüft und Negativtests verhindern Rechteausweitung.
- Querbezüge: FA056;FA061;NFA010

### FA007 · Einladung administrativer Nutzer

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Zugang zum Administrationssystem erfolgt nur über ablaufende Einladung durch berechtigte Administrator:innen oder über eine freigegebene Institution. Selbstregistrierung für das Backend ist deaktiviert.
- Abnahme: Nicht eingeladene App-Nutzer können das Backend nicht betreten; Einladungen sind einmalig, zeitlich begrenzt und auditierbar.
- Querbezüge: FA003;FA006;FA059

### FA008 · Sitzungen und Abmeldung

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Nutzer:innen können sich lokal und auf allen Geräten abmelden. Refresh-Tokens können widerrufen werden; gesperrte Konten verlieren zeitnah den Online-Zugriff.
- Abnahme: „Von allen Geräten abmelden“ invalidiert aktive Tokens; die App löscht Tokens sicher, behält Offline-Inhalte aber gemäß Nutzerwahl.
- Querbezüge: FA001;NFA009;NFA011

### FA009 · Datenkopie und Kontolöschung

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Nutzer:innen können eine maschinenlesbare Kopie ihrer Profildaten, Fortschritte und Herbariumseinträge anfordern sowie ihr Konto löschen. Gesetzliche oder wissenschaftlich vereinbarte Aufbewahrungen werden transparent ausgewiesen.
- Abnahme: Export wird in einem dokumentierten Format bereitgestellt; Löschung entfernt oder anonymisiert personenbezogene Daten innerhalb der festgelegten Frist und erzeugt einen Auditnachweis ohne Inhaltsdaten.
- Querbezüge: FA039;FA074;NFA012

## Ökosysteme, Level und Pflanzenwissen

### FA010 · Dynamische Ökosysteme

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Redakteur:innen können beliebig viele Ökosysteme mit Titel, Beschreibung, Region, Saison, Bildern, Reihenfolge und Veröffentlichungsstatus anlegen.
- Abnahme: Ein neues Ökosystem erscheint nach Veröffentlichung und Synchronisation ohne App-Release; Entwürfe bleiben unsichtbar.
- Querbezüge: FA014;FA050;FA054

### FA011 · Dynamische Level

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Level sind datengetrieben und enthalten Name, Lernziel, Schwierigkeitsgrad, Artenmenge, Quizkonfiguration, Abschlussbedingungen, Freischaltregel und Reihenfolge. Die Anzahl ist nicht im App-Code begrenzt.
- Abnahme: Ein viertes Testlevel kann vollständig im Backend angelegt, veröffentlicht, synchronisiert und gespielt werden, ohne die App neu zu bauen.
- Querbezüge: FA012;FA026;FA053

### FA012 · Voraussetzungen und Freischaltung

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Level können abhängig von vorherigem Abschluss, Mindestpunktzahl, gefundenen Arten oder administrativer Freigabe gesperrt bzw. freigeschaltet werden.
- Abnahme: Alle konfigurierten Regeln werden server- und clientseitig konsistent ausgewertet; die Oberfläche erklärt noch fehlende Voraussetzungen.
- Querbezüge: FA011;FA026;FA063

### FA013 · Pflanzensteckbrief

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Ein Steckbrief enthält wissenschaftlichen Namen, gebräuchliche Namen, Familie, Beschreibung, Erkennungsmerkmale, Verwechslungsarten, Lebensraum, Blütezeit, Verbreitung, Schutz-/Gefahrenhinweise, Quellen und Medien.
- Abnahme: Pflichtfelder und Taxonomie werden validiert; ein veröffentlichter Steckbrief ist offline lesbar und zeigt Quellen- sowie Lizenzangaben.
- Querbezüge: FA015;FA060;NFA028

### FA014 · Mehrsprachige Inhalte

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Ökosysteme, Level, Steckbriefe, Quizfragen und UI-Texte sind lokalisierbar. Fallback-Sprache und Übersetzungsstatus werden je Inhalt verwaltet.
- Abnahme: Deutsch ist vollständig; ein zweites Test-Locale kann für mindestens einen vollständigen Lernpfad veröffentlicht werden, fehlende Texte fallen kontrolliert zurück.
- Querbezüge: FA010;FA013;NFA018

### FA015 · Bild- und Medienanzeige

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Pflanzen können mehrere fachlich beschriftete Bilder für Habitus, Blatt, Blüte, Frucht und Rinde besitzen. Varianten/Thumbnails werden serverseitig erzeugt.
- Abnahme: Bilder laden responsiv, sind mit Alternativtext, Urheber:in und Lizenz versehen und stehen in definierter Offline-Qualität zur Verfügung.
- Querbezüge: FA013;FA060;NFA016

### FA016 · Suche und Filter

- Priorität: **SOLL**
- Primärrolle: `flutter-frontend`
- Beschreibung: Nutzer:innen können Pflanzen nach deutschem und wissenschaftlichem Namen suchen sowie nach Ökosystem, Familie, Merkmal, Saison und Lernstatus filtern.
- Abnahme: Suche liefert bei 225 Arten innerhalb von 300 ms auf einem Referenzgerät relevante Ergebnisse und funktioniert offline.
- Querbezüge: FA013;FA041;NFA005

### FA017 · Versioniertes Inhaltsmanifest

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Jede Veröffentlichung erzeugt eine Inhaltsversion mit Manifest, Prüfsummen, Größen und Abhängigkeiten. Clients ermitteln damit Delta-Updates und erkennen veraltete Inhalte.
- Abnahme: Ein Client mit Version N lädt nur geänderte Daten/Medien für N+1; fehlerhafte Prüfsummen führen zu Wiederholung statt inkonsistentem Bestand.
- Querbezüge: FA041;FA045;FA054

## Lernen, Quiz und Fortschritt

### FA020 · Geführte Lerneinheiten

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Ein Level vermittelt Arten in konfigurierbaren Einheiten aus Bild, Kurztext, Merkmalen, Merkhilfe und Selbstprüfung. Einheiten können unterbrochen und fortgesetzt werden.
- Abnahme: Ein vollständiges Level lässt sich mit der Backend-Konfiguration durchlaufen; die letzte Position wird lokal und serverseitig wiederhergestellt.
- Querbezüge: FA011;FA029;FA041

### FA021 · Quizmodus Bilderkennung

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Aus einem oder mehreren kuratierten Bildern wird die richtige Pflanzenart per Auswahl oder Texteingabe bestimmt. Distraktoren sind manuell definierbar oder regelbasiert aus ähnlichen Arten wählbar.
- Abnahme: Frage, Lösung, Distraktoren und Erklärung funktionieren offline; dieselbe Bild-Lizenz wird wie im Steckbrief ausgewiesen.
- Querbezüge: FA013;FA024;FA052

### FA022 · Quizmodus Artennamen

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Wissenschaftliche und gebräuchliche Namen werden in beide Richtungen abgefragt; akzeptierte Synonyme und Tippfehlertoleranz sind konfigurierbar.
- Abnahme: Tests decken Synonyme, Groß-/Kleinschreibung, Sonderzeichen und nicht akzeptierte falsche Arten ab.
- Querbezüge: FA014;FA024;FA052

### FA023 · Quizmodus Merkmale und Lebensräume

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Quizfragen prüfen botanische Merkmale, Familien, Blütezeit, Lebensräume und ökologische Zusammenhänge als Single-/Multiple-Choice, Zuordnung oder Wahr/Falsch.
- Abnahme: Jeder Fragetyp kann im Backend erstellt, validiert, offline beantwortet und mit fachlicher Erklärung ausgewertet werden.
- Querbezüge: FA013;FA024;FA052

### FA024 · Bewertung und unmittelbares Feedback

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Antworten werden reproduzierbar bewertet. Nutzer:innen erhalten korrekt/falsch, eine kurze Begründung und optional einen Hinweis auf das entscheidende Merkmal.
- Abnahme: Bewertungslogik ist automatisiert getestet; Feedback verrät bei Wiederholungsfragen nicht unbeabsichtigt die Lösung.
- Querbezüge: FA021;FA022;FA023;FA025

### FA025 · Wiederholung nach Lernstand

- Priorität: **SOLL**
- Primärrolle: `flutter-frontend`
- Beschreibung: Falsch oder unsicher beantwortete Arten werden häufiger wiederholt; der Algorithmus ist transparent konfigurierbar und speichert keinen unnötig detaillierten Verhaltensverlauf.
- Abnahme: Ein definierter Testverlauf erzeugt reproduzierbar die erwartete Wiederholungsreihenfolge; Nutzer:innen können eine Wiederholung neu starten.
- Querbezüge: FA024;FA028;NFA012

### FA026 · Levelabschluss

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Ein Level wird abgeschlossen, wenn seine konfigurierten Lern-, Quiz- und Feldbedingungen erfüllt sind. Die Entscheidung wird serverseitig validiert und offline vorläufig angezeigt.
- Abnahme: Manipulierte Clientdaten führen nicht zum Abschluss; nach Synchronisation stimmen Client und Server überein.
- Querbezüge: FA012;FA030;FA043

### FA027 · Erfolge und Zertifikat

- Priorität: **SOLL**
- Primärrolle: `flutter-frontend`
- Beschreibung: Konfigurierbare Erfolge visualisieren Meilensteine. Nach Abschluss des vorgesehenen Curriculums kann ein verifizierbares Teilnahmezertifikat mit Name oder Pseudonym erzeugt werden.
- Abnahme: Mindestens fünf MVP-Erfolge sind konfiguriert; Zertifikate enthalten eindeutige Verifikations-ID, Aussteller, Datum und erreichten Umfang.
- Querbezüge: FA026;FA063;NFA012

### FA028 · Fortschrittsübersicht

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Dashboard und Levelansicht zeigen absolvierte Einheiten, Quizleistung, gefundene Arten, nächste Aufgabe und Gesamtfortschritt.
- Abnahme: Fortschritt ist nach Neuinstallation und Anmeldung wiederherstellbar; Werte stimmen mit serverseitiger Berechnung überein.
- Querbezüge: FA026;FA057;FA072

### FA029 · Pausieren und Fortsetzen

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Lern- und Quizsitzungen können ohne Datenverlust verlassen und später auf demselben oder einem anderen Gerät fortgesetzt werden.
- Abnahme: App-Abbruch nach jedem Schritt führt nach Neustart höchstens zur Wiederholung des letzten atomaren Schritts, nicht zum Verlust einer Einheit.
- Querbezüge: FA020;FA042;FA044

## Exkursion, PlantNet und Herbarium

### FA030 · Abschlussaufgabe in der Natur

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Level können eine oder mehrere Zielarten als Feldaufgabe verlangen. Aufgabe, Sicherheitshinweise, Suchgebiet-Genauigkeit und Nachweisbedingungen sind konfigurierbar.
- Abnahme: Eine veröffentlichte Feldaufgabe kann offline geöffnet, fotografiert, später identifiziert und dem Levelabschluss zugeordnet werden.
- Querbezüge: FA026;FA031;FA033

### FA031 · Fotoaufnahme und Bildauswahl

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Die App unterstützt Kamera und – sofern erlaubt – Galerie. Sie gibt Hinweise für geeignete Aufnahmen und kann bis zu fünf Bilder desselben Individuums mit Organangabe bündeln.
- Abnahme: JPG/PNG werden vor Upload auf definierte Größe komprimiert, Orientierung bleibt korrekt, ungeeignete oder zu große Dateien werden verständlich abgewiesen.
- Querbezüge: FA033;NFA005;NFA014

### FA032 · Fundort erfassen

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: GPS-Koordinaten sind optional und werden nur nach expliziter Berechtigung erfasst. Nutzer:innen können Genauigkeit reduzieren, einen Ort manuell setzen oder keinen Ort speichern.
- Abnahme: Ablehnung der Standortfreigabe blockiert Foto und Herbarium nicht; genaue Koordinaten sind standardmäßig privat.
- Querbezüge: FA036;FA039;NFA014

### FA033 · Pflanzenidentifikation über PlantNet

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Bilder werden über das eigene Backend an PlantNet gesendet; der API-Schlüssel bleibt serverseitig. Das Backend wählt Region/Flora und Sprache, speichert Antwort, Score, Modellversion und Quotenstatus.
- Abnahme: Erfolgs-, Timeout-, 4xx-, 5xx- und Quotenfälle sind getestet; Nutzer:innen sehen Status und können später erneut versuchen.
- Querbezüge: FA031;FA034;FA035;NFA030

### FA034 · Abgleich mit erwarteter Art

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Das normalisierte Taxon der PlantNet-Ergebnisse wird gegen Zielart und freigegebene Synonyme des Levels verglichen. Schwellwerte für sicher, unsicher und nicht passend sind konfigurierbar.
- Abnahme: Tests decken exakte Treffer, Synonyme, niedrigen Score, ähnliche Art und kein Ergebnis ab; ein niedriger Score wird nicht als sicherer Treffer gewertet.
- Querbezüge: FA013;FA030;FA033;FA063

### FA035 · Unsicherheit und erneuter Versuch

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Bei unsicherer oder abweichender Identifikation erklärt die App, dass Ergebnisse probabilistisch sind, zeigt geeignete nächste Aufnahmen und erlaubt einen neuen Versuch.
- Abnahme: Die UI behauptet nie Gewissheit allein aufgrund des Top-1-Ergebnisses; bei Quoten-/Netzfehler bleibt der Auftrag wiederholbar.
- Querbezüge: FA031;FA033;NFA030

### FA036 · Herbariumeintrag erzeugen

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Ein bestätigter Fund erzeugt einen persönlichen Eintrag mit eigenem Foto, referenziertem Steckbrief, Datum, optionalem Fundort, Notiz und Identifikationsmetadaten.
- Abnahme: Ein Eintrag ist direkt offline sichtbar, wird idempotent synchronisiert und erzeugt bei Wiederholung kein ungewolltes Duplikat.
- Querbezüge: FA032;FA037;FA043

### FA037 · Herbarium durchsuchen und anzeigen

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Die Sammlung bietet Raster/Liste, Detailansicht, Sortierung und Filter nach Art, Ökosystem, Datum, Ort vorhanden und Level.
- Abnahme: Mindestens 500 Einträge lassen sich auf dem Referenzgerät flüssig durchsuchen; Bilder und Notizen sind offline verfügbar.
- Querbezüge: FA016;FA036;FA041

### FA038 · Notizen und Funddaten bearbeiten

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Eigene Notizen, Titel, Datum und Standortfreigabe können nachträglich geändert werden; die ursprünglich erkannte Art bleibt mit Historie nachvollziehbar.
- Abnahme: Änderungen werden konfliktarm synchronisiert; fachliche Quelldaten werden nicht durch persönliche Notizen überschrieben.
- Querbezüge: FA036;FA044;FA059

### FA039 · Einzelfund exportieren oder löschen

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Nutzer:innen können eigene Funde samt Bild und Metadaten exportieren und löschen. Beim Teilen werden genaue Koordinaten standardmäßig entfernt oder vergröbert.
- Abnahme: Export und Löschung funktionieren offline mit späterer Synchronisation; geteilte Standarddatei enthält keine exakten GPS-Daten.
- Querbezüge: FA009;FA032;NFA014

### FA040 · Sicherheits- und Schutzinformation

- Priorität: **MUSS**
- Primärrolle: `content-data`
- Beschreibung: Vor Feldaufgaben und bei relevanten Pflanzen zeigt die App konfigurierbare Hinweise zu Giftigkeit, Allergien, Schutzstatus, Sammelverboten und naturverträglichem Verhalten.
- Abnahme: Pflichtwarnungen können nicht versehentlich durch fehlende Übersetzung entfallen; veraltete Warnungen können zentral zurückgezogen werden.
- Querbezüge: FA013;FA017;NFA028

## Offline-Nutzung und Synchronisation

### FA041 · Offline-Lerninhalte

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Ausgewählte Ökosysteme und Level einschließlich Steckbriefen, Quizfragen und optimierten Medien werden lokal gespeichert und ohne Netz nutzbar.
- Abnahme: Ein vollständig heruntergeladenes Level kann im Flugmodus gelernt und gequizzt werden; fehlende optionale Medien sind klar markiert.
- Querbezüge: FA017;FA045;NFA020

### FA042 · Offline-Fortschritt

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Lern-, Quiz- und Fortschrittsereignisse werden lokal als unveränderliche, eindeutig identifizierte Ereignisse gespeichert und später übertragen.
- Abnahme: Mehrfaches Senden desselben Ereignisses verändert das Ergebnis nur einmal; Neustart während Synchronisation verursacht keinen Verlust.
- Querbezüge: FA026;FA029;FA044

### FA043 · Offline-Auftragswarteschlange

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Foto-Uploads und Identifikationen können ohne Netz vorbereitet werden. Die App zeigt Wartestatus, ermöglicht Abbruch und überträgt nur bei geeigneter Verbindung entsprechend Nutzerpräferenz.
- Abnahme: Ein offline erstellter Auftrag wird nach Netzwiederkehr genau einmal hochgeladen und sein Ergebnis dem richtigen Fund/Level zugeordnet.
- Querbezüge: FA030;FA033;FA036

### FA044 · Synchronisation und Konflikte

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Synchronisation arbeitet idempotent mit Client-IDs, Serverversionen und klaren Konfliktregeln. Inhaltsdaten sind serverführend; persönliche Texte nutzen versionsbasierten Konfliktschutz; Fortschrittsereignisse werden zusammengeführt.
- Abnahme: Automatisierte Tests simulieren zwei Geräte, Offline-Änderungen, Wiederholung, Reihenfolgewechsel und gelöschte Datensätze ohne stillen Datenverlust.
- Querbezüge: FA017;FA038;FA042;NFA020

### FA045 · Download- und Speicherverwaltung

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Nutzer:innen sehen Größe und Status von Offline-Paketen, können Downloads pausieren/löschen und zwischen WLAN-only bzw. mobiler Übertragung wählen.
- Abnahme: Ein abgebrochener Download wird fortgesetzt oder sauber neu gestartet; Löschen eines Pakets entfernt keine persönlichen Herbariumdaten.
- Querbezüge: FA017;FA041;NFA005

## Administrationssystem

### FA050 · Inhalte verwalten

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Berechtigte Redakteur:innen können Ökosysteme, Pflanzen, Beschreibungen, Bilder, Quizfragen, Level und Abschlussbedingungen erstellen, lesen, ändern, archivieren und veröffentlichen.
- Abnahme: Alle MVP-Inhalte sind ohne Datenbankzugriff pflegbar; Berechtigungen greifen pro Operation und Inhaltstyp.
- Querbezüge: FA010;FA011;FA013;FA054

### FA051 · Beziehungen und fachliche Validierung

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Das Backend prüft Pflichtfelder, Taxon-IDs, Synonyme, Levelabhängigkeiten, Quizlösungen, Übersetzungen, Bildlizenzen und zyklische Freischaltregeln vor Veröffentlichung.
- Abnahme: Ein absichtlich unvollständiges Level kann nicht veröffentlicht werden; Fehlermeldungen benennen Feld und Korrektur.
- Querbezüge: FA011;FA013;FA052;NFA028

### FA052 · Quiz-Builder

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Redakteur:innen erstellen alle unterstützten Fragetypen, Lösungen, Erklärungen, Hinweise, Distraktoren, Schwierigkeit und Zielkompetenz in einer Vorschau.
- Abnahme: Jeder Fragetyp wird in der Vorschau identisch zur App dargestellt und kann einem Level bzw. einer Art zugeordnet werden.
- Querbezüge: FA021;FA022;FA023

### FA053 · Level- und Regel-Builder

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Levelreihenfolge, Artenauswahl, Lernblöcke, Quizmix, Mindestwerte, Feldaufgaben und Freischaltung werden über Formulare konfiguriert.
- Abnahme: Ein:e Konfigurator:in kann das vierte Testlevel ohne Entwicklerhilfe anlegen und in einer Staging-App testen.
- Querbezüge: FA011;FA012;FA030;FA063

### FA054 · Entwurf, Review und Veröffentlichung

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Inhalte durchlaufen Entwurf, fachliches Review, Freigabe, Veröffentlichung und Archivierung. Veröffentlichungen sind versioniert und zeitlich planbar; Rücknahme ist möglich.
- Abnahme: Redaktion kann nicht selbst das verpflichtende botanische Review umgehen; Rücknahme erzeugt ein neues Manifest und Auditereignis.
- Querbezüge: FA017;FA059;NFA028

### FA055 · App-Nutzer verwalten

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Administratoren können App-Nutzer suchen, Status und Organisation sehen, sperren/entsperren sowie Datenschutzanfragen anstoßen. Passwörter sind nie sichtbar oder administrativ auslesbar.
- Abnahme: Sperrung verhindert neue Online-Sitzungen; alle administrativen Aktionen sind autorisiert und auditiert.
- Querbezüge: FA006;FA008;FA009;FA059

### FA056 · Rollen- und Rechteverwaltung

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Systemadministrator:innen weisen Backend-Rollen zu und konfigurieren deren Rechte. Kritische Systemrechte sind nicht durch Organisationsadmins vergebbar.
- Abnahme: Eine dokumentierte Rechte-Matrix wird in Integrationstests für erlaubte und verbotene Aktionen geprüft.
- Querbezüge: FA006;FA007;NFA010

### FA057 · Nutzungsdashboard

- Priorität: **MUSS**
- Primärrolle: `research-analytics`
- Beschreibung: Das Backend zeigt datenschutzgerecht registrierte/aktive Nutzer, Levelstarts/-abschlüsse, Lernfortschritt, Quizleistung, Funde, Identifikationsstatus und technische Fehler.
- Abnahme: Kennzahlen haben Definition, Zeitraum und Filter; kleine Gruppen werden bei Forschungs-/Organisationsansichten unterdrückt oder aggregiert.
- Querbezüge: FA028;FA058;FA070;NFA012

### FA058 · Filter und Berichtsexport

- Priorität: **SOLL**
- Primärrolle: `research-analytics`
- Beschreibung: Dashboards lassen sich nach Zeitraum, Ökosystem, Level, Plattform und – berechtigt – Organisation filtern. Aggregierte Tabellen können als CSV exportiert werden.
- Abnahme: Exportwerte stimmen für einen bekannten Testdatensatz mit Dashboardwerten überein; personenbezogene Rohdaten sind nicht enthalten.
- Querbezüge: FA057;FA072;NFA012

### FA059 · Änderungs- und Auditprotokoll

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Sicherheitsrelevante Administration, Rollenänderungen, Veröffentlichung und wesentliche Inhaltsänderungen werden mit Akteur, Zeitpunkt und Objekt nachvollziehbar protokolliert.
- Abnahme: Auditdaten sind unveränderlich für normale Admins, filterbar und nach festgelegter Frist löschbar; sensible Inhalte werden nicht unnötig dupliziert.
- Querbezüge: FA007;FA054;FA056;NFA025

### FA060 · Medienrechte verwalten

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Jedes Medium besitzt Urheber:in, Quelle, Lizenz, Lizenz-URL, Alternativtext, Freigabestatus und optional Ablaufdatum/Region.
- Abnahme: Ein Medium ohne Pflichtangaben kann nicht veröffentlicht werden; Attribution erscheint in App und Export.
- Querbezüge: FA015;FA051;NFA001

### FA061 · Organisationen verwalten

- Priorität: **SOLL**
- Primärrolle: `auth-manager`
- Beschreibung: Hochschulen und Bildungseinrichtungen werden mit Domains, Identity-Providern, Admins und sichtbaren Auswertungsbereichen verwaltet. Inhalte können global oder organisationsspezifisch sein.
- Abnahme: Ein Organisationsadmin sieht nur freigegebene Organisationsdaten; globale Systemverwaltung bleibt getrennt.
- Querbezüge: FA003;FA006;FA057

### FA062 · Strukturierter Import und Export

- Priorität: **SOLL**
- Primärrolle: `cms-manager`
- Beschreibung: Pflanzen, Übersetzungen und Quizfragen können über validierte CSV/JSON-Vorlagen importiert und exportiert werden. Ein Dry-run zeigt Fehler vor Speicherung.
- Abnahme: Ein Referenzdatensatz mit 75 Arten wird reproduzierbar importiert; fehlerhafte Zeilen werden mit Zeile/Feld berichtet, ohne Teilveröffentlichung.
- Querbezüge: FA013;FA014;FA051

### FA063 · Systemkonfiguration

- Priorität: **MUSS**
- Primärrolle: `cms-manager`
- Beschreibung: Schwellwerte, maximale Uploadgröße, erlaubte Sprachen, Feature Flags, Levelregeln, PlantNet-Flora, Quotenwarnung und Supporthinweise sind versioniert konfigurierbar. Geheimnisse gehören nicht in diese Inhaltskonfiguration.
- Abnahme: Änderungen werden auditiert, vor Aktivierung validiert und können auf einen vorherigen Stand zurückgeführt werden.
- Querbezüge: FA012;FA034;FA053;NFA011

## Forschung, Daten und Support

### FA070 · Datensparsame Nutzungsereignisse

- Priorität: **SOLL**
- Primärrolle: `research-analytics`
- Beschreibung: Die Plattform erfasst nur definierte, versionierte Ereignisse zur Produktqualität und – nach passender Rechtsgrundlage – Forschung. Freitext, genaue GPS-Daten und Fotos werden nicht in Analytikereignisse kopiert.
- Abnahme: Ein Eventkatalog dokumentiert Zweck, Felder, Rechtsgrundlage und Aufbewahrung; unbekannte Felder werden serverseitig abgewiesen.
- Querbezüge: FA005;FA057;FA073;NFA012

### FA071 · Studienkohorten und Varianten

- Priorität: **KANN**
- Primärrolle: `research-analytics`
- Beschreibung: Berechtigte Forschende können freigegebene, ethisch genehmigte Studienvarianten und Kohorten konfigurieren, ohne Kerninhalte unkontrolliert zu verändern.
- Abnahme: Zuweisung ist reproduzierbar und protokolliert; eine Studie kann gestoppt werden und Nutzer:innen behalten einen sicheren Standardpfad.
- Querbezüge: FA070;FA073;NFA028

### FA072 · Pseudonymisierter Forschungsdatenexport

- Priorität: **SOLL**
- Primärrolle: `research-analytics`
- Beschreibung: Berechtigte Forschende können zweckgebundene, minimierte Datensätze mit projektspezifischem Pseudonym und Datenwörterbuch exportieren. Identitätsdaten liegen getrennt.
- Abnahme: Export enthält nur genehmigte Felder/Teilnehmende; Kleingruppen- und Reidentifikationsrisiko wird vor Freigabe geprüft.
- Querbezüge: FA057;FA070;FA073;NFA012

### FA073 · Forschungseinwilligung und Widerruf

- Priorität: **SOLL**
- Primärrolle: `research-analytics`
- Beschreibung: Teilnahme an Forschung ist getrennt von App-Nutzung. Information, Einwilligung, Version und Widerruf werden studienspezifisch verwaltet.
- Abnahme: Ohne Einwilligung entstehen keine Forschungsereignisse; Widerruf wirkt für zukünftige Verarbeitung und stößt den genehmigten Umgang mit Bestandsdaten an.
- Querbezüge: FA005;FA070;FA072

### FA074 · Aufbewahrung und Löschläufe

- Priorität: **MUSS**
- Primärrolle: `research-analytics`
- Beschreibung: Für Konto, Fortschritt, Fotos, Standort, Logs, Audit und Forschung gelten getrennte konfigurierbare Aufbewahrungsregeln und dokumentierte Löschläufe.
- Abnahme: Ein automatisierter Bericht weist fällige, gelöschte, anonymisierte und rechtmäßig zurückgestellte Datensätze nach.
- Querbezüge: FA009;FA059;NFA012

### FA075 · Feedback und Support

- Priorität: **SOLL**
- Primärrolle: `product-manager`
- Beschreibung: Nutzer:innen können technische Probleme oder Inhaltsfehler mit App-/Inhaltsversion melden. Das Senden von Diagnosedaten und Screenshot ist optional.
- Abnahme: Feedback erreicht ein definiertes Ticketsystem; personenbezogene Anhänge werden kenntlich gemacht und nach Supportfrist entfernt.
- Querbezüge: FA017;NFA024;NFA027

## Offenheit, Architektur und Portabilität

### NFA001 · Open-Source-Lizenzierung

- Priorität: **MUSS**
- Primärrolle: `orchestrator`
- Beschreibung: Der vollständige projektspezifische Quellcode für App, Backend-Erweiterungen, Infrastruktur, Tests und Dokumentation wird unter einer OSI-kompatiblen Lizenz veröffentlicht. Abhängigkeiten und Inhalte besitzen kompatible Lizenzen; Medien können abweichende offene Einzellizenzen tragen.
- Abnahme: Ein automatisierter Lizenz- und SBOM-Scan weist keine unfreigegebenen inkompatiblen Abhängigkeiten nach; LICENSE, NOTICE und Medienattribution sind vollständig.
- Querbezüge: FA060;NFA010

### NFA002 · Modulare Gesamtarchitektur

- Priorität: **MUSS**
- Primärrolle: `orchestrator`
- Beschreibung: App, Identität, Inhaltsverwaltung, Fachlogik, Datenbank, Objektspeicher, Analytik und externe Identifikation sind über dokumentierte Schnittstellen getrennt. Anbieterabhängige Logik liegt hinter Adaptern.
- Abnahme: Ein Austausch des PlantNet-Adapters oder lokalen Speichers erfordert keine Änderung der Domänenlogik; Architekturtests verhindern verbotene Abhängigkeiten.
- Querbezüge: FA003;FA033;NFA021

### NFA003 · Flutter, Clean Architecture und lokale Datenbank

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Android, iOS und Web werden aus einer Flutter-Codebasis entwickelt. Präsentation, Use Cases, Domäne und Infrastruktur sind getrennt. Isar ist die gesetzte lokale Datenbank für mobile Plattformen; Zugriff erfolgt ausschließlich über Repository-Ports.
- Abnahme: Architekturregeln sind statisch getestet. Ein Web-Spike bestätigt bis Ende August 2026 den produktionsreifen Isar-Pfad; andernfalls greift der freigegebene IndexedDB/Drift-Adapter ohne Domänenänderung.
- Querbezüge: FA041;FA044;NFA019

### NFA004 · Versionierte und dokumentierte API

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: Die öffentliche App-API ist unter /v1 versioniert und mit OpenAPI 3.1 beschrieben. Breaking Changes erfordern neue Hauptversion und definierte Übergangsfrist.
- Abnahme: CI validiert Spezifikation und Implementierung; generierte Clients bauen reproduzierbar und Contract-Tests laufen gegen Staging.
- Querbezüge: FA017;NFA023

### NFA005 · Antwortzeiten und Ressourceneffizienz

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: Gecachte Inhaltsabfragen erreichen serverseitig p95 unter 500 ms, schreibende Standardaufrufe p95 unter 800 ms; lokale Navigation reagiert in der Regel unter 100 ms. PlantNet-Zeit zählt getrennt und blockiert die UI nicht.
- Abnahme: Lasttest mit Zielprofil aus Abschnitt sec:load erfüllt Grenzwerte; App-Start, Paketgröße, Speicher und Akkuverbrauch werden pro Release überwacht.
- Querbezüge: FA016;FA031;FA045

### NFA006 · Horizontale Skalierbarkeit

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: API und Worker sind zustandsarm und horizontal skalierbar. Medien liegen außerhalb der App-Container; Sessions sind tokenbasiert; Hintergrundaufträge verwenden eine persistente Queue.
- Abnahme: Zwei API-Instanzen und zwei Worker verarbeiten parallele Last ohne doppelte Identifikationen oder Datenverlust; Kapazität kann ohne App-Update erhöht werden.
- Querbezüge: FA033;FA043

### NFA007 · Verfügbarkeit

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: Für den MVP gilt ein monatliches Verfügbarkeitsziel von 99,5 % für App-API und Adminsystem, ausgenommen angekündigte Wartung. Offline-Lernfunktionen bleiben bei Serverausfall verfügbar.
- Abnahme: Monitoring berechnet SLI/SLO; ein simulierter API-Ausfall zeigt Offline-Inhalte und stellt ausstehende Synchronisation später wieder her.
- Querbezüge: FA041;FA043;NFA024

### NFA008 · Datensicherung und Wiederanlauf

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: PostgreSQL, Objektspeicher, Konfiguration und Schlüsselmaterial werden gesichert. Zielwerte: RPO höchstens 24 Stunden, RTO höchstens 8 Stunden im MVP; Wiederherstellung wird mindestens quartalsweise getestet.
- Abnahme: Ein dokumentierter Restore in isolierter Umgebung stellt konsistente Daten und stichprobenartig geprüfte Medien innerhalb des RTO wieder her.
- Querbezüge: FA036;FA054;NFA026

## Sicherheit und Datenschutz

### NFA009 · Sichere Authentifizierung und Transportverschlüsselung

- Priorität: **MUSS**
- Primärrolle: `auth-manager`
- Beschreibung: Alle externen Verbindungen nutzen TLS; mobile Anmeldung verwendet Authorization Code Flow mit PKCE. Passwörter, Tokens und Schlüssel werden nicht geloggt. Administrative Konten unterstützen Mehrfaktor-Authentifizierung.
- Abnahme: Dynamischer Sicherheitstest findet keine Klartextübertragung; Tokenablauf, Refresh, Widerruf und MFA sind in Integrationstests abgedeckt.
- Querbezüge: FA001;FA008;NFA011

### NFA010 · Secure Development Lifecycle

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Bedrohungsmodell, Code Review, SAST, Dependency-/Container-Scan, Secret-Scan, DAST und Penetrationstest vor Go-live orientieren sich an OWASP MASVS/ASVS. Kritische Befunde blockieren Releases.
- Abnahme: CI erzeugt nachvollziehbare Berichte; vor Go-live sind keine offenen kritischen/hohen Befunde ohne formale Risikoakzeptanz vorhanden.
- Querbezüge: FA006;NFA001;NFA023

### NFA011 · Geheimnis- und Schlüsselmanagement

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: PlantNet-Key, OIDC-Secrets, Signierschlüssel und Datenbankpasswörter liegen in geschütztem Secret Management, nicht im Repository, Client oder Image. Rotation ist dokumentiert.
- Abnahme: Secret-Scan bleibt leer; Rotation eines Testschlüssels ist ohne Downtime und ohne App-Release möglich.
- Querbezüge: FA033;FA063;NFA009

### NFA012 · Privacy by Design und DSGVO

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Datenverarbeitung folgt Zweckbindung, Minimierung, Transparenz, Speicherbegrenzung und Betroffenenrechten. Datenschutz-Folgenabschätzung wird wegen Foto-, Standort-, Minderjährigen- und Forschungsbezug früh geprüft.
- Abnahme: Verzeichnis der Verarbeitungstätigkeiten, Löschkonzept, Berechtigungskonzept, Datenschutzhinweise und ggf. DSFA sind vor Pilot freigegeben; Betroffenenrechte sind getestet.
- Querbezüge: FA005;FA009;FA070;FA074

### NFA013 · Schutz Minderjähriger

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Anmeldung, Einwilligung, Kommunikation, Analytik und Standortdaten berücksichtigen Minderjährige. Es gibt keine verhaltensmanipulativen Dark Patterns, öffentliche Profile oder standardmäßig sichtbare Fundorte.
- Abnahme: Rechts- und Datenschutzprüfung bestätigt Alters-/Einwilligungsfluss für die Zielgruppen; UX-Test mit geeigneten Vertretungen prüft Verständlichkeit.
- Querbezüge: FA005;FA032;NFA012

### NFA014 · Standort- und Artenschutz

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Exakte Fundorte sind privat, verschlüsselt übertragen und in Export/Analytik standardmäßig entfernt oder vergröbert. Für gefährdete Arten kann die Anzeige unabhängig vom Nutzerstandort zusätzlich maskiert werden.
- Abnahme: Berechtigungstests verhindern Organisations-/Adminzugriff ohne Zweck; öffentliche/aggregierte Ausgabe unterschreitet definierte Genauigkeit.
- Querbezüge: FA032;FA039;NFA012

### NFA015 · Datenresidenz und Auftragsverarbeitung

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Primäre App-, Identitäts-, Datenbank-, Backup- und Mediendaten werden in Deutschland oder EU/EWR betrieben. Externe Übermittlungen, insbesondere PlantNet und Social Login, werden dokumentiert und rechtlich bewertet.
- Abnahme: Architektur- und Anbieterregister nennt Ort, Rolle, Vertrag, Datenkategorien und Löschung; erforderliche AV-Verträge/Transfergrundlagen liegen vor.
- Querbezüge: FA002;FA033;NFA012

## Qualität, Zugänglichkeit und Betrieb

### NFA016 · Barrierefreiheit

- Priorität: **MUSS**
- Primärrolle: `ux-accessibility`
- Beschreibung: App und Administration zielen auf WCAG 2.2 AA bzw. EN 301 549: semantische Beschriftung, Screenreader, Tastatur, Kontrast, Textvergrößerung, Fokus, reduzierte Bewegung und Alternativen zu Farbe/Bild.
- Abnahme: Automatisierte Prüfungen plus manueller Test zentraler Flows mit Screenreader und Tastatur bestehen; bekannte Ausnahmen sind dokumentiert und priorisiert.
- Querbezüge: FA015;FA020;NFA017

### NFA017 · Usability in Lern- und Feldsituation

- Priorität: **MUSS**
- Primärrolle: `ux-accessibility`
- Beschreibung: Kernaufgaben sind mit einer Hand, bei wechselndem Licht und instabiler Verbindung verständlich. Navigation, Systemstatus, Unsicherheit und nächste Schritte sind sichtbar.
- Abnahme: Mindestens zwei formative Tests und ein Feldpilot zeigen: 80 % der Testpersonen schließen Kernaufgaben ohne Hilfe ab; kritische Probleme sind vor Go-live behoben.
- Querbezüge: FA020;FA030;FA035

### NFA018 · Internationalisierung

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: UI und Inhalte unterstützen UTF-8, variable Textlängen, sprachabhängige Namen, Pluralformen, Datum/Zeit und später Rechts-nach-links-Layout. Sprache ist nicht Teil von IDs.
- Abnahme: Pseudo-Lokalisierung erzeugt keine abgeschnittenen Kerntexte; Locale-Wechsel erhält Fortschritt und Taxonzuordnung.
- Querbezüge: FA014;NFA016

### NFA019 · Plattformkompatibilität

- Priorität: **MUSS**
- Primärrolle: `qa-playwright`
- Beschreibung: Unterstützt werden die jeweils zwei aktuellen Hauptversionen von Android und iOS sowie aktuelle stabile Versionen von Chrome, Firefox, Safari und Edge. Exakte Mindestversionen werden vor Beta festgelegt.
- Abnahme: Geräte-/Browsermatrix wird in CI und manueller Abnahme ausgeführt; Kamera, OIDC, Offline-Speicher und Datei-Export sind enthalten.
- Querbezüge: NFA003;NFA023

### NFA020 · Offline-Robustheit

- Priorität: **MUSS**
- Primärrolle: `flutter-frontend`
- Beschreibung: Netzwechsel, Prozessabbruch, Speicherknappheit und doppelte Zustellung dürfen keine persönlichen Daten beschädigen. Lokale Migrationen sind versioniert und rückwärts getestet.
- Abnahme: Fehlerinjektionstests decken Abbruch an Synchronisationsgrenzen ab; Datenbankmigration von zwei Vorversionen bleibt verlustfrei.
- Querbezüge: FA041;FA044;NFA003

### NFA021 · Wartbarkeit und Erweiterbarkeit

- Priorität: **MUSS**
- Primärrolle: `orchestrator`
- Beschreibung: Domänenmodelle, Adapter, Use Cases und UI-Komponenten sind klar benannt, dokumentiert und klein genug für unabhängige Tests. Neue Quiztypen und Identifikationsadapter besitzen definierte Erweiterungspunkte.
- Abnahme: Ein prototypischer zusätzlicher Quiztyp wird ohne Änderung bestehender Typen integriert; Code-Coverage und Komplexitätsgrenzen werden in CI überwacht.
- Querbezüge: FA052;NFA002;NFA027

### NFA022 · Automatisierte Tests

- Priorität: **MUSS**
- Primärrolle: `qa-playwright`
- Beschreibung: Unit-, Widget-, Integrations-, Contract-, Migrations- und End-to-End-Tests decken Kernpfade ab. Kritische Domänenlogik erreicht mindestens 90 % Branch Coverage; Gesamtwerte sind kein Selbstzweck.
- Abnahme: Pipeline blockiert bei fehlschlagenden Tests; Testpyramide und bewusst ausgeschlossene Bereiche sind dokumentiert.
- Querbezüge: FA024;FA034;FA044;NFA023

### NFA023 · GitLab CI/CD

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: GitLab-Pipelines prüfen Format, Analyse, Tests, Sicherheit und Lizenzen, bauen reproduzierbar Android/iOS/Web und deployen Backend/Infrastruktur über Staging nach Produktion mit Freigabe.
- Abnahme: Ein Release Candidate wird aus einem Tag vollständig reproduziert; Produktionsdeploy besitzt Freigabe, Migration, Smoke-Test und dokumentierten Rollback.
- Querbezüge: NFA004;NFA010

### NFA024 · Monitoring und Diagnose

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: Metriken, strukturierte Logs und Traces überwachen API, Queue, Datenbank, Speicher, Auth, Synchronisation und PlantNet-Quote. Personenbezogene Inhalte und Tokens werden nicht geloggt.
- Abnahme: Dashboards und Alarme erkennen Ausfall, erhöhte Fehlerrate, Queue-Stau, Quotenknappheit und Speicherwachstum; ein Alarmtest erreicht den Bereitschaftskanal.
- Querbezüge: FA033;FA057;NFA007

### NFA025 · Auditierbarkeit

- Priorität: **MUSS**
- Primärrolle: `security-privacy`
- Beschreibung: Administrative und sicherheitskritische Änderungen sind nachvollziehbar, zeitlich synchronisiert und gegen normale Bearbeitung geschützt. Audit ersetzt keine übermäßige Überwachung von Lernenden.
- Abnahme: Stichprobe rekonstruiert Veröffentlichung und Rollenänderung; Zugriffe auf Auditdaten sind selbst berechtigt und protokolliert.
- Querbezüge: FA059;NFA012

### NFA026 · Portabilität und Anbieterwechsel

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: Daten, Medien und Konfiguration können in offenen Formaten exportiert und auf einer frischen Open-Source-Installation wiederhergestellt werden. Infrastruktur ist als Code dokumentiert.
- Abnahme: Jährlicher Exit-Test baut eine isolierte Instanz aus Repository, Backup und Dokumentation ohne proprietären Cloud-Dienst auf.
- Querbezüge: FA062;NFA001;NFA008

### NFA027 · Dokumentation

- Priorität: **MUSS**
- Primärrolle: `orchestrator`
- Beschreibung: Repository enthält Architekturentscheidungen, lokale Einrichtung, Datenmodell, API, Betrieb, Backup/Restore, Release, Sicherheit, Datenschutz, Redaktion und Contribution.
- Abnahme: Eine neue Entwickler:in startet die Kernumgebung anhand der Dokumentation; Redaktion veröffentlicht ein Testlevel ohne Entwicklerhilfe.
- Querbezüge: FA053;NFA004;NFA021

### NFA028 · Fachliche Inhaltsqualität

- Priorität: **MUSS**
- Primärrolle: `content-data`
- Beschreibung: Veröffentlichte botanische Inhalte sind quellenbasiert, versioniert, mit Vier-Augen-Review und klarer Trennung zwischen Fakten, Merkhilfen und Sicherheitshinweisen. Generative Vorschläge werden nie ungeprüft veröffentlicht.
- Abnahme: Jeder MVP-Steckbrief und jede Quizfrage besitzt Reviewstatus und Quelle; Stichprobe bestätigt Taxonomie, Lösung und Bildzuordnung.
- Querbezüge: FA013;FA051;FA054

### NFA029 · Nachhaltiger Betrieb

- Priorität: **SOLL**
- Primärrolle: `devops-release`
- Beschreibung: Mediengrößen, Cache, Aufbewahrung und Infrastruktur werden so dimensioniert, dass Energie- und Speicherbedarf ohne Verlust des Bildungswerts begrenzt bleiben.
- Abnahme: Betriebsdashboard weist Datenvolumen pro aktiver Nutzer:in, CDN-/Cachequote und Löschwirkung aus; unnötige Originalduplikate werden vermieden.
- Querbezüge: FA045;FA074

### NFA030 · Resilienz externer Identifikation

- Priorität: **MUSS**
- Primärrolle: `backend-api`
- Beschreibung: PlantNet-Aufrufe verwenden Timeout, begrenzte Retries mit Backoff, Circuit Breaker, Queue, Quotenreserve und verständlichen Fallback. Der App-Kern bleibt ohne PlantNet verfügbar.
- Abnahme: Simulierter Ausfall/HTTP 429 überlastet weder API noch Provider; Aufträge bleiben nachvollziehbar und werden nach Freigabe kontrolliert fortgesetzt.
- Querbezüge: FA033;FA035;NFA024

### NFA031 · Store- und Release-Konformität

- Priorität: **MUSS**
- Primärrolle: `devops-release`
- Beschreibung: App-Datenschutzangaben, Berechtigungsbegründungen, Account-Löschung, Sign-in-with-Apple-Anforderungen, Altersfreigabe und Store-Metadaten werden je Release gepflegt.
- Abnahme: Android- und iOS-Release bestehen interne Store-Prüfung; Berechtigungen entsprechen tatsächlich genutzten Funktionen.
- Querbezüge: FA002;FA009;FA032;NFA023

### NFA032 · Offene Governance und klar getrennte Rollen

- Priorität: **MUSS**
- Primärrolle: `orchestrator`
- Beschreibung: Entscheidungsrechte, Ernennung, Amtszeit, Vertretung, Interessenkonflikte und Eskalationswege für Steering Committee, technische und fachliche Maintainer, Security- und Release-Rollen sind öffentlich dokumentiert. Ein öffentlicher Beitrag begründet weder Produktionszugriff noch automatische Veröffentlichung.
- Abnahme: GOVERNANCE.md, MAINTAINERS.md, Code of Conduct und Entscheidungsprotokoll sind vorhanden; eine beispielhafte Code-, Inhalts- und Sicherheitsänderung durchläuft jeweils den vorgesehenen Weg mit dokumentierter Freigabe.
- Querbezüge: NFA001;NFA010;NFA025;NFA027
