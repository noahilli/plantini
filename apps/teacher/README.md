# Plantini Lehrendenportal

Eigenständiges deutsches statisches Frontend ohne npm-Abhängigkeiten. Alle Lern- und Kontodaten kommen aus der Teaching-API. Das Portal verwendet Systemschriften, lokale Assets und keine Analytics-Dienste.

## Lokal starten

Aus diesem Verzeichnis:

```sh
TEACHER_HTTP_PORT=8085 \
PLANTINI_API_BASE_URL=http://127.0.0.1:1338/api/v1 \
PLANTINI_OIDC_ISSUER_URL=http://127.0.0.1:8082/realms/plantini \
PLANTINI_OIDC_CLIENT_ID=plantini-teacher-dev \
docker compose up --build
```

Aufruf: `http://127.0.0.1:8085/`. Produktions-Origin: `https://portal.plantini.eu/`. Alle API-/OIDC-Adressen sind aus Sicht des Browsers anzugeben. Der Compose-Port bindet ausschließlich an IPv4-Loopback. `TEACHER_HTTP_PORT` legt den Hostport fest; `TEACHER_LISTEN_PORT` den Containerport (Standard 8080, zulässig 1024–65535). Keine vorhandenen Dienste oder Volumes werden durch diese eigenständige Compose-Datei eingebunden.

## Laufzeitkonfiguration und Integration

Der Container erzeugt bei jedem Start `/config.json` und die Nginx-Konfiguration aus öffentlichen Umgebungsvariablen:

| Variable | Produktionsstandard |
| --- | --- |
| `PLANTINI_API_BASE_URL` | `https://api.plantini.eu/api/v1` |
| `PLANTINI_OIDC_ISSUER_URL` | `https://auth.plantini.eu/realms/plantini` |
| `PLANTINI_OIDC_CLIENT_ID` | `plantini-teacher-production` |
| `TEACHER_LISTEN_PORT` | `8080` |

Die Content Security Policy erlaubt Verbindungen zu genau den konfigurierten API-/OIDC-Origins. `/healthz` liefert `ok`. HTML, Assets und Konfiguration werden mit `Cache-Control: no-store` ausgeliefert. `config.json` im Quellverzeichnis dient einem einfachen statischen Entwicklungsserver; im Container wird sie zur Laufzeit erzeugt. Das Frontend muss an der Wurzel einer eigenen Origin betrieben werden. Produktionsbetrieb setzt HTTPS am vorgeschalteten Proxy voraus.

Backend/Infra müssen einen öffentlichen OIDC-Client mit Authorization Code Flow, PKCE S256 und ohne Client-Secret bereitstellen. Redirect URI und Post-Logout Redirect URI sind jeweils die Portal-Origin mit abschließendem `/` (`https://portal.plantini.eu/` bzw. `http://127.0.0.1:8085/`); Web Origins/CORS müssen dieselbe konkrete Origin erlauben. Auch die API muss Authorization- und Content-Type-Header sowie GET/POST/PATCH für diese Origin erlauben. Rollen: `lehrende` oder `systemadministration`; bestehende Systemadministrationskonten können sich anmelden, eine Selbstregistrierung wird im Portal nicht angeboten. Die API bleibt für Berechtigungsprüfung und Klassenzuordnung verantwortlich. `capabilities.manageStudents` steuert die sichtbaren Aktionen zur Kontoverwaltung. Klassen können unabhängig davon angelegt werden. Die Oberfläche berücksichtigt maximal 100 Klassen und 500 Schülerkonten pro Klasse. Benutzernamen: 3–64 ASCII-Zeichen, beginnend mit a–z oder 0–9, danach zusätzlich Punkt, Unterstrich und Bindestrich. Eine angegebene E-Mail-Adresse muss bei der Anmeldung bestätigt werden; Konten ohne E-Mail-Adresse sind unterstützt.

API-Pfade werden relativ zu `PLANTINI_API_BASE_URL` mit `/teaching` ergänzt. Verwendet werden `/session`, `/dashboard`, `/classes`, `/classes/{uuid}`, `/classes/{uuid}/students`, `/students/{uuid}/reset-password` und `/students/{uuid}`. Klassenanlage erwartet das Klassenobjekt direkt als Antwort. `activeStudents` wird als Anzahl aktiver Konten dargestellt; `averageProgress` wird direkt aus dem Backend übernommen und nicht im Browser neu berechnet.

Der Container läuft unprivilegiert als `nginx` mit Port 8080. `read_only: true` mit tmpfs für `/tmp`, `/var/cache/nginx` und `/var/run` wird unterstützt und ist im lokalen Compose aktiviert. Die generierte vollständige Nginx-Konfiguration, öffentliche JSON-Konfiguration, PID und temporäre Dateien liegen unter `/tmp`; `/etc/nginx` bleibt unverändert. Der eigene Entrypoint ersetzt die Standard-Konfigurationsschritte des Basisimages. Logs gehen nach stdout/stderr.

## Anmeldung und temporäre Passwörter

PKCE-Verifier, zufälliger State und Erstellzeit liegen nur bis zur einmaligen Rückgabe in `sessionStorage`; Rückgaben sind zehn Minuten gültig. Bei der Rückgabe wird der gespeicherte Vorgang vor dem Token-Austausch entfernt und die URL sofort bereinigt. Access-, Refresh- und ID-Token liegen ausschließlich im Arbeitsspeicher. Refresh-Anfragen werden zusammengeführt und vor Ablauf automatisch ausgeführt. Bei abgelaufener Sitzung verschwinden geschützte Inhalte. Nach einem Neuladen ist eine neue OIDC-Anmeldung erforderlich; eine vorhandene SSO-Sitzung kann diese vereinfachen. Abmelden löscht den lokalen Zustand und ruft den OIDC-Logout auf.

Temporäre Passwörter werden nur im geöffneten Dialog angezeigt und beim Schließen aus dem DOM entfernt. Sie werden weder gespeichert noch geloggt. Kopieren verwendet die Browser-Zwischenablage; wenn diese nicht verfügbar ist, wird das Feld für manuelles Kopieren markiert. Die Zwischenablage liegt außerhalb der Portal-Persistenz und sollte nach der Übergabe geleert werden. Während einer Kontomutation ist das Schließen des Formulars gesperrt, damit die einmalige Passwortantwort sichtbar bleibt. Fehlgeschlagene Mutationen werden nicht automatisch wiederholt.

## Prüfung

Keine Tests angelegt. Syntax kann ohne Stackstart geprüft werden:

```sh
node --check app.js
sh -n 40-teacher-config.sh
docker compose config --quiet
```

Browserprüfung mit echten Diensten: Anmelden mit erlaubter Rolle, Übersicht laden, Klasse erstellen/öffnen, Schülerkonto erstellen und Passwort kopieren, Passwort zurücksetzen, sperren/aktivieren, Refresh und Logout. Zusätzlich Tastaturbedienung, schmale Ansicht, leere Klassen, API-Ausfälle und fehlende Berechtigungen prüfen.
