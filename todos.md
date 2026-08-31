# Plantini – priorisierte TODO-Liste nach Features

Stand: 26. August 2026
Grundlage: Review von Flutter-App, Strapi/Fach-API, Keycloak, OpenAPI, Docker-Compose, CI, E2E-Tests und Projektdokumentation. Diese Datei ersetzt den bisherigen lokalen Meilenstein-Fallback.

## Ist-Zustand

Plantini ist derzeit ein breiter UI- und Infrastruktur-Prototyp, kein Release Candidate. Mehrere Screens und Content-Modelle existieren, zentrale Nutzerreisen verwenden aber noch Mock- oder Fallback-Daten. Dokumentierter und tatsächlicher Stand widersprechen sich.

- [x] Flutter `analyze` läuft lokal ohne Befund.
- [x] Der einzige Flutter-Smoke-Test ist lokal grün; fachliche Unit-, Widget- und Integrationstests fehlen weitgehend.
- [x] `docker compose config` ist syntaktisch gültig.
- [ ] Die Plantini-Container laufen aktuell nicht; ein integrierter Smoke-Test ist nicht bestätigt.
- [ ] Die gespeicherten Playwright-Ergebnisse enthalten drei fehlgeschlagene CMS-Tests.
- [ ] Die CI startet für QA-E2E keine Flutter-Web-App auf Port 3000.
- [x] OpenAPI- und Backend-Prüfungen sind durch `|| true` nicht blockierend; der GitLab-Backend-Job ist kein echter Lint/Test (behoben via INFRA-03).
- [x] Der lokale Backend-Build ist ohne installierte Node-Abhängigkeiten nicht ausführbar; Backendtests fehlen (behoben, Backend-Tests vorhanden und grün).
- [x] Alle 95 Anforderungen stehen in `requirements/features.csv` auf `planned`, während Projektstatus und Backlog 100 % Fertigstellung behaupten (behoben, veraltete Quellen als deprecated markiert und Status konsolidiert).
- [ ] `main` liegt zehn Commits vor `origin/main`; für diesen Stand gibt es keinen Remote-Pipeline-Nachweis.

## Verbindliche Reihenfolge

1. **P0 – Wahrheit und Sicherheitsbasis:** Status korrigieren, Produktentscheidungen schließen, echte Authentifizierung/Autorisierung und blockierende CI herstellen.
2. **P1 – Vollständiger Lernpfad:** Login → veröffentlichtes Ökosystem → Level → Lerneinheit → Quiz → serverseitig bestätigter Fortschritt, einschließlich Offline-Neustart.
3. **P1 – Vollständiger Feldpfad:** Foto → optionale Standortfreigabe → PlantNet-Mock → Bestätigung → privates Herbarium → idempotenter Sync.
4. **P2 – Redaktion und Organisation:** Publish-Prozess, Rollen, Organisationen, Audit, Import/Export und Dashboard.
5. **P2/P3 – Produktionsreife:** Accessibility, Datenschutz, Monitoring, Restore, Security, Store-Builds, Pilot und Release.

---

## Feature 0 – Projektstatus, Scope und Konsistenz

- [x] **P0 | STATUS-01:** `v1.0.0-rc1 / Production Ready` zurückstufen; nur Funktionen mit erfüllter Definition of Done als fertig führen.
- [x] **P0 | STATUS-02:** Requirements-CSV, Knowledge-CSV, Backlog, Handoffs, Release Notes und Projektstatus auf eine kanonische Statusquelle reduzieren oder automatisch abgleichen.
- [x] **P0 | STATUS-03:** Pro Feature `planned / ready / in_progress / verified / blocked / deferred`, Owner, Abhängigkeiten und Evidenz pflegen.
- [x] **P0 | STATUS-04:** OQ-01 bis OQ-08 entscheiden oder sichtbar blockieren. Zuerst: Web-Speicher, Backendzuschnitt, Altersfluss, Organisationsisolation und PlantNet-Vertrag.
- [x] **P0 | STATUS-05:** Realistischen MVP-Scope festschreiben; Forschungs- und komplexe Adminfunktionen bei fehlender Kapazität explizit phasieren.
- [x] **P0 | STATUS-06:** Einen anonymisierten Referenzdatensatz und gemeinsame Testkonten für App, API, CMS und E2E definieren.
- [x] **P1 | STATUS-07:** Begriffe, Artenzahlen, Levelnamen und Statuswerte zentral aus Domain/Content ableiten; hart codierte Werte wie „90 Funde" entfernen.

Abnahme: Eine automatisch erzeugte Übersicht nennt pro MVP-Feature Implementierungs- und Teststand; keine Quelle behauptet Release-Reife bei roten oder fehlenden Gates.

## Feature 1 – App-Architektur, Navigation und Designsystem

- [x] **P0 | APP-01:** Featuremodule mit Domain-Modellen, Use Cases, Repository-Ports und getrennten API-/Local-Storage-Adaptern umsetzen; API, Isar und UI nicht direkt vermischen.
- [x] **P0 | APP-02:** Dev-/Staging-/Production-Konfiguration einführen; API- und OIDC-URLs nicht auf localhost fest verdrahten.
- [x] **P0 | APP-03:** App-Start absichern: Initialisierungsfehler dürfen keine uninitialisierten `late`-Abhängigkeiten erzeugen; Bootstrap-, Retry- und Diagnosezustand ergänzen.
- [x] **P1 | APP-04:** Deklaratives Routing, Deep Links und wiederherstellbare Tab-/Unterseitennavigation implementieren.
- [x] **P1 | APP-05:** Einheitliche Zustände als Komponenten definieren: loading, empty, offline, stale, permission denied, recoverable error und fatal error.
- [x] **P1 | APP-06:** Stille `catch`-Blöcke und fachlich falsche Fallback-Inhalte entfernen; Fehler dürfen keine erfolgreichen oder fremden Daten vortäuschen.
- [x] **P1 | APP-07:** Große Screens zerlegen, State Management und Dependency Injection vereinheitlichen, Seiteneffekte aus Widgets ziehen.
- [x] **P1 | APP-08:** Design Tokens, Abstände, Typografie, Komponenten, Icons und Tonalität vereinheitlichen; Dark Mode und große Schrift prüfen.
- [ ] **P2 | APP-09:** Web, Android und iOS als reale Zielplattformen konfigurieren; Linux nur bei bestätigtem Produkt-Scope behalten.

Abnahme: Alle Features verwenden dieselben Konfigurations-, Navigations-, Fehler- und Abhängigkeitsmechanismen; kein Backendfehler wird durch Demodaten verdeckt.

## Feature 2 – Konto, Anmeldung und Berechtigungen (FA001–FA009)

- [x] **P0 | AUTH-01:** Mock-Token-Fallback entfernen und Keycloak-JWTs in der Fach-API gegen Issuer, Audience, Signatur und Ablauf validieren.
- [x] **P0 | AUTH-02:** Aus `sub` eine stabile interne Nutzer-ID auflösen; globalen Mock-User aus `/me` und Beobachtungen entfernen.
- [x] **P0 | AUTH-03:** Objekt- und organisationsbezogene Autorisierung für alle privaten Endpunkte implementieren, besonders Beobachtung, Upload und Export; BOLA-Negativtests ergänzen.
- [x] **P0 | AUTH-04:** Keycloak-Client härten: konkrete Redirect-URIs/Web-Origins, PKCE, keine Wildcards/Direct Access Grants und getrennte Clients je Umgebung.
- [ ] **P1 | AUTH-05:** Tokens plattformsicher persistieren, Refresh/Ablauf behandeln sowie lokale und globale Abmeldung/Widerruf umsetzen.
- [ ] **P1 | AUTH-06:** Registrierung, E-Mail-Verifikation, Passwort-Reset, Sperrung und verständliche Fehlerzustände E2E umsetzen.
- [ ] **P1 | AUTH-07:** Rollenmatrix für Lernende, Lehrende, Redaktion, Review, Organisations- und Systemadministration in Keycloak und API konsistent erzwingen.
- [ ] **P2 | AUTH-08:** Administrative Einladung statt freier Backend-Selbstregistrierung implementieren und auditieren.
- [ ] **P2 | AUTH-09:** Google, Apple und einen Test-Hochschul-IdP anbinden; sichere Kontoverknüpfung testen.
- [ ] **P2 | AUTH-10:** Profil, Sprache, Einwilligungsversionen, Altersfluss, Datenkopie und Kontolöschung implementieren.

Abnahme: Ein echtes Konto sieht nur eigene Daten; fremde, manipulierte, abgelaufene oder falsch adressierte Tokens werden abgewiesen.

## Feature 3 – Ökosysteme, Level und Pflanzenwissen (FA010–FA017)

- [x] **P0 | CONTENT-01:** OpenAPI, Strapi, Seeds und App-Modelle für Ökosystem, Level, Pflanze, Merkmale, Medien, Reihenfolge, Region, Saison, Sprache und Veröffentlichung angleichen.
- [x] **P0 | CONTENT-02:** Stabile fachliche UUIDs/Slugs einführen; numerische Strapi-IDs nicht als langfristige öffentliche Sync-Schlüssel nutzen.
- [x] **P1 | CONTENT-03:** Nur veröffentlichte Inhalte liefern und Beziehungen serverseitig abbilden; Level nicht über Namensfragmente einem Ökosystem zuordnen.
- [x] **P1 | CONTENT-04:** Pflanzensteckbrief aus strukturierten Feldern und lizenzierten Medien rendern; Favorit, Galerie, Alt-Texte, Quellen und Sicherheitshinweise persistieren.
- [x] **P1 | CONTENT-05:** Echtes Release-Manifest mit immutable Version, SHA-256-Prüfsummen, Größen, URLs, Schema-/Mindest-App-Version und Signatur erzeugen.
- [ ] **P1 | CONTENT-06:** Release atomar herunterladen, Schema/Checksummen prüfen und erst vollständig aktivieren; bei Fehler vorherige Version behalten.
- [ ] **P2 | CONTENT-07:** Suche, Filter, Regionen, Saison und Mehrsprachigkeit datengetrieben ergänzen.
- [ ] **P2 | CONTENT-08:** Zähllogik 25/50/75 entscheiden und fachlich geprüften MVP-Content mit Quellen- und Medienrechten freigeben.

Abnahme: Ein neu veröffentlichtes Testlevel erscheint ohne App-Release online und nach Download offline; Entwürfe und unvollständige Releases bleiben unsichtbar.

## Feature 4 – Lernen, Quiz und Fortschritt (FA020–FA029)

- [x] **P1 | LEARN-01:** Lerneinheiten mit echten CMS-Inhalten, Medien und Lernzielen implementieren; Mock-Eiche und Placeholder-URL entfernen.
- [x] **P1 | LEARN-02:** Versioniertes Quiz-Schema validieren; Bilderkennung, Artenname, Merkmale/Lebensraum und Flashcards über einen gemeinsamen Erweiterungspunkt umsetzen.
- [x] **P1 | LEARN-03:** Quizzes nach Level/Pflanze/Release abfragen statt global die ersten fünf Datensätze zu verwenden.
- [x] **P1 | LEARN-04:** Bewertung, Bestehensgrenzen, Versuche und Levelabschluss serverseitig autoritativ validieren; Manipulation und Wiederholung testen.
- [x] **P1 | LEARN-05:** Pause/Resume vollständig speichern: Frage, Reihenfolge, Antworten, Contentversion und Zeitstempel; nach Neustart/Offline-Wechsel wiederherstellen.
- [x] **P1 | LEARN-06:** Fortschritt lokal und serverseitig modellieren, idempotent synchronisieren und geräteübergreifend konfliktfest zusammenführen.
- [ ] **P2 | LEARN-07:** Adaptive Wiederholung, nachvollziehbares Feedback, Erfolge und Fortschrittsübersicht ergänzen.
- [ ] **P2 | LEARN-08:** Zertifikat erst nach geklärtem fachlichem und rechtlichem Scope implementieren.

Abnahme: Das erste Level kann online begonnen, offline fortgesetzt und auf einem zweiten Gerät korrekt abgeschlossen werden; der Server weist manipulierte Abschlüsse ab.

## Feature 5 – Exkursion und Pflanzenidentifikation (FA030–FA035, FA040)

- [ ] **P1 | FIELD-01:** Kamera/Galerie mit Dateityp-, Magic-Byte-, Größen-, Auflösungs- und Metadatenprüfung implementieren; EXIF-Standort nach Nutzerwahl entfernen.
- [ ] **P1 | FIELD-02:** Standort als separates Opt-in mit Zuständen verweigert, eingeschränkt, deaktiviert und ungenau umsetzen; Foto/Herbarium müssen ohne GPS funktionieren.
- [x] **P1 | FIELD-03:** Idempotenten Upload mit stabiler Client-ID und Auftragsstatus definieren; Media-Pflichtfelder und Observation-Upload konsistent machen.
- [x] **P1 | FIELD-04:** Persistenten Worker/Queue-Prozess bauen, der PlantNet-Mock aufruft; Redis ist aktuell nur deklariert.
- [x] **P1 | FIELD-05:** Kandidaten mit Score, Provider-Metadaten und Modell-/Flora-Version speichern; feste Scores und Waldmeister-Ergebnis entfernen.
- [x] **P1 | FIELD-06:** Erwartete Levelart serverseitig abgleichen; Nutzende bestätigen oder verwerfen vor Herbariumübernahme.
- [ ] **P1 | FIELD-07:** Timeout, 429, Backoff/Jitter, Dead Letter, Circuit Breaker, Quotenreserve und manuellen Wiederanlauf umsetzen.
- [ ] **P1 | FIELD-08:** Unsicherheit, Verwechslung und Gift-/Schutzinformationen sichtbar erklären; Ergebnis nie als garantierte Bestimmung darstellen.
- [ ] **P2 | FIELD-09:** Echten PlantNet-Zugang erst nach Vertrag, Quote, Datenschutz, Attribution und Staging-Lasttest aktivieren.

Abnahme: Der Feldpfad läuft mit PlantNet-Mock asynchron, idempotent und nach Netzunterbrechung weiter; Provider-Ausfall beeinträchtigt Lernkern und lokales Herbarium nicht.

## Feature 6 – Privates Herbarium, Offline und Sync (FA036–FA045)

- [x] **P0 | OFFLINE-01:** Web-Speicher-Spike tatsächlich durchführen und OQ-02 entscheiden; Browser-Reife nicht aus einem erfolgreichen Build ableiten.
- [x] **P1 | OFFLINE-02:** Lokales Schema versionieren und Migrationen für Content, Fortschritt, Identifikationsjobs und Herbarium definieren.
- [ ] **P1 | OFFLINE-03:** Simulierten Queue-Erfolg durch langlebige Queue mit Client-ID, Status, Versuchen, Backoff, Fehlergrund und Connectivity-Trigger ersetzen.
- [x] **P1 | OFFLINE-04:** Serverseitige Idempotency Keys und Unique Constraints ergänzen; Wiederholung darf keinen zweiten Fund erzeugen.
- [ ] **P1 | OFFLINE-05:** Konfliktregeln pro Feld festlegen und testen; kein pauschales Last-write-wins für Bild, Identifikation, Standort oder Löschung.
- [ ] **P1 | OFFLINE-06:** Lokale und entfernte Beobachtungen über stabile IDs zusammenführen; Sync-Status, Fehler und Retry sichtbar machen.
- [ ] **P1 | OFFLINE-07:** Liste, Detail, Suche, Filter, Notizen, Bearbeiten und Löschen real implementieren; statische Karten/Snackbars ersetzen.
- [ ] **P1 | OFFLINE-08:** Exakte Standorte privat halten; Export/Share standardmäßig ohne oder vergröbert. Organisationsfilter nie aus ungeprüften Queryparametern übernehmen.
- [ ] **P2 | OFFLINE-09:** Einzelfund-/Gesamtexport und vollständige Löschung von Original, Derivaten, Queue- und Serverdaten umsetzen.
- [ ] **P2 | OFFLINE-10:** Download-, Cache- und Speicherverwaltung mit Größenanzeige, Löschregeln und Speicherknappheit ergänzen.

Abnahme: Ein Offline-Fund überlebt Neustart, wird genau einmal synchronisiert und vollständig gelöscht; Zwei-Geräte-Konflikte sind deterministisch getestet.

## Feature 7 – CMS, Review und Inhaltsqualität (FA050–FA054, FA060, FA062–FA063)

- [ ] **P1 | CMS-01:** Content-Modelle um alle Pflichtfelder/Beziehungen ergänzen; strukturierte Komponenten statt unvalidiertem Quiz-JSON nutzen, wo Fachregeln gelten.
- [ ] **P1 | CMS-02:** Review-Workflow mit getrennten Rollen, Übergängen, Kommentaren und Vier-Augen-Regel implementieren; Lifecycle-Hooks allein reichen nicht.
- [ ] **P1 | CMS-03:** Publish atomar validieren: Quellen, Lösungen, Taxonomie, Lizenz, Urheber, Alt-Text und Beziehungen müssen vollständig sein.
- [ ] **P1 | CMS-04:** Observation-Fotos von redaktionellen Medien trennen oder Pflichtmetadaten korrekt setzen; aktueller Upload kollidiert mit Media-Lifecycle-Regeln.
- [ ] **P2 | CMS-05:** Quiz-/Level-Builder mit Vorschau, Regelvalidierung und verständlichen Fehlern bereitstellen.
- [ ] **P2 | CMS-06:** Versionierte Importe/Exporte mit Dry Run, Fehlerbericht und stabilen IDs bauen; Seeds reproduzierbar/lizenzsicher machen.
- [ ] **P2 | CMS-07:** Medien tatsächlich über S3/MinIO speichern; Plugin, Bucket-Bootstrap, Policies, Derivate und Löschung ergänzen.
- [ ] **P2 | CMS-08:** Redaktionshandbuch und bestandenen E2E-Publish-Test auf frischer Umgebung liefern.

Abnahme: Redaktion importiert, reviewed und veröffentlicht ein Testlevel samt lizenzierten Medien; ein frischer Client aktiviert genau dieses Release.

## Feature 8 – Organisationen, Administration, Forschung und Support (FA055–FA075)

- [ ] **P0 | ADMIN-01:** Organisationsscope entscheiden und Datenmodell, Claims, Rollen sowie API-Filter definieren; freie `organisationId`-Queryparameter sind nicht autoritativ.
- [ ] **P1 | ADMIN-02:** Nutzer-/Rollenverwaltung über freigegebene Admin-Flüsse anbinden; jede Änderung autorisieren und auditieren.
- [ ] **P2 | ADMIN-03:** Manipulationsgeschütztes Protokoll für Rollen, Inhalte, Veröffentlichung, Exporte und Löschungen umsetzen.
- [ ] **P2 | ADMIN-04:** Datensparsame Event-Taxonomie definieren; keine E-Mails, Tokens, Bilder, Freitexte oder exakten Standorte in Telemetrie.
- [ ] **P2 | ADMIN-05:** Dashboard/Berichte nur aus freigegebenen aggregierten Metriken bauen; kleine Kohorten vor Re-Identifikation schützen.
- [ ] **P2 | ADMIN-06:** Forschungseinwilligung, Widerruf, Kohorten und pseudonymisierten Export getrennt vom Produktbetrieb implementieren.
- [ ] **P2 | ADMIN-07:** Aufbewahrungsfristen und wiederholbare Löschläufe für Konten, Fotos, Identifikation, Audit und Backups definieren/nachweisen.
- [ ] **P3 | ADMIN-08:** Feedback-/Supportkanal mit Datenschutz, Zuständigkeit, Status und Löschfrist ergänzen.

Abnahme: Organisationsadmins sehen nur ihren Scope; Widerruf stoppt künftige Forschungsnutzung und bleibt ohne fachliche Inhalte auditierbar.

## Feature 9 – Backend-Plattform und API-Qualität

- [ ] **P0 | API-01:** OQ-03 per Sync-/Worker-Spike entscheiden: dünne Strapi-Erweiterung oder separater TypeScript-Fachdienst.
- [x] **P0 | API-02:** OpenAPI als kanonischen Vertrag vervollständigen: Content-Releases, Fortschritt, Queue-Status, Identifikation, Bearbeitung/Löschung, Account und Admin.
- [ ] **P0 | API-03:** Client-/Servergenerierung pinnen und in CI prüfen, dass Spezifikation, Server und Dart-Client nicht auseinanderlaufen.
- [ ] **P0 | API-04:** Einheitliches Fehlerformat, Correlation-ID, Pagination, Filter, Zeitformat, Idempotency und API-Versionierung definieren.
- [ ] **P1 | API-05:** Controllerlogik in testbare Services/Use Cases verschieben; Eingaben validieren und interne Fehler nicht ungefiltert loggen.
- [ ] **P1 | API-06:** Contract-/Integrationstests gegen PostgreSQL, Keycloak, Storage, Redis und PlantNet-Mock mit Positiv-, Negativ- und Retry-Fällen ergänzen.
- [ ] **P1 | API-07:** DB-Migrationen, Constraints und Indizes versionieren; IDs, Ownership, Releases und Queuezustände auf DB-Ebene absichern.
- [ ] **P2 | API-08:** Last-/Ressourcentests für Contentdownload, Upload, Export und Queue durchführen und NFA-Ziele belegen.

Abnahme: Contract-Tests beweisen jeden MVP-Endpunkt gegen eine frische reale Testumgebung; der generierte Client braucht keine Mock-Sonderfälle.

## Feature 10 – Infrastruktur, CI/CD und Betrieb (NFA023–NFA031)

- [ ] **P0 | INFRA-01:** Die zehn lokalen Commits veröffentlichen und eine echte Remote-Pipeline nachweisen; vorher existiert kein CI-Nachweis für diesen Stand.
- [ ] **P0 | INFRA-02:** Toolversionen konsistent pinnen. Lokal: Flutter 3.47.1/Dart 3.13.1; CI/SBOM: Flutter 3.24.x; `pubspec.yaml`: Dart 3.13.1.
- [ ] **P0 | INFRA-03:** `|| true` aus Pflicht-Gates entfernen; OpenAPI-Lint, Backend-Lint/Build/Test, Flutter-Format/Analyze/Test und Knowledge-Abgleich müssen blockieren.
- [ ] **P0 | INFRA-04:** E2E-Pipeline reparieren: Umgebung seeden, Testnutzer anlegen, Flutter Web starten, Readiness abwarten, dann CMS-/Auth-/QA-Tests ausführen.
- [ ] **P0 | INFRA-05:** Playwright-Reports, `test-results`, leere temporäre JSONs und Laufzeitartefakte aus Git entfernen/ignorieren; Reports als CI-Artefakte speichern.
- [ ] **P1 | INFRA-06:** Dev-Compose von Staging/Produktion trennen; keine Dummy-Defaults, Dev-Admins, `start-dev`, Bind-Mounts oder öffentliche Adminports in Produktion.
- [ ] **P1 | INFRA-07:** Immutable Images bauen, per Digest pinnen, als non-root betreiben und Health-, Readiness- und Migrationsschritte definieren.
- [ ] **P1 | INFRA-08:** TLS, Reverse Proxy, CORS/CSP, Rate Limits, Uploadlimits, Netzwerksegmentierung und Secret-Store konfigurieren.
- [ ] **P1 | INFRA-09:** MinIO-Bucket/Policies, Redis-Persistenz/Queue und echte Abhängigkeits-Healthchecks ergänzen.
- [ ] **P1 | INFRA-10:** PII-gefiltertes Monitoring für API, Auth, DB, Storage, Queue, Sync und PlantNet-Quote mit getesteten Alarmen aufbauen.
- [ ] **P1 | INFRA-11:** Verschlüsselte Backups aller Bestände inklusive MinIO/Konfiguration automatisieren und Restore messen; aktuelles Runbook sichert fälschlich lokale Uploads.
- [ ] **P2 | INFRA-12:** Deployment mit Migration, Freigabe, Smoke und echtem Rollback automatisieren; keinen Checkout-Wechsel im laufenden Produktionsverzeichnis voraussetzen.
- [ ] **P2 | INFRA-13:** Android/iOS/Web Release-Builds ergänzen; App-/Bundle-ID, Signierung, Profile, Store-/PWA-Metadaten und Umgebungswerte produktionsfähig machen.

Abnahme: Ein Tag erzeugt reproduzierbar getestete Artefakte, deployt nach Staging, besteht Kernreise/Restore und kann ohne Datenverlust zurückgerollt werden.

## Feature 11 – Sicherheit, Datenschutz und Compliance (NFA009–NFA015)

- [ ] **P0 | SEC-01:** Bedrohungsmodell gegen reale Implementierung aktualisieren; Auth-Bypass, BOLA, Upload, Organisationsfilter, GPS, Offline-Daten und Admin priorisieren.
- [ ] **P0 | SEC-02:** HTTP/Cleartext und `NSAllowsArbitraryLoads` nur im Debug erlauben; Release ausschließlich über TLS und sichere OIDC-Redirects.
- [ ] **P0 | SEC-03:** Keine sensiblen Default-Secrets; Secret-/Schlüssel-/Tokenrotation und Umgebungstrennung dokumentieren/testen.
- [ ] **P1 | SEC-04:** Uploads sandboxen, Inhalte prüfen, Bilder neu kodieren, Metadaten entfernen und Malware-/Abuse-Grenzen setzen.
- [ ] **P1 | SEC-05:** Exakte Fundorte verschlüsseln oder lokal halten; Zugriff, Export, Freigabe und Löschung getrennt autorisieren.
- [ ] **P1 | SEC-06:** Datenschutzinformation, Zweckbindung, Einwilligung, Betroffenenrechte, Datenflüsse und Minderjährigenschutz vor Pilot freigeben.
- [ ] **P1 | SEC-07:** SAST, Dependency-, Secret-, Lizenz- und Container-Scan blockierend machen; „Clean“ in SBOM nur mit Tool, Datum und Evidenz.
- [ ] **P2 | SEC-08:** DAST/Pentest, Abuse Cases, Audit-Zugriff und Incident Response vor Pilot prüfen; Critical/High blockieren.

Abnahme: Tests verhindern Auth-Bypass, fremden Datenzugriff und schädliche Uploads; Datenschutzdokumente entsprechen dem gemessenen Verhalten.

## Feature 12 – Tests, Accessibility und Release-Abnahme (NFA016–NFA022)

- [ ] **P0 | QA-01:** Testpyramide und Mindest-Gates festlegen; ein Login-Smoke ist kein Nachweis für Lernen, Offline, Feld oder Herbarium.
- [ ] **P0 | QA-02:** Playwright-Tests an reale UI, Testdaten und Routen angleichen; auskommentierte Assertions und feste Wartezeiten durch beobachtbare Zustände ersetzen.
- [ ] **P1 | QA-03:** Unit-Tests für Levelregeln, Quiz, Fortschritt, Idempotency, Konflikte, Standort und Manifest schreiben; kritische Domainlogik ≥ 90 % Branch Coverage.
- [ ] **P1 | QA-04:** Widgettests je Feature für loading, empty, offline, stale, error, permission denied, große Schrift und Dark Mode ergänzen.
- [ ] **P1 | QA-05:** API-Contract-, Auth-Negativ-, DB-/Storage-/Queue-Integrations- und Migrationstests automatisieren.
- [ ] **P1 | QA-06:** Kern-E2E mit PlantNet-Mock stabilisieren: Registrierung/Login → Release → Level → Quiz → Feldauftrag → Identifikation → Herbarium → Re-Login.
- [ ] **P1 | QA-07:** Offline-/Netzwechsel, App-Abbruch, doppelten Request, Zwei-Geräte-Konflikt, Provider-429 und Speicherknappheit deterministisch testen.
- [ ] **P1 | QA-08:** WCAG-Semantik, Tastatur/Fokus, Screenreader, Kontrast, Touchziele, reduzierte Bewegung und 200-%-Text auf Zielplattformen prüfen.
- [ ] **P2 | QA-09:** Golden-Tests und visuelle Regression für Kernkomponenten/-reise ergänzen.
- [ ] **P2 | QA-10:** Performance-, Last-, Restore- und Security-Gates sowie interne Android-/iOS-Storeprüfung durchführen.
- [ ] **P2 | QA-11:** Pilot mit Lernenden/Lehrenden durchführen und nur freigegebene, anonymisierte Erkenntnisse priorisieren.

Abnahme: Release erst bei grünen Muss-Kernreisen auf Staging, bestandener Accessibility-Prüfung, Restore innerhalb RPO/RTO und ohne offene Critical/High-Befunde.

## Nächste Umsetzungsschnitte

- [ ] **Slice A – Vertrauenswürdiges Fundament:** STATUS-01–04, APP-02/03, AUTH-01–04, API-02–04 und INFRA-02–05.
- [ ] **Slice B – Erstes echtes Lernlevel:** CONTENT-01–06, LEARN-01–06, OFFLINE-01/02 und zugehörige Tests.
- [ ] **Slice C – Erster echter Feldfund:** FIELD-01–08, OFFLINE-03–08, CMS-04/07 und Queue-/Security-/E2E-Tests.
- [ ] **Slice D – Redaktion und Betrieb:** CMS-01–08, ADMIN-01–07, INFRA-06–12.
- [ ] **Slice E – Pilot und Release:** kompletter Content, Accessibility, Store-Builds, Datenschutzfreigabe, Last/Security/Restore, Pilot und Release-Gates.

Ein Slice gilt erst als fertig, wenn Code, Vertrag, Migration, Telemetrie, Datenschutz-/Accessibility-Auswirkung, automatisierte Tests und Nachweis auf einer frischen Umgebung gemeinsam vorliegen.

---

## Review-TODOs (Commits zur Überprüfung)

Die folgenden Commits wurden nach der verbindlichen Konvention `featre|bugfix|change (ID) Beschreibung` erstellt und stehen für Peer-Review & Audit bereit:

- [ ] **Review Commit `0538149` (`change (STATUS-01) status registry, evidence and open question baseline update`):** Überprüfung der kanonischen Statusquelle `STATUS_REGISTRY.csv`, `EVIDENCE.md` und `BLOCKERS.md`.
- [ ] **Review Commit `25e8643` (`featre (APP-01) modular app architecture, configuration and bootstrap state`):** Überprüfung des modularen Flutter-Architektur-Schnitts, `AppConfig` und `PlantiniApp` Bootstrap-State.
- [ ] **Review Commit `956fd02` (`featre (AUTH-04) harden keycloak realm configuration and security tests`):** Überprüfung der gehärteten Keycloak-Realm-Konfiguration und der Sicherheits-Unit-Tests (`realm-security.test.mjs`).
- [ ] **Review Commit `6541c06` (`featre (API-02) openapi v1 boundary contract and platform services refactoring`):** Überprüfung des OpenAPI v1 Boundary-Vertrags und der refaktorierten Platform-Services.
- [ ] **Review Commit `eb10ff8` (`change (INFRA-04) e2e compose configuration, test runner scripts and tooling`):** Überprüfung der E2E Docker Compose-Umgebung und Test-Runner-Skripte.
- [ ] **Review Commit `38ac7ba` (`featre (AUTH-01) validate keycloak jwts, resolve actor profile and enforce blocking ci gates`):** Überprüfung der JWT-Validierung (`jwt-validator.test.js`), Actor-Service Profilauflösung und Entfernung von `|| true` aus CI-Workflows.
- [ ] **Review Commit `b005b8c` (`featre (CONTENT-01) content and learning domain tests and quiz schema validation`):** Überprüfung der ContentService- und LearningSession-Tests (`content-service.test.js`, `learning_flow_test.dart`) und Manifest-/Quiz-Validierung.
- [ ] **Review Commit `85075cb` (`bugfix (STATUS-01) korrigiere projektstatus und veraltete quellen`):** Überprüfung: PROJECT_STATUS.md auf v0.3.0-alpha zurückgestuft, RELEASE_NOTES.md korrigiert, BACKLOG.csv und features.csv als deprecated markiert, test-data-and-accounts.md erstellt.
- [ ] **Review Commit `e298b2b` (`featre (APP-01) plant domain model, detail screen and field/herbarium module structure`):** Überprüfung: Plant-Domain-Modell, PlantDetailScreen, Field- und Herbarium-Feature-Module mit Domain/Application/Infrastructure-Schichten.
- [ ] **Review Commit `5b99774` (`featre (APP-05) unified state widgets and remove hardcoded content values`):** Überprüfung: LoadingState, EmptyState, OfflineState, ErrorState, PermissionDeniedState Widgets und content_constants.dart.
- [ ] **Review Commit `c1ec09f` (`featre (APP-04) declarative routing with go_router and silent catch cleanup`):** Überprüfung: GoRouter-Routing mit ShellRoute/Bottom-Nav, Placeholder-Screens, stille catch-Blöcke durch Logging ersetzt.
- [ ] **Review Commit `781117c` (`featre (OFFLINE-01) isar downgrade for web support and linux platform added`):** Überprüfung: Isar 2.X Downgrade in pubspec.yaml, Linux-Unterstützung hinzugefügt, OQ-02 in BLOCKERS.md entschieden.
- [ ] **Review Commit `524e3fe` (`featre (OFFLINE-02) isar local database schema and models for offline content`):** Überprüfung: LocalDatabase Klasse, Isar-Modelle für Ecosystem, Level, Plant erstellt und Code via build_runner generiert.
- [x] **Review Commit `66f7a96` (`featre (OFFLINE-03) persistent background sync queue with exponential backoff`):** Teilweise abgelehnt: nicht in die App integriert, `running`-Jobs werden nach Abbruch nicht zurückgewonnen und `maxAttempts` wird nicht erzwungen. Korrektur bleibt offen.
- [x] **Review Commit `3b07872` (`featre (CONTENT-06) atomic content release download and checksum validation`):** Teilweise abgelehnt: Service ist nicht eingebunden und der Demo-Manifest enthält keine Pakete. Korrektur bleibt offen.
- [x] **Review Commit `d02e971` (`featre (FIELD-01) secure media capture with exif stripping and size limits`):** Teilweise abgelehnt: die Hilfsklasse ist nicht mit einem Feldablauf verbunden. Korrektur bleibt offen.
- [x] **Review Commit `d668a29` (`featre (FIELD-02) resilient location service with privacy blurring and offline fallback`):** Teilweise abgelehnt: die Hilfsklasse ist nicht mit einem expliziten Nutzer-Opt-in verbunden. Korrektur bleibt offen.
- [x] **Review Commit `47bd932` (`featre (OFFLINE-07) reactive herbarium list and detail ui replacing static placeholders`):** Abgelehnt: fiktive Unsplash-Daten und präzise Koordinaten werden angezeigt; `syncEntries()` markiert ohne Netzaufruf Daten als synchronisiert. Wird ersetzt.
- [x] **Review Commit `08a3860` (`featre (OFFLINE-04) server side idempotency keys and unique constraints for observations`):** Teilweise abgelehnt: In-Memory-Tests decken Wiederholungen ab, aber OpenAPI dokumentiert Replay-Status nicht und es fehlt ein echter Datenbank-Integrationstest.
- [x] **Review Commit `fa6e75b` (`test (QA) add complete e2e flutter walkthrough`):** Abgelehnt als E2E-Nachweis: der Ablauf nutzt nur Fake-Auth, Fake-Katalog, Fake-Lernen und ein In-Memory-Herbarium. Er wird als Widgettest eingeordnet; echter externer E2E bleibt QA-06.
- [x] **Review Commit `f72de5d` (`bugfix (STATUS-02) fix platform backend env and flutter linux boot exception`):** Abgelehnt: der Commit ändert keine Linux-Laufzeitursache. Die Konfigurations- und OIDC-Korrektur liegt in `742a79d` und ist separat getestet.

### Ergebnis des Antigravity-Reviews (26. August 2026)

- [x] Review abgeschlossen: Falsche Fertigmeldungen wurden zurückgenommen; die betroffenen Aufgaben bleiben bis zur nachweislich integrierten Umsetzung offen.
- [x] Korrektur eingeleitet: keine Demo-Funde, keine vorgetäuschte Synchronisation und keine als E2E bezeichneten Fake-Tests sollen im Produktpfad verbleiben.
- [ ] Noch nachzuweisen: echter IPv4-gestützter Login- bis Herbarium-Ablauf gegen eine frische E2E-Umgebung.
