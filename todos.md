# Plantini – offene Aufgaben

Stand: 11. November 2026. Ziel ist eine präsentierbare, öffentlich zugängliche Demo, kein Produktionsausbau.

Diese Liste enthält nur offene, wesentliche Punkte. Erledigte und überholte Einträge stehen in der Git-Historie dieser Datei (letzte vollständige Fassung: Stand vor dem 11.11.2026).

**Format:** `- [ ] **P<0–3> | <ID>:** Beschreibung`. Jede ID braucht eine Zeile in `knowledge/state/STATUS_REGISTRY.csv`, sonst schlägt `knowledge/scripts/validate_knowledge.py` fehl. Abhaken (`[x]`) nur mit Nachweis in `knowledge/state/EVIDENCE.md`; danach den Eintrag hier entfernen.

## 1. Öffentlicher Start

- [ ] **P0 | OSS-01:** Öffentliches Repository <https://github.com/noahilli/plantini> nachziehen. Seit 11.11.2026 öffentlich, mit bereinigter Historie, Secret Scanning samt Push-Schutz, Dependabot-Warnungen und -Sicherheitsupdates, privater Schwachstellenmeldung und Schutz von `main` gegen Force-Push und Löschen. Offen: eine grüne Remote-Pipeline nachweisen (hängt an TEST-01; ersetzt INFRA-01).
- [ ] **P0 | TEST-01:** Rote Flutter-Tests beheben oder bewusst markieren, damit die öffentliche CI aussagekräftig ist (13 Tests schlugen schon vor den Spieländerungen fehl; `game05_herbarium_bottles_test.dart` kompiliert nicht: `await tester.view.reset()` ist `void`). Nur nach Freigabe, solange GAME-QA pausiert ist.
- [ ] **P1 | SEC-06:** Datenschutzerklärung an die offene Selbstregistrierung anpassen (Registrierung, Konten ohne E-Mail, Minderjährige, Löschung) und freigeben.
- [ ] **P1 | AUTH-10:** Einwilligungsversionen, Altersfluss, Datenkopie und Kontolöschung umsetzen; mit offener Registrierung vordringlich.
- [ ] **P1 | CONTENT-12:** Rechte an Texten, Fotos und 3D-Modellen prüfen und je Datei kennzeichnen (Lizenz, Urheber, Alt-Text); BANini-Bilder nicht ohne Nutzungsrecht übernehmen.
- [ ] **P1 | INFRA-11:** Verschlüsselte Sicherung **außerhalb** des Produktionsservers einrichten und eine Wiederherstellung messen (heute liegt die Sicherung auf demselben Server).
- [ ] **P1 | SEC-07:** Secret-, Dependency-, Lizenz- und Container-Scans in der CI blockierend machen.
- [ ] **P2 | DOCS-02:** Betriebshandbuch nachziehen: Handbuch-Dienst `docs` (Port 8086, `DOCS_IMAGE`, `DOCS_HTPASSWD_DIR`) fehlt in `betrieb/index.md`, `compose.md`, `deployment.md` und `repo-karte.md`; LAN-Demo (`infra/compose.lan.yaml`, `tools/scripts/start-lan-demo.sh`, bindet `0.0.0.0`) fehlt in `compose.md`, `setup.md` und `repo-karte.md`; Ownership-Zeilen für nicht existierende `docs/research/`, `docs/security/` bereinigen.

## 2. Offene Nutzerabnahmen

Implementiert, aber erst erledigt, wenn die Person es in der laufenden App bestätigt. Build-Erfolg ist keine Abnahme.

- [ ] **P1 | GAME-08:** Steckbrief-/Quiz-/Sammelablauf, insbesondere Nachschlagen ohne Verlust der Antwort und Wiederanlauf mit vorhandenem Cache.
- [ ] **P1 | WORLD-11:** Animierte 3D-Ökosysteme (Wald, Wiese, Alpen): angemeldeter Spielablauf und Leistung auf Mobilgeräten. Siehe `knowledge/handovers/world-redesign-2026-10-06.md`.
- [ ] **P1 | DESIGN-09:** Low-Poly-Redesign mit großer Schrift, schmalen Fenstern und kompletter Nutzerreise.
- [ ] **P1 | DESIGN-10:** Responsive Pflanzen-Karteikarte (Desktop/Mobil, 200-%-Schrift). Siehe `knowledge/handovers/editorial-cards-and-practice.md`.
- [ ] **P1 | DESIGN-11:** App-Design Slice 1; offen sind Quiz, Feldaufgabe, Kamera, Abschluss-Feier, Profil und 200-%-Schrift. Siehe `knowledge/handovers/app-design-vitrine.md`.
- [ ] **P1 | DESIGN-12:** Tageszeiten der Ökosysteme, Lesbarkeit der Nachtansicht auf echten Handys.
- [ ] **P1 | DESIGN-13:** Auswahl der neun Entdecker:innen beim ersten Login.
- [ ] **P1 | LEARN-12:** Endloser Karteikarten-Lernmodus.
- [ ] **P1 | MEDIA-10:** Foto-Galerie der Pflanzenkarten (Stand 29.09.: 28 von 30 Pflanzen mit Foto).
- [ ] **P1 | APP-10:** Herbarium-Fotos auf Produktion und Gerät; Obergrenze des Bild-Caches festlegen.
- [ ] **P1 | APP-11:** Herbarium-Karte, Artkarten und Sammelquoten; Wikipedia-Text mit echtem Netz, OSM-Nutzungsbedingungen bei Last.
- [ ] **P1 | PERF-01:** Leistung auf schwachen Android-Geräten messen (`integration_test/perf_walk_test.dart`).

## 3. Nächste Produktschritte

- [ ] **P1 | AUTH-06:** Konto-Lebenszyklus Ende-zu-Ende: Selbstregistrierung (seit 10.11.2026 wieder offen) und verwaltete Schülerkonten, Bestätigungsmail, Passwort-Reset, Sperre, verständliche Fehlerzustände.
- [ ] **P1 | AUTH-07:** Rollenmatrix (Lernende, Lehrende, Redaktion, Review, Administration) in Keycloak und API konsistent erzwingen.
- [ ] **P1 | CONTENT-10:** Alle 30 Arten fachlich gegen direkte Artenquellen prüfen und redaktionell freigeben.
- [ ] **P1 | CONTENT-05:** Echtes Release-Manifest mit unveränderlicher Version, SHA-256, Größen, Mindest-App-Version und Signatur.
- [ ] **P1 | CONTENT-06:** Release atomar laden und erst nach vollständiger Prüfung aktivieren; bei Fehler vorherige Version behalten.
- [ ] **P1 | CMS-10:** Redaktionsvorschau und atomare Release-Freigabe für generierte Entwürfe im Studio.
- [ ] **P1 | CMS-02:** Review-Workflow mit getrennten Rollen und Vier-Augen-Regel.
- [ ] **P1 | OFFLINE-08:** Exakte Fundorte privat halten; Export standardmäßig ohne oder vergröbert.
- [ ] **P1 | API-07:** Datenbankmigrationen, Constraints und Indizes versionieren.
- [ ] **P2 | FIELD-09:** Echten PlantNet-Zugang erst nach Vertrag, Quote, Datenschutz und Attribution aktivieren.
- [ ] **P2 | INFRA-12:** Deployment mit Migration, Smoke-Test und Rollback automatisieren.
- [ ] **P2 | INFRA-13:** Store-Builds für Android/iOS (Signierung, Metadaten, Umgebungswerte).

## 4. Später

- [ ] **P2 | AUTH-09:** Google, Apple und einen Hochschul-IdP anbinden.
- [ ] **P2 | CONTENT-07:** Suche, Filter, Regionen, Saison und Mehrsprachigkeit.
- [ ] **P2 | CONTENT-11:** Runden 2 und 3 mit eigenen Vergleichs- und Lebensraumfragen.
- [ ] **P2 | LEARN-07:** Adaptive Wiederholung und Fortschrittsübersicht.
- [ ] **P2 | OFFLINE-09:** Export und vollständige Löschung einzelner Funde und aller Daten.
- [ ] **P2 | CMS-07:** Medien in S3/MinIO statt im lokalen Volume.
- [ ] **P2 | ADMIN-04:** Datensparsame Event-Taxonomie, keine personenbezogenen Daten in Telemetrie.
- [ ] **P2 | INFRA-10:** Monitoring ohne personenbezogene Daten mit getesteten Alarmen.
- [ ] **P2 | SEC-08:** Pentest, Abuse Cases und Incident Response vor einem Pilotbetrieb.
- [ ] **P2 | QA-08:** Barrierefreiheit (Screenreader, Tastatur, Kontrast, 200-%-Text) auf Zielplattformen prüfen.
- [ ] **P2 | QA-11:** Pilot mit Lernenden und Lehrenden.
