# Backup und Beobachtung

Alle Daten, die sich nicht aus dem Repository neu bauen lassen, liegen in vier benannten Docker-Volumes und in wenigen Dateien auf dem Server. Eine nächtliche Sicherung auf derselben Maschine deckt sie ab; Beobachtung beschränkt sich auf Healthchecks und Logs. Diese Seite sagt genau, was gesichert wird, wie du wiederherstellst – und wo die Lücken sind.

!!! warning "Stand: ehrlich gesagt unvollständig"
    Die Sicherung liegt auf demselben Server und derselben Platte wie die Daten, sie wird nicht verschlüsselt, ihr Ausfall löst keinen Alarm aus, und die Wiederherstellung wurde noch nie in einem Probelauf geübt. Die Details stehen unter [Ehrliche Lücken](#ehrliche-lucken). Das passt zum Projektstatus (unveröffentlichter Teaser); für einen echten Betrieb mit Nutzerdaten reicht es nicht.

## Datenhaltung

| Volume (Projekt `plantini-production`) | Inhalt | In `backup.sh` |
|---|---|---|
| `plantini-production_platform-db` | PostgreSQL der Plattform (Katalog, Fortschritt, Herbarium-Metadaten, Klassen) | ja, `pg_dump -Fc` → `platform.dump` |
| `plantini-production_keycloak-db` | PostgreSQL von Keycloak (Realm, Clients, Konten, Rollen, Ereignisse) | ja → `keycloak.dump` |
| `plantini-production_private-media` | hochgeladene Nutzerfotos (`PRIVATE_UPLOAD_DIR`) | ja → `private-media.tar.gz` |
| `plantini-production_redis-data` | Redis (AOF + Snapshot): Identifikations-Warteschlange, PlantNet-Tageskontingent | **nein** |
| `plantini-proxy_caddy-data` | TLS-Zertifikate und ACME-Konto von Caddy | ja → `caddy-data.tar.gz` |
| `plantini-proxy_caddy-config` | von Caddy erzeugte Konfiguration | nein (wird neu erzeugt) |

Auf dem Host (nicht in Volumes), unter `<deploy-root>`:

| Pfad | In der Sicherung |
|---|---|
| `production.env` (alle Geheimnisse) | ja, in `config.tar.gz` |
| `realm-production.json` | ja, in `config.tar.gz` |
| `infra/` (Compose, Caddyfile, Skripte) | ja, in `config.tar.gz` |
| `downloads/plantini.json` | ja, in `config.tar.gz` – **nur** die JSON-Datei, nicht die APK |
| `web/`, `downloads/*.apk`, `releases/` | nein – aus dem Release neu erzeugbar, sofern der Build noch existiert |
| `production.env.bak-*` | nein |

### Was Updates überleben

Ein Release-Update (`docker compose up -d` mit neuen Image-Tags) und ein Neustart ändern die Volumes nicht. Keycloak importiert den Realm nur beim allerersten Start, Konten und Clients bleiben also erhalten. Verloren gehen Daten nur durch:

- `docker compose down -v`, `docker volume rm` oder `docker system prune --volumes`,
- Verlust der Platte,
- ein bewusstes Zurückspielen einer Sicherung.

!!! danger "Nie ausführen"
    `docker compose down -v`, `docker volume rm …` und `docker system prune --volumes` auf dem Produktionshost. Der Lokalstack kennt `down --volumes` (z. B. `stack:up` und `stack:down` in `tools/e2e`) – dort ist es gewollt, im Betrieb nie.

Der Redis-Inhalt ist verschmerzbar: Beim Start gleicht `bootstrap` anstehende Identifikationsaufträge aus der Datenbank ab (`runtime.field.recoverPendingJobs()` in `services/platform/src/index.js`, danach alle 30 s). Verloren geht dabei der Stand des PlantNet-Tageskontingents; was das praktisch bedeutet, wurde nicht untersucht.

## Die nächtliche Sicherung

`infra/production/backup.sh` schreibt pro Lauf ein Verzeichnis `<BACKUP_DIR>/<UTC-Zeitstempel>/`:

```bash title="infra/production/backup.sh (Auszug)"
ROOT=${PLANTINI_ROOT:-/opt/plantini}
DEST=${BACKUP_DIR:-/var/backups/plantini}
KEEP_DAYS=${KEEP_DAYS:-14}
PROJECT=${COMPOSE_PROJECT:-plantini-production}
...
docker exec "${PROJECT}-postgres-platform-1" pg_dump -U plantini -d plantini -Fc > "$dir/platform.dump"
docker exec "${PROJECT}-postgres-keycloak-1" pg_dump -U keycloak -d keycloak -Fc > "$dir/keycloak.dump"
```

| Variable | Standard | Bedeutung |
|---|---|---|
| `PLANTINI_ROOT` | `/opt/plantini` | `<deploy-root>` |
| `BACKUP_DIR` | `/var/backups/plantini` | Ziel der Sicherungen |
| `KEEP_DAYS` | `14` | Aufbewahrung in Tagen |
| `COMPOSE_PROJECT` | `plantini-production` | Projektname (bestimmt Container- und Volume-Namen) |

Ablauf im Skript:

1. `umask 077` und `set -euo pipefail` – Dateien sind nur für root lesbar, jeder Fehler beendet das Skript.
2. **Datenbanken:** je ein logischer Dump im Custom-Format (wiederherstellbar mit `pg_restore`), erzeugt über `docker exec` im laufenden Container. Konsistent, ohne den Betrieb zu stoppen.
3. **Volumes:** `private-media` und `caddy-data` werden mit einem kurzen Container (`alpine:3.20`) gelesen (`-v …:/data:ro`) und als `.tar.gz` abgelegt.
4. **Konfiguration:** `tar -C "$ROOT" -czf config.tar.gz production.env realm-production.json infra downloads/plantini.json` – enthält Geheimnisse.
5. **Prüfung:** beide Dumps werden mit `pg_restore --list` in einem Wegwerf-Container (`postgres:16.4-alpine`) gelesen.
6. `sha256sum "$dir"/* > "$dir/SHA256SUMS"`, dann `"<Zeitstempel> ok"` an `backup.log`.
7. **Aufbewahrung:** `find "$DEST" -mindepth 1 -maxdepth 1 -type d -mtime +14 -exec rm -rf {} +`.

Ein Verzeichnis enthält danach: `platform.dump`, `keycloak.dump`, `private-media.tar.gz`, `caddy-data.tar.gz`, `config.tar.gz`, `SHA256SUMS`.

### systemd-Einheiten

```ini title="infra/production/plantini-backup.service"
[Unit]
Description=Plantini nightly backup
After=docker.service

[Service]
Type=oneshot
ExecStart=/opt/plantini/infra/production/backup.sh
Nice=10
IOSchedulingClass=idle
```

```ini title="infra/production/plantini-backup.timer"
[Timer]
OnCalendar=*-*-* 03:15:00
RandomizedDelaySec=600
Persistent=true

[Install]
WantedBy=timers.target
```

Der Timer läuft täglich um 03:15 (Serverzeit) mit bis zu 10 Minuten Streuung. `Persistent=true` holt einen verpassten Lauf nach dem Neustart nach; der Dienst läuft mit niedriger CPU- und Platten-Priorität.

Die Installation der Einheiten ist **in keinem Skript** abgebildet. Üblicherweise (Standard-systemd, hier nicht aus einem Repo-Skript):

```bash
sudo cp <deploy-root>/infra/production/plantini-backup.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now plantini-backup.timer
systemctl list-timers plantini-backup.timer
```

Der `ExecStart`-Pfad ist fest auf das Standardverzeichnis eingetragen; liegt `<deploy-root>` woanders, passe ihn an. `backup.sh` muss ausführbar sein. Einen Lauf von Hand startest du mit `sudo systemctl start plantini-backup.service`, das Ergebnis siehst du mit `systemctl status plantini-backup.service` und `journalctl -u plantini-backup.service`.

## Wiederherstellung

!!! warning "Nie geübt"
    Die folgenden Schritte sind aus dem Format der Sicherung abgeleitet (Custom-Format-Dumps, `tar`-Archive). Sie wurden in keinem Probelauf durchgespielt. Übe sie auf einer Wegwerf-Instanz, bevor du sie brauchst.

Die Sicherungsverzeichnisse gehören root (`0700`), und die Umleitungen `< $B/….dump` öffnet deine eigene Shell – führe deshalb **alle Befehle dieses Abschnitts in einer Root-Shell** aus (`sudo -i`); ein vorangestelltes `sudo` vor `docker exec` genügt nicht. Container-Namen folgen dem Muster `<Projekt>-<Dienst>-1` (Compose v2). Wähle zuerst die Sicherung:

```bash
B=/var/backups/plantini/<Zeitstempel>
ls -l $B
( cd $B && sha256sum -c SHA256SUMS )     # Achtung: SHA256SUMS enthält absolute Pfade
```

!!! note "Stolperfalle: absolute Pfade in `SHA256SUMS`"
    `backup.sh` ruft `sha256sum "$dir"/*` mit dem vollen Verzeichnispfad auf; `SHA256SUMS` enthält daher absolute Pfade. `sha256sum -c` funktioniert nur am ursprünglichen Ort. Hast du die Sicherung kopiert, vergleiche die Hashes von Hand.

**Fall A: Daten beschädigt, Server intakt**

```bash
ENV=<deploy-root>/production.env
C="docker compose --env-file $ENV -f <deploy-root>/infra/compose.production.yaml"

# 1. Verbraucher anhalten (Datenbanken laufen weiter)
$C stop platform keycloak

# 2. Plattform-Datenbank zurückspielen
docker exec -i plantini-production-postgres-platform-1 \
  pg_restore -U plantini -d plantini --clean --if-exists < $B/platform.dump

# 3. Keycloak-Datenbank zurückspielen
docker exec -i plantini-production-postgres-keycloak-1 \
  pg_restore -U keycloak -d keycloak --clean --if-exists < $B/keycloak.dump

# 4. Private Fotos zurückspielen
docker run --rm -v plantini-production_private-media:/data -v $B:/in:ro alpine:3.20 \
  tar -C /data -xzf /in/private-media.tar.gz

# 5. Dienste starten
$C up -d platform keycloak
```

`--clean --if-exists` löscht vorhandene Objekte vor dem Anlegen; Fehlermeldungen zu nicht existierenden Objekten bleiben dadurch aus. Keycloak ändert beim Start nichts am Realm, weil dieser in der wiederhergestellten Datenbank schon existiert (`--import-realm` wird übersprungen).

**Fall B: neuer Server** (ebenfalls in einer Root-Shell)

1. Docker und das Compose-Plugin installieren; `<deploy-root>` anlegen.
2. `sudo tar -C <deploy-root> -xzf $B/config.tar.gz` stellt `production.env`, `realm-production.json`, `infra/` und `downloads/plantini.json` her.
3. **Images bereitstellen:** Die Images sind nicht Teil der Sicherung. `production.env` nennt die Tags (Commit-Hashes); baue sie aus diesen Commits neu und übertrage sie ([Deployment](deployment.md)). Die Web-App und die APK müssen ebenfalls neu gebaut und mit `promote-public-assets.mjs` veröffentlicht werden.
4. Zuerst nur die Datenbanken und Redis starten (`$C up -d postgres-platform postgres-keycloak redis`, legt leere Volumes an), dann die Schritte 2–4 aus Fall A ausführen und erst danach `$C up -d`. So importiert Keycloak beim ersten Start keinen frischen Realm in die leere Datenbank, und die Plattform legt keine Demo-Inhalte an, die das Zurückspielen sofort überschriebe.
5. Caddy-Zertifikate: `docker run … tar -C /data -xzf /in/caddy-data.tar.gz` in das Volume `plantini-proxy_caddy-data` zurückspielen (sonst stellt Caddy sie neu aus) und den Eingang starten; DNS muss vorher auf den neuen Host zeigen.
6. Smoke-Checks ([Deployment](deployment.md#smoke-checks-extern)).

Der APK-Signaturschlüssel liegt **nicht** auf dem Server und nicht in dieser Sicherung. Ohne ihn lassen sich installierte Apps nicht aktualisieren ([Android-Release](android-release.md)).

## Ehrliche Lücken

| Lücke | Folge | Beleg |
|---|---|---|
| **Keine Offsite-Kopie** | Plattenausfall, Serververlust oder Kompromittierung des Hosts vernichten Daten und Sicherung zugleich | `DEST` ist ein lokales Verzeichnis; nichts kopiert es weg |
| **Wiederherstellung nie geübt** | RTO unbekannt; Fehler im Ablauf zeigen sich erst im Ernstfall | kein Skript, kein Protokoll im Repo |
| **Keine Verschlüsselung** | `config.tar.gz` enthält `production.env` im Klartext; Schutz nur durch `0700`/`umask 077` und root-Rechte | `tar -czf` ohne Verschlüsselung |
| **Kein Alarm bei Fehlschlag** | Schlägt ein Lauf fehl, merkt es niemand: kein `OnFailure=` in der Service-Datei, `backup.log` enthält nur Erfolgszeilen | `plantini-backup.service`, `backup.sh` Zeile `echo "$stamp ok"` |
| **Laufzeit-Abhängigkeit von Registries** | Die Prüfung nutzt fest `postgres:16.4-alpine`, das Volume-Archiv `alpine:3.20` – beide werden bei Bedarf geladen. Ohne Netz (oder bei fehlendem Image) bricht der Lauf ab. Zusätzlich weicht die feste Postgres-Version vom Stack-Image `POSTGRES_IMAGE` ab | `backup.sh` Zeilen 26 und 34 |
| **Aufbewahrung nur bei Erfolg** | Die Bereinigung steht am Ende des Skripts; ein dauerhaft fehlschlagender Lauf räumt nichts auf: alte und halbfertige Verzeichnisse bleiben liegen und belegen Platz | `find … -mtime +KEEP_DAYS` als letzte Zeile |
| **Nicht gesichert** | Redis, `web/`, APK-Dateien, `releases/`, `production.env.bak-*`, Docker-Images, die Servereinrichtung (systemd-Einheiten, Firewall, Docker-Daemon-Einstellungen) | Inhalt von `backup.sh` |
| **RPO 24 Stunden** | Zwischen zwei Läufen eingetragene Daten sind bei einem Totalverlust weg | Timer: einmal täglich |

Realistisch einzuordnende Verbesserungsvorschläge (alle **noch nicht umgesetzt**): regelmäßige verschlüsselte Kopie auf ein anderes System; Fehlerbenachrichtigung (`OnFailure=`-Einheit); einen vierteljährlichen Wiederherstellungstest auf einer Wegwerf-Instanz; Image-Referenzen im Skript an `POSTGRES_IMAGE` binden.

## Logs

Weder `infra/compose.production.yaml` noch `infra/production/compose.proxy.yaml` setzen eine `logging:`-Option, und das `Caddyfile` enthält keine `log`-Direktive. Daraus folgt:

- Alle Container schreiben auf stdout/stderr und nutzen die Standardeinstellung des Docker-Daemons. **Rotation und Aufbewahrung des Daemons sind nicht geprüft.**
- Caddy protokolliert ohne `log`-Direktive keine Zugriffe; Laufzeit- und Fehlermeldungen stehen im Container-Log. Im Repository existiert keine Zugriffsprotokoll-Konfiguration.
- Ob und wie lange Zugriffs- und Container-Logs tatsächlich gespeichert werden, ist daher vom Host abhängig und hier nicht belegt. Gleiche das mit der Datenschutzerklärung auf der Homepage ab, bevor du Aussagen zur Speicherdauer machst.
- Konkret belegt ist nur die Ereignis-Aufbewahrung in Keycloak: `eventsExpiration` = 7 776 000 s (90 Tage), Ereignisse ohne Details ([Identität und Keycloak](identity-keycloak.md#die-realm-quelle)).

```bash
cd <deploy-root>
C="docker compose --env-file production.env -f infra/compose.production.yaml"
$C logs --since 1h platform            # Strapi (strapi::logger)
$C logs -f keycloak
docker compose --env-file production.env -f infra/production/compose.proxy.yaml logs --since 1h caddy
```

(Auch der Proxy-Aufruf braucht `--env-file`, weil `compose.proxy.yaml` Pflichtvariablen verwendet.)

## Health-Endpunkte

| Ziel | Pfad | Antwort | Aussage |
|---|---|---|---|
| Plattform (intern) | `http://127.0.0.1:1338/api/v1/health` bzw. öffentlich `https://api.<domain>/api/v1/health` | `{ "status": "ok", "apiVersion": … }` | Prozess nimmt Anfragen an; **prüft weder Datenbank noch Redis** (`controllers/platform.js`) |
| Web-App | `https://app.<domain>/healthz` | `ok` | Caddy antwortet (`respond @healthz "ok" 200`); sagt nichts über die API |
| Homepage, Studio, Portal | `/healthz` des jeweiligen Hosts | `ok` | nginx im Container läuft |
| Keycloak | TCP-Port 8080 im Container (Compose-Healthcheck) | – | Prozess lauscht. Mit `KC_HEALTH_ENABLED` bietet Keycloak 24 zusätzlich Health-Endpunkte auf dem Hauptport; Caddy gibt sie nicht frei (nicht geprüft) |
| PostgreSQL | `pg_isready` | – | Compose-Healthcheck |
| Redis | `redis-cli ping` | – | Compose-Healthcheck |

Die Compose-Healthchecks beeinflussen `depends_on: condition: service_healthy` (Startreihenfolge) und die Anzeige in `docker compose ps`. `restart: unless-stopped` startet abgestürzte Container neu; **unhealthy** Container werden von Docker allein nicht neu gestartet.

## Metriken und Alarme

Es gibt keine Metriken-Erfassung: In `services/platform/src` und `services/platform/config` kommen weder `prometheus` noch `metrics` vor, in den Compose-Dateien existiert kein Monitoring-Dienst, und Keycloak-Metriken sind nicht eingeschaltet. Es gibt auch keine externe Verfügbarkeitsprüfung und keine Alarmierung. Fällt der Dienst aus, bemerkst du es durch Hinsehen oder durch eine Rückmeldung.

### Soll und Ist

`knowledge/operations/observability-and-backup.md` beschreibt einen Zielzustand; die Tabelle stellt ihn dem Code gegenüber.

| Thema | Soll (Wissenspaket) | Ist |
|---|---|---|
| Metriken (API-Latenz, Fehler, Queue, PlantNet-Quote …) | erfasst | nicht vorhanden |
| strukturierte Logs mit Trace-ID | gefordert | nicht geprüft; Strapi-Standard-Logger |
| SLO | 99,5 % monatlich, Reads p95 < 500 ms | nicht gemessen |
| RPO / RTO | ≤ 24 h / ≤ 8 h | RPO 24 h erreicht, solange der Lauf gelingt; RTO ungeprüft |
| Backup getrennt gesichert | Datenbanken, Objektspeicher, Realm-/CMS-Konfiguration, IaC, Schlüssel getrennt | alles im selben Verzeichnis, selbe Maschine |
| Restore-Test | mindestens vierteljährlich | noch nie |
| Alarmfälle (5xx, Queue-Stau, PlantNet-Quote > 70 %, Backup-Fehler …) | definiert | keine Alarmierung |

!!! note "Widerspruch in den Betriebsnotizen"
    `operations/runbooks/backup-restore.md` nennt „RPO < 4 Stunden, RTO < 30 Minuten“ und Container wie `plantini-postgres-platform-1`. Beides beschreibt den alten Entwicklungsstack, nicht den Produktionsbetrieb: Die Sicherung läuft nur nächtlich, und der Container heißt `plantini-production-postgres-platform-1`. Auch die dort genannte MinIO-Sicherung entfällt (private Medien liegen im Volume `private-media`).

## Routinekontrolle (manuell)

Es gibt keine Automatik, also gehört eine kurze Routine dazu:

- [ ] `systemctl list-timers plantini-backup.timer` – nächster Lauf geplant?
- [ ] `tail <BACKUP_DIR>/backup.log` – letzte Zeile jünger als 24 h und `ok`?
- [ ] `ls -l <BACKUP_DIR>` – Größe der letzten Sicherung plausibel (vergleiche mit dem Vortag)?
- [ ] `df -h` – Platz für Datenbanken, Volumes und Sicherungen (alles auf derselben Platte)
- [ ] `docker compose … ps` – alle Dienste `healthy`?
- [ ] Smoke-Checks von außen ([Deployment](deployment.md#smoke-checks-extern))
- [ ] Ein Auszug der Sicherung wurde mindestens einmal an einen anderen Ort kopiert und dort geöffnet

## Weiterführend

- [Betrieb: Überblick](index.md) · [Compose-Dateien](compose.md) · [Deployment](deployment.md) · [Identität und Keycloak](identity-keycloak.md)
- [Sicherheit und Datenschutz](../architektur/sicherheit-datenschutz.md)
- Quellen: `infra/production/backup.sh`, `infra/production/plantini-backup.service`, `infra/production/plantini-backup.timer`, `infra/compose.production.yaml`, `infra/production/Caddyfile`
- Hintergrund: `knowledge/operations/observability-and-backup.md` (Soll), `operations/runbooks/production-deploy.md` (Betriebsnotizen; enthält reale Hostdetails und wird hier nicht wiedergegeben)
