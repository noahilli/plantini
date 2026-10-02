# Plantini Studio: Anforderung und Umsetzungsstand

Stand: 2026-10-01. Das Studio ist eine separate Webanwendung. Es ersetzt **nicht** das interne Strapi-Admin.

## Seiten und Rechte

| Seite | Zweck | Rechte |
| --- | --- | --- |
| Übersicht | Nutzer, PlantNet-Tageszugriffe, privater Upload-Speicher, Ökosysteme, Level, Pflanzen, Quizze, Karten, offene Reviews | Redaktion und Review |
| Inhalte | Baum Ökosystem → Level → Pflanze/Quiz; Entwürfe erstellen und bearbeiten; Lernkarten und Relationen pflegen | Redaktion und Review |
| Review | Eingereichte Änderungen ansehen, begründet zurückweisen oder fachlich freigeben; Verlauf nachvollziehen | Review; Redakteure sehen eigene Änderungen |
| Team | Redakteure per Keycloak-E-Mail einladen; Reviewer nur durch Systemadministration | Redaktion bzw. Systemadministration |

Die Keycloak-Realm-Rollen heißen `inhaltsredaktion`, `botanisches_review` und `systemadministration`. Rollenprüfung erfolgt serverseitig an jeder Editor-API. Browser-Login nutzt Authorization Code + PKCE S256 mit separatem Public Client. Die Keycloak-Admin-API wird nur vom Backend mit einem eigenen, eng berechtigten Service Account aufgerufen. Es gibt keine Admin-Zugangsdaten im Browser.

## Architektur und Deployment

`apps/editor` ist ein statischer Nginx-Container hinter `studio.<domain>`. Er spricht ausschließlich mit `api.<domain>/api/v1/editor/*` und `auth.<domain>`. Der API-Dienst hält Entwürfe und Review-Zustände in PostgreSQL (`editor_changes`); die veröffentlichten Strapi-Inhalte bleiben zunächst unverändert. In der Produktions-Compose-Datei hängt der Editor nur am Edge-Netz. Auf einem bestehenden Keycloak-Realm muss der neue OIDC-Client **live** angelegt werden: ein Realm-Import aktualisiert ihn nicht automatisch. Der Einladungsdienst benötigt einen separat konfigurierten Keycloak-Service-Account und funktionierenden SMTP-Versand. Seed-Inhalte müssen bei echter Redaktion deaktiviert sein (`PLATFORM_SEED_DEMO_CONTENT=false`). Vor Produktionsbetrieb sind Datenbank-Backups nötig.

### Lokal auf IPv4 starten

Voraussetzung: Der isolierte E2E-Stack und seine ignorierte `tools/e2e/.runtime/e2e.env` existieren. Dann:

```sh
node tools/scripts/configure-local-editor.mjs
docker compose --env-file tools/e2e/.runtime/e2e.env -p plantini-e2e \
  -f infra/compose.e2e.yaml -f infra/compose.authoring.local.yaml \
  -f infra/compose.editor.local.yaml up -d --build --wait editor platform
```

Studio: `http://127.0.0.1:8084/`. Lokale Konten stehen ausschließlich in `tools/e2e/.runtime/editor-studio.env` (0600); das Konfigurationsskript setzt ihre Passwörter bei jedem Lauf neu. Der lokale Overlay schaltet den Demo-Seed für die redaktionelle Plattform aus, lässt vorhandene E2E-Daten und Volumes aber bestehen. Einladungen sind lokal ohne zusätzlichen Keycloak-Service-Account/SMTP nicht verfügbar. Das Studio und die API verwenden bewusst IPv4-Loopback.

## Aktueller Funktionsumfang und harte Grenze

Angelegt sind die Studio-Oberfläche, Keycloak-Clients im versionierten Realm, API für Dashboard/Katalog/Entwürfe/Einreichen/Zurückweisen/Einladen und der Container-Bau. JSON-Inhalte (Quellen, Merkmale, Abschlussregel, Quizdaten und Lernkarten) haben eine rekursive Formularansicht mit Typwahl, verschachtelten Objekten/Listen, Hinzufügen und Entfernen sowie eine editierbare Raw-JSON-Ansicht; beide Ansichten nutzen denselben Entwurf. Die Browseroberfläche zeigt vorhandene Bilder, kann sie aber noch nicht hochladen oder zuordnen. Einladungen sind nur mit konfiguriertem Service Account und SMTP nutzbar. Dashboard-Speicher zählt derzeit nur hochgeladene private Medien; Kartenanzahl ist aus drei Pflicht-Lernkarten je veröffentlichter Pflanze abgeleitet; PlantNet-Zugriffe sind nur der Tageszähler aus Redis, keine historische Analyse. Katalogabfragen sind noch auf 1000 Datensätze je Typ begrenzt.

**Fachliche Freigabe ist möglich, Veröffentlichung bleibt deaktiviert.** Der bestehende Live-Lesepfad und die Offline-Manifest/Paket-Linie sind noch nicht an ein atomar aktiviertes Release gekoppelt. Direktes Publizieren in Strapi könnte Clients inkonsistente Inhalte liefern. Deshalb dürfen freigegebene Entwürfe noch keine veröffentlichten Datensätze ändern. Um Veröffentlichung zu aktivieren, müssen nacheinander umgesetzt werden:

Am 02.10. wurde die lokale Sync-Grenze gehärtet: Die App hasht jetzt die unveränderten HTTP-Bytes (nicht erneut serialisiertes JSON), prüft auch die deklarierte Paketgröße und verwirft fehlende oder leere Kernpakete vor einem Datenbanktausch. Der Demo-Seed `2026.10.02-de.1` liefert nun unveränderliche Ökosystem-/Level-/Pflanzenpakete aus den veröffentlichten CMS-Datensätzen; die lokalen IPv4-HTTP-Antworten wurden gegen Manifest-Größe und SHA-256 geprüft. Bereits vollständig zwischengespeicherter Content derselben Version wird weiterverwendet. **Ein redaktionell publizierbarer, atomarer Offline-Release ist das noch nicht:** Signatur, Offline-Quizdaten, aktive Online-Lesepfade und Apply/Rollback der freigegebenen Entwürfe fehlen.

Beim Einreichen wird der Entwurf gehasht; im Review wird der Hash erneut geprüft. Statuswechsel und Speichern haben Datenbank-Grenzbedingungen, damit eine verspätete Speicherung eine Einreichung nicht überschreibt. Vor Einreichung und Freigabe werden vorhandene Referenzen, Slugs und der bearbeitete Ausgangsstand geprüft. Reviewer dürfen eigene Entwürfe fachlich freigeben, wie vom Auftraggeber ausdrücklich vorgesehen. Das ist eine Ausnahme von einer strengen Vier-Augen-Regel und muss bei der späteren Publish-Policy bewusst berücksichtigt werden.

Lokaler Browser-Smoketest am 02.10.: Redaktionslogin, neuer Ökosystem-Entwurf, Einreichung, Reviewer-Login und fachliche Freigabe bestanden; das öffentliche Ökosystem-Listing blieb unverändert. Dies beweist **keine** Produktionsfreigabe und keinen App-Sync.

1. Release-übergreifende Validierung für Beziehungen, Quizlösungen, Quellen, Bildlizenz und Alt-Text.
2. Versionierten Release aus geprüften Datensätzen bauen; Pakete, SHA-256, Manifest und Cursor aus denselben Daten erzeugen.
3. Release atomar aktivieren und zurückrollen können; Online-Endpunkte strikt auf das aktive Release filtern.
4. Die bereits fachlich freigegebenen Änderungen in den atomaren Release-Schritt einbinden. Reviewer dürfen eigene Inhalte freigeben; Redakteure benötigen Reviewer-Freigabe.
5. Bildverwaltung, Teamübersicht, Dashboard-Paginierung und einen Frischumgebungs-Test vom Entwurf bis zum App-Sync ergänzen.

Bis dahin ist dies ein **Redaktions-MVP für Entwürfe und fachliches Review, kein produktionsfertiger Veröffentlichungsweg**.
