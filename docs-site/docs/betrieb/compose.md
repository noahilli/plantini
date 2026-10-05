# Compose-Dateien

Unter `infra/` liegen acht Compose-Dateien. Genau eine (`compose.production.yaml`) beschreibt den Betrieb; die übrigen sind Entwicklungs-, Test- und Overlay-Dateien. Diese Seite erklärt jede Datei, ihre Dienste, Netze, Volumes, Healthchecks und die Härtung – mit Auszügen aus dem tatsächlichen Code.

## Überblick

| Datei | Projektname | Zweck | Baut aus Quelltext? |
|---|---|---|---|
| `infra/compose.yaml` | `plantini` | alter Entwicklungsstack (`start.sh`/`stop.sh`) | nein, mountet `services/platform` |
| `infra/compose.e2e.yaml` | `plantini-e2e` | isolierte Testumgebung für Playwright und lokale Demo | ja (`platform`, `plantnet-mock`) |
| `infra/compose.production.yaml` | `plantini-production` | Anwendungsstack im Betrieb | nein – nur fertige Images |
| `infra/production/compose.proxy.yaml` | `plantini-proxy` | öffentlicher Eingang (Caddy) | nein |
| `infra/compose.editor.local.yaml` | (Overlay) | Studio-Container auf dem E2E-Stack | ja (`apps/editor`) |
| `infra/compose.teacher.local.yaml` | (Overlay) | Portal-Container auf dem E2E-Stack | ja (`apps/teacher`) |
| `infra/compose.authoring.local.yaml` | (Overlay) | Backend-Quelltext live in den E2E-Stack mounten | nein |
| `infra/compose.plantnet.local.yaml` | (Overlay) | echter PlantNet-Anbieter, nur zusammen mit `compose.yaml` | nein |

!!! warning "Stolperfalle: nicht vermischen"
    Die Kopfkommentare trennen die Zwecke ausdrücklich: Die E2E-Datei ist „intentionally separate from deployment compose files“, und `compose.production.yaml` „never builds from source“. Der Entwicklungsstack aus `compose.yaml` hat Platzhalter-Passwörter als Standardwerte (`${PLATFORM_DB_PASSWORD:-dummy_db_password}`) und darf nie öffentlich erreichbar sein.

## `compose.production.yaml`

Kopfkommentar der Datei:

```yaml title="infra/compose.production.yaml"
name: plantini-production

# Single-host production topology intended to run behind a host TLS reverse
# proxy. Every image reference and secret is mandatory. Deploy only immutable
# image references (tag plus digest); this file never builds from source.
```

„Mandatory“ ist wörtlich gemeint: Jede Pflichtvariable nutzt die Compose-Syntax `${VAR:?Fehlermeldung}`. Fehlt sie, bricht schon `docker compose … config --quiet` ab – so fällt ein unvollständiges `production.env` vor dem Start auf.

!!! note "Abweichung: Tag statt Digest"
    Der Kopfkommentar verlangt „tag plus digest“. Images, die per `docker save | ssh … docker load` übertragen werden, tragen aber keinen Repository-Digest; im Betrieb werden sie deshalb über Tags (der Commit-Hash des Releases) referenziert. Das Skript `infra/production/update-release-env.mjs` akzeptiert nur Hex-Tags (`/^[0-9a-f]{7,40}$/`). Die Datei fordert damit mehr, als der gelebte Ablauf liefert; die Image-Identität ist nur durch den lokal geladenen Tag gesichert.

### Dienste

| Dienst | Image-Variable | Netze | Host-Port | Persistenz |
|---|---|---|---|---|
| `postgres-platform` | `POSTGRES_IMAGE` | `data` | – | Volume `platform-db` |
| `postgres-keycloak` | `POSTGRES_IMAGE` | `data` | – | Volume `keycloak-db` |
| `redis` | `REDIS_IMAGE` | `data` | – | Volume `redis-data` |
| `keycloak` | `KEYCLOAK_IMAGE` | `app`, `data`, `edge` | `127.0.0.1:${AUTH_LOOPBACK_PORT:-8082}` | Realm-Datei (Bind-Mount, read-only) |
| `platform` | `PLATFORM_IMAGE` | `app`, `data`, `provider` | `127.0.0.1:${API_LOOPBACK_PORT:-1338}` | Volume `private-media` |
| `homepage` | `HOMEPAGE_IMAGE` | `edge` | `127.0.0.1:${HOMEPAGE_LOOPBACK_PORT:-8083}` | – |
| `teacher` | `TEACHER_IMAGE` | `edge` | `127.0.0.1:${TEACHER_LOOPBACK_PORT:-8085}` | – |
| `editor` | `EDITOR_IMAGE` | `edge` | `127.0.0.1:${EDITOR_LOOPBACK_PORT:-8084}` | – |

Alle Dienste haben `restart: unless-stopped` und `security_opt: [no-new-privileges:true]`.

### Netze

```yaml title="infra/compose.production.yaml"
networks:
  edge: {}
  app:
    internal: true
  data:
    internal: true
  provider: {}
```

Docker erlaubt auf `internal: true`-Netzen weder ausgehenden Verkehr noch veröffentlichte Host-Ports. Daraus ergibt sich die Aufteilung:

| Netz | internal | Mitglieder | Begründung |
|---|---|---|---|
| `data` | ja | beide Postgres, Redis, `keycloak`, `platform` | Datenhaltung nur für die beiden Verbraucher erreichbar, kein Internet |
| `app` | ja | `keycloak`, `platform` | Plattform ↔ Keycloak (JWKS, Admin-API) ohne Umweg über das öffentliche Netz |
| `provider` | nein | `platform` | ausgehende Aufrufe (PlantNet, Kartenkacheln, Wikimedia) **und** das Veröffentlichen von `127.0.0.1:1338` |
| `edge` | nein | `keycloak`, `homepage`, `teacher`, `editor` | Port-Veröffentlichung für Caddy; bei Keycloak zusätzlich ausgehendes SMTP |

!!! warning "Stolperfalle: warum Keycloak am `edge`-Netz hängt"
    Der Kommentar im Compose-File fasst es zusammen:

    ```yaml title="infra/compose.production.yaml"
    # `edge` is a normal (non-internal) network: internal networks cannot
    # publish host ports and would block the outgoing SMTP connection.
    networks: [app, data, edge]
    ```

    Keycloak braucht zwei Dinge, die ein internes Netz verbietet: Caddy muss den Dienst über `127.0.0.1:8082` erreichen (veröffentlichter Port), und Keycloak muss Verifizierungs- und Passwort-Mails an einen externen SMTP-Server senden. Wäre Keycloak nur in `app` und `data`, scheiterte beides: Caddy erreichte weder die Login-Seiten noch den Health-Port, und ausgehende Mails (SMTP) kämen nicht heraus.

    Die `platform` hat denselben Konflikt: Sie ist nicht in `edge`, sondern in `provider`, einem zweiten normalen Netz. Auch hier gilt: ohne ein nicht-internes Netz gäbe es weder den Loopback-Port noch Verbindungen zu PlantNet.

Ehrliche Einschränkung: `edge` ist kein Isolationsnetz. Dort liegen vier Container nebeneinander, und das Netz hat ausgehenden Zugriff. Die eigentliche Absicherung liefern Loopback-Bindung, `read_only`/`cap_drop` und die Keycloak-/Strapi-Konfiguration, nicht die Netztrennung zwischen diesen vier.

### Datenbanken und Redis

```yaml title="infra/compose.production.yaml"
postgres-platform:
  image: ${POSTGRES_IMAGE:?set an immutable PostgreSQL image reference}
  restart: unless-stopped
  environment:
    POSTGRES_DB: plantini
    POSTGRES_USER: plantini
    POSTGRES_PASSWORD: ${PLATFORM_DB_PASSWORD:?missing PLATFORM_DB_PASSWORD}
  volumes:
    - platform-db:/var/lib/postgresql/data
  networks: [data]
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U plantini -d plantini"]
```

`postgres-keycloak` ist identisch aufgebaut (Datenbank `keycloak`, Benutzer `keycloak`, `KEYCLOAK_DB_PASSWORD`). Redis läuft mit `--appendonly yes --save 60 1000` (AOF plus Snapshot) und dient der Identifikations-Warteschlange und dem Tageskontingent für PlantNet (`services/platform/src/api/platform/services/core/field/provider-guard.js`, `identification-queue.js`).

### Keycloak

```yaml title="infra/compose.production.yaml"
keycloak:
  image: ${KEYCLOAK_IMAGE:?set a Keycloak image built from services/identity/Dockerfile}
  # --optimized needs the build-time options baked in by that Dockerfile.
  # --import-realm only creates the realm when it does not exist yet.
  command: ["start", "--optimized", "--import-realm"]
  environment:
    KC_DB: postgres
    KC_DB_URL: jdbc:postgresql://postgres-keycloak:5432/keycloak
    KC_HOSTNAME: ${AUTH_PUBLIC_HOST:?missing AUTH_PUBLIC_HOST}
    KC_HOSTNAME_STRICT: "true"
    # Keycloak 24: TLS terminates at the host proxy which sets X-Forwarded-*.
    KC_PROXY: edge
    KC_HTTP_ENABLED: "true"
    KC_HEALTH_ENABLED: "true"
  volumes:
    - ${KEYCLOAK_REALM_FILE:?set the generated production realm file}:/opt/keycloak/data/import/plantini-realm.json:ro
```

Wichtig an dieser Definition:

- **`start --optimized`** setzt ein Image voraus, das mit `kc.sh build` vorbereitet wurde. Das leistet `services/identity/Dockerfile` (Build-Stufe mit `KC_DB=postgres`, `KC_HEALTH_ENABLED=true`). Das offizielle Image ohne diesen Schritt würde mit `--optimized` nicht starten.
- **`--import-realm`** wirkt nur beim allerersten Start, solange der Realm `plantini` nicht existiert. Spätere Änderungen an der Realm-Datei haben keine Wirkung (Details: [Identität und Keycloak](identity-keycloak.md#import-nur-beim-ersten-start)).
- **`KC_HOSTNAME_STRICT: "true"`** plus `KC_PROXY: edge`: Keycloak 24 akzeptiert nur den konfigurierten Hostnamen (`AUTH_PUBLIC_HOST`) und vertraut den `X-Forwarded-*`-Headern von Caddy. In Keycloak 25 heißt diese Option anders (`KC_PROXY_HEADERS`); die Datei ist auf Version 24 abgestimmt, wie auch `services/identity/Dockerfile` (`quay.io/keycloak/keycloak:24.0.4`).
- **Bootstrap-Administrator:** `KEYCLOAK_ADMIN` / `KEYCLOAK_ADMIN_PASSWORD` (aus `KEYCLOAK_ADMIN_USERNAME`, `KEYCLOAK_ADMIN_PASSWORD`) werden nur verwendet, solange der `master`-Realm leer ist.
- **Healthcheck ohne `curl`:** das Image enthält keines. Der Test öffnet per Bash einen TCP-Socket: `bash -c 'echo > /dev/tcp/127.0.0.1/8080'` (`start_period: 60s`, `retries: 18`). Der Kommentar vermerkt, dass der Health-Endpunkt in Keycloak 24 auf dem Hauptport liegt; ein separater Management-Port 9000 existiert erst ab Version 25.

### Platform

Der Dienst `platform` ist der umfangreichste. Die Umgebung gliedert sich in sechs Gruppen (die vollständige Liste mit Quelle erzeugt [Konfiguration](konfiguration.md) automatisch):

| Gruppe | Variablen (Container) | Quelle in `production.env` |
|---|---|---|
| Datenbank | `DATABASE_CLIENT/HOST/PORT/NAME/USERNAME`, `DATABASE_PASSWORD` | fest im Compose-File; Passwort aus `PLATFORM_DB_PASSWORD` |
| Strapi-Geheimnisse | `APP_KEYS`, `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`, `TRANSFER_TOKEN_SALT`, `JWT_SECRET` | `STRAPI_APP_KEYS`, `STRAPI_API_TOKEN_SALT`, `STRAPI_ADMIN_JWT_SECRET`, `STRAPI_TRANSFER_TOKEN_SALT`, `STRAPI_JWT_SECRET` |
| Ursprünge und CORS | `CORS_ORIGINS`, `PLATFORM_EDITOR_ORIGIN`, `PLATFORM_TEACHER_ORIGIN`, `PUBLIC_URL` | `WEB_PUBLIC_URL`, `EDITOR_PUBLIC_URL`, `TEACHER_PUBLIC_URL`, `API_PUBLIC_URL` |
| OIDC | `PLATFORM_OIDC_ISSUER`, `PLATFORM_OIDC_AUDIENCE` (`plantini-api`), `PLATFORM_OIDC_JWKS_URI`, `PLATFORM_EDITOR_OIDC_CLIENT_ID`, `PLATFORM_TEACHER_OIDC_CLIENT_ID` | `AUTH_PUBLIC_URL`; Client-IDs fest (`plantini-editor-production`, `plantini-teacher-production`) |
| Keycloak-Verwaltung | `PLATFORM_KEYCLOAK_ADMIN_BASE_URL`, `…_CLIENT_ID`, `…_CLIENT_SECRET` | `PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID/SECRET` (leer = Einladungen aus) |
| PlantNet und Inhalte | `PLANTNET_MODE: real`, `PLANTNET_API_KEY`, `PLANTNET_DAILY_REQUEST_LIMIT`, `PLANTNET_QUOTA_RESERVE`, `PLANTNET_CIRCUIT_*`, `PLATFORM_SEED_DEMO_CONTENT`, `PLATFORM_EXTERNAL_PLANT_PHOTOS` | gleichnamig |

Zwei Besonderheiten:

```yaml title="infra/compose.production.yaml"
PLATFORM_OIDC_ISSUER: ${AUTH_PUBLIC_URL:?missing AUTH_PUBLIC_URL}/realms/plantini
PLATFORM_OIDC_JWKS_URI: http://keycloak:8080/realms/plantini/protocol/openid-connect/certs
```

Der **Issuer** ist die öffentliche URL (denn so steht er im Token, `iss`-Claim), die **Schlüsselmenge** holt die Plattform dagegen intern über das `app`-Netz. Beides muss zusammenpassen: Stimmt `AUTH_PUBLIC_URL` nicht mit `KC_HOSTNAME` überein, lehnt die Plattform jedes Token ab.

```yaml title="infra/compose.production.yaml"
CORS_ORIGINS: ${WEB_PUBLIC_URL:?missing WEB_PUBLIC_URL},${EDITOR_PUBLIC_URL:?missing EDITOR_PUBLIC_URL},${TEACHER_PUBLIC_URL:?missing TEACHER_PUBLIC_URL}
```

`CORS_ORIGINS` wird in `services/platform/config/middlewares.js` per `env.array('CORS_ORIGINS', [])` gelesen und ist damit die einzige Freigabeliste für Browser-Clients. Wer die Web-App auf eine neue Adresse umzieht, muss `WEB_PUBLIC_URL` ändern und `platform` neu starten.

!!! warning "Stolperfalle: Demo-Inhalte im Produktionsstack"
    `PLATFORM_SEED_DEMO_CONTENT` ist im Produktionsstack konfigurierbar (Standard `false`). `services/platform/src/index.js` protokolliert beim Einschalten dennoch eine Warnung: „Synthetic E2E content is enabled; never use this flag in staging or production.“ Der Kommentar im Compose-File begründet das mit dem Stand des Projekts: Die 30 Demo-Arten sind der einzige Inhalt und noch nicht botanisch geprüft. Für eine leere Instanz setzt du `false`.

Der Healthcheck der Plattform ist ein Node-Einzeiler gegen die eigene Health-Route:

```yaml title="infra/compose.production.yaml"
healthcheck:
  test: ["CMD-SHELL", "node -e \"fetch('http://127.0.0.1:1337/api/v1/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))\""]
  interval: 10s
  timeout: 5s
  retries: 18
  start_period: 40s
```

Die Route `GET /v1/health` (`services/platform/src/api/platform/controllers/platform.js`) antwortet mit `{ status: 'ok', apiVersion }` und prüft **weder Datenbank noch Redis**. Sie belegt, dass der Prozess Anfragen annimmt, nicht dass die Abhängigkeiten gesund sind. Die Abhängigkeiten sichert stattdessen `depends_on: condition: service_healthy` beim Start ab.

`NODE_OPTIONS: --dns-result-order=ipv4first` bevorzugt IPv4 bei DNS-Auflösung ausgehender Verbindungen – derselbe Schalter wie in den lokalen Stacks (`infra/compose.plantnet.local.yaml`). Das Projekt ist insgesamt „IPv4-first“; eine belegte Ursache steht nicht im Repo.

Das Volume `private-media` enthält die hochgeladenen Nutzerfotos (`PRIVATE_UPLOAD_DIR: /var/lib/plantini/private-media`). Sie sind privat und werden nicht über Caddy ausgeliefert, sondern nur über die API mit Besitzerprüfung (`GET /v1/media/:mediaId/content`).

### Statische Container: `homepage`, `teacher`, `editor`

```yaml title="infra/compose.production.yaml"
homepage:
  image: ${HOMEPAGE_IMAGE:?set the plantini/homepage image built from apps/homepage}
  restart: unless-stopped
  read_only: true
  tmpfs: [/tmp]
  cap_drop: [ALL]
  ports:
    - "127.0.0.1:${HOMEPAGE_LOOPBACK_PORT:-8083}:8080"
  networks: [edge]
  healthcheck:
    test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:8080/healthz | grep -qx ok"]
```

Alle drei sind nginx-unprivileged-Images (Port 8080, kein root). Unterschiede:

| | `homepage` | `teacher` | `editor` |
|---|---|---|---|
| `tmpfs` | `/tmp` | `/tmp`, `/var/cache/nginx`, `/var/run` | `/tmp`, `/var/cache/nginx`, `/var/run` |
| Laufzeitkonfiguration | keine (zur Bauzeit: `PLANTINI_APP_URL`) | `PLANTINI_API_BASE_URL`, `PLANTINI_OIDC_ISSUER_URL`, `PLANTINI_OIDC_CLIENT_ID` | keine – API und Issuer sind in der nginx-CSP fest eingetragen |
| Healthcheck-Intervall | 15 s | 10 s | 15 s |

Das Portal wird beim Start konfiguriert: `apps/teacher/40-teacher-config.sh` validiert die drei öffentlichen Werte (reine HTTP(S)-URLs, Client-ID `[A-Za-z0-9._-]+`), schreibt `/tmp/teacher-config.json` und rendert `nginx.conf.template` per `envsubst` nach `/tmp/teacher-nginx.conf`. Die generierten Dateien liegen unter `/tmp`; `teacher` und `editor` binden zusätzlich `/var/cache/nginx` und `/var/run` als `tmpfs`, damit nginx bei `read_only: true` Laufzeitdateien schreiben kann. Das Studio dagegen hat die Zieladressen **fest in der CSP** (`apps/editor/nginx.conf`) – für eine eigene Domain muss sein Image angepasst werden (siehe [Eigene Instanz](deployment.md#eigene-instanz-fest-verdrahtete-werte)).

### Volumes

```yaml title="infra/compose.production.yaml"
volumes:
  platform-db:
  keycloak-db:
  redis-data:
  private-media:
```

Compose präfixiert sie mit dem Projektnamen: `plantini-production_platform-db`, `…_keycloak-db`, `…_redis-data`, `…_private-media`. Caddys Volumes `caddy-data` und `caddy-config` gehören zum Projekt `plantini-proxy`. Was ein Update überlebt, steht unter [Backup und Beobachtung](backup-monitoring.md#datenhaltung).

### Härtung im Überblick

| Maßnahme | Wo | Stand |
|---|---|---|
| `no-new-privileges:true` | alle Dienste, auch Caddy | gesetzt |
| `read_only: true` | `homepage`, `teacher`, `editor` | gesetzt |
| `cap_drop: [ALL]` | `homepage`, `teacher`, `editor` | gesetzt |
| Ports nur an `127.0.0.1` | alle veröffentlichten Ports | gesetzt |
| Interne Netze | `data`, `app` | gesetzt |
| Nicht-root-Benutzer | Plattform-Image (`USER plantini`, UID 10001), nginx-unprivileged | gesetzt |
| `read_only` / `cap_drop` | `platform`, `keycloak`, Datenbanken, Redis | **nicht** gesetzt |
| Ressourcenlimits (`mem_limit`, `cpus`) | alle | **nicht** gesetzt |
| Log-Rotation (`logging:`) | alle | **nicht** gesetzt (Docker-Standard des Hosts) |

## `compose.yaml` (alt)

Der Entwicklungsstack hinter `start.sh` und `stop.sh` (`docker compose -f infra/compose.yaml up -d`). Er unterscheidet sich vom Produktionsstack grundlegend:

- **`platform`** nutzt `node:20-alpine`, mountet `../services/platform` nach `/opt/app` und startet `npm run develop`; ohne `package.json` wartet er mit `sleep infinity`.
- **Zusätzliche Dienste:** `minio` (S3-kompatibler Speicher, Ports `127.0.0.1:9000`/`9002`), `mailpit` (SMTP-Falle, `127.0.0.1:1025`/`8025`), `plantnet-mock` (`mockserver/mockserver:5.15.0`) und das Profil `tools` mit `playwright`.
- **Keycloak** läuft mit `start-dev --import-realm` und bindet das ganze Verzeichnis `services/identity/realm` als Importquelle.
- **Standardwerte** für alle Geheimnisse (`dummy_…`, `key1,key2`) – nur für lokale Nutzung.

Die Platform-Umgebung in dieser Datei enthält noch `S3_ENDPOINT`/`S3_ACCESS_KEY`; der aktuelle Plattformcode (`services/platform/src`, `config`) enthält keinen Verweis auf `S3_*` oder MinIO – diese Variablen und der Dienst `minio` sind vermutlich Überbleibsel; der Produktionsstack kommt ohne Objektspeicher aus (private Medien liegen im Volume `private-media`).

!!! note "Veraltete Runbooks"
    `operations/runbooks/deployment.md` und `operations/runbooks/backup-restore.md` beschreiben noch diesen alten Stack (`infra/compose.yaml`, MinIO, Health-Pfad `/_health`, Container `plantini-postgres-platform-1`). Der Produktionsstack heißt `plantini-production`, die Health-Route `/api/v1/health` und die Container `plantini-production-postgres-platform-1`. Nutze diese beiden Dateien nicht als Quelle.

## `compose.e2e.yaml`

Eine frische, isolierte Integrationsumgebung: Passwörter werden zur Laufzeit erzeugt (`tools/e2e/scripts/prepare-e2e-env.mjs` schreibt eine ignorierte Datei unter `tools/e2e/.runtime/`), jeder Host-Port ist an IPv4-Loopback gebunden.

| Dienst | Image | Besonderheit |
|---|---|---|
| `postgres-platform`, `postgres-keycloak` | `postgres:16.4-alpine` | Volumes `e2e-platform-db`, `e2e-keycloak-db` |
| `redis` | `redis:7.4.2-alpine` | Volume `e2e-redis` |
| `plantnet-mock` | gebaut aus `infra/plantnet-mock` (`plantini/plantnet-mock:e2e`) | `PLANTNET_MOCK_MODE` über `E2E_PLANTNET_MODE` (`success` …) |
| `keycloak` | `quay.io/keycloak/keycloak:24.0.4` | `start-dev --import-realm --http-enabled=true`, Host-Port `127.0.0.1:8082` |
| `keycloak-bootstrap` | wie `keycloak` | einmaliger Job: legt den synthetischen Lerner an (`infra/scripts/keycloak-bootstrap-e2e.sh`) |
| `platform` | gebaut aus `services/platform` (`plantini/platform:e2e`) | `PLANTNET_MODE: mock`, `PLATFORM_SEED_DEMO_CONTENT: 'true'`, Port `127.0.0.1:1338` |
| `web` | `nginx:1.27.4-alpine` | liefert `apps/flutter/build/web` mit `infra/nginx/e2e.conf` (Fallback auf `index.html`, `/healthz`), Port `127.0.0.1:3000` |

Der Start läuft über `tools/e2e/scripts/run-e2e-stack.sh` (npm-Skript `stack:up` in `tools/e2e`): Es baut die Web-App mit `--dart-define=PLANTINI_ENV=development`, fährt vorher `down --volumes` und startet die dauerhaften Dienste; der Bootstrap-Job läuft separat per `run --rm --no-deps keycloak-bootstrap`, weil Compose einen erfolgreich beendeten Einmal-Dienst unter `up --wait` als Fehler wertet (Kommentar im Skript). `stack:down` räumt Volumes weg.

Unterschiede zur Produktion, die bei Fehlersuche zählen:

- Keycloak läuft im Entwicklungsmodus (`start-dev`), mit `KC_HOSTNAME_STRICT: 'false'` und Importquelle `services/identity/realm` (also dem **Entwicklungs-Realm** mit den `-dev`-Clients).
- Aussteller und Browser-Adresse sind `http://127.0.0.1:8082/realms/plantini`; die Plattform holt die Schlüssel über das Docker-Netz (`http://keycloak:8080/…`). Dasselbe Muster wie in der Produktion, nur mit HTTP.
- Alle Dienste liegen im Standardnetz des Projekts, es gibt weder `internal`-Netze noch Härtung.

## Overlays für den lokalen Stack

Die vier `*.local.yaml`-Dateien werden mit `-f` hinter `compose.e2e.yaml` (bzw. `compose.yaml`) gelegt und erhalten dessen benannte Volumes.

=== "Studio (`compose.editor.local.yaml`)"

    ```yaml title="infra/compose.editor.local.yaml"
    services:
      platform:
        environment:
          CORS_ORIGINS: http://127.0.0.1:3000,http://127.0.0.1:8084
          PLATFORM_EDITOR_ORIGIN: http://127.0.0.1:8084
          PLATFORM_EDITOR_OIDC_CLIENT_ID: plantini-editor-dev
          PLATFORM_SEED_DEMO_CONTENT: 'false'

      editor:
        image: plantini/editor:local
        build:
          context: ../apps/editor
        ports:
          - "127.0.0.1:8084:8080"
    ```

    Das Overlay erweitert CORS um den Studio-Ursprung, wählt den Dev-Client und schaltet die Demo-Inhalte ab.

=== "Portal (`compose.teacher.local.yaml`)"

    Setzt zusätzlich `PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID` und `…_SECRET` als **Pflichtvariablen** (`${…:?run configure-managed-accounts.mjs}`) und startet `teacher` mit `read_only`, `tmpfs` und `cap_drop: [ALL]` auf `127.0.0.1:8085`, Client `plantini-teacher-dev`. Die Variablen erzeugt `tools/scripts/configure-managed-accounts.mjs` (siehe [Identität und Keycloak](identity-keycloak.md#verwaltete-konten)).

=== "Backend-Entwicklung (`compose.authoring.local.yaml`)"

    ```yaml title="infra/compose.authoring.local.yaml"
    services:
      platform:
        volumes:
          - ../services/platform/src:/opt/plantini/src:ro
    ```

    Der Quelltext `services/platform/src` wird read-only über den vorhandenen Code im Image gelegt; Abhängigkeiten und Admin-Build bleiben aus dem Image. Aufruf laut Kommentar: `docker compose --env-file tools/e2e/.runtime/e2e.env -f infra/compose.e2e.yaml -f infra/compose.authoring.local.yaml up -d --no-build --wait platform`.

=== "Echtes PlantNet (`compose.plantnet.local.yaml`)"

    Nur zusammen mit `infra/compose.yaml`. Setzt `PLANTNET_MODE: real` und lädt den Schlüssel aus einer nicht versionierten Datei (`env_file`). Der Startbefehl exportiert den Schlüssel nur für den Backend-Prozess und entfernt die Quellvariable danach (`unset API_KEY SUBSCRIPTION`). Die CI und `compose.e2e.yaml` verwenden bewusst weiter den Mock.

Die gleiche Idee – ein dünnes Overlay statt einer Kopie des Stacks – steckt in den **Release-Overlays** der Images (`Dockerfile.release-overlay`), siehe [Deployment](deployment.md#release-overlays).

## `compose.proxy.yaml`

```yaml title="infra/production/compose.proxy.yaml"
services:
  caddy:
    image: ${CADDY_IMAGE:-caddy:2.8.4-alpine}
    restart: unless-stopped
    network_mode: host
    environment:
      PLANTINI_DOMAIN: ${PLANTINI_DOMAIN:?missing PLANTINI_DOMAIN}
      ACME_EMAIL: ${ACME_EMAIL:?missing ACME_EMAIL}
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ${WEB_ROOT:?set the directory with the Flutter web build}:/srv/web:ro
      - ${DOWNLOADS_DIR:-/opt/plantini/downloads}:/srv/downloads:ro
      - caddy-data:/data
      - caddy-config:/config
    security_opt: [no-new-privileges:true]
```

- **`network_mode: host`:** Caddy bindet 80/443 direkt am Host und erreicht die Anwendungen über deren Loopback-Ports (`127.0.0.1:…`). Deshalb müssen alle Dienste ihre Ports an `127.0.0.1` veröffentlichen.
- **Variablen:** `PLANTINI_DOMAIN`, `ACME_EMAIL`, `WEB_ROOT` und optional `DOWNLOADS_DIR`, `CADDY_IMAGE` kommen aus derselben `production.env` (`--env-file`). `infra/production.env.example` führt sie **nicht** auf – du musst sie selbst ergänzen.
- **Kopplung an `<deploy-root>`:** `WEB_ROOT` und `DOWNLOADS_DIR` müssen auf `<deploy-root>/web` und `<deploy-root>/downloads` zeigen, weil `promote-public-assets.mjs` genau dorthin schreibt (und `backup.sh` `downloads/plantini.json` relativ zu `$ROOT` sichert). Andernfalls veröffentlicht das Skript Dateien, die Caddy nie ausliefert.
- **Volumes:** `caddy-data` hält Zertifikate und ACME-Konto; ein Verlust löst eine Neuausstellung aus (und kann Ausstellungslimits berühren). Deshalb sichert `backup.sh` dieses Volume.
- **Zwei Datei-/Verzeichnis-Mounts mit Folgen:** `Caddyfile` ist ein *einzelne Datei* als Bind-Mount, `WEB_ROOT` ein Verzeichnis. Bei Einzeldatei-Mounts hält der Container den Inode fest. Wer das `Caddyfile` ersetzt, indem er eine neue Datei darüber umbenennt, ändert für den Container nichts. Das Skript `promote-public-assets.mjs` verfolgt denselben Gedanken für das Web-Verzeichnis (siehe [Deployment](deployment.md#web-app-und-apk-veroffentlichen)).

!!! tip "Caddyfile ändern"
    Schreibe den Inhalt *in die bestehende Datei* (`cat neues-Caddyfile > <deploy-root>/infra/production/Caddyfile`) und lade danach neu. Details im [Deployment](deployment.md#caddy-aktualisieren).

## Umgebungsvariablen und ihre Quelle

Die Kette ist durchgehend dieselbe:

1. `infra/production.env.example` – Vorlage der Namen (versioniert, ohne Werte).
2. `<deploy-root>/production.env` – echte Werte (nicht versioniert, nur root).
3. `docker compose --env-file production.env -f …` – Compose ersetzt `${VAR}` im Compose-File.
4. Container-Umgebung – nur was im `environment:`-Block steht, kommt im Container an.

Wichtig: Eine Variable in `production.env` ist **nicht** automatisch im Container. `ACME_EMAIL` etwa wirkt nur, weil `compose.proxy.yaml` sie explizit weiterreicht. Umgekehrt (siehe oben) werden `HOMEPAGE_PORT`, `EDITOR_PORT` und `TEACHER_PORT` vom Caddyfile erwartet, aber nie gesetzt.

Die Werte-Gruppen der Vorlage:

| Gruppe | Variablennamen |
|---|---|
| Images | `PLATFORM_IMAGE`, `POSTGRES_IMAGE`, `REDIS_IMAGE`, `KEYCLOAK_IMAGE`, `HOMEPAGE_IMAGE`, `EDITOR_IMAGE`, `TEACHER_IMAGE` |
| Öffentliche Adressen | `WEB_PUBLIC_URL`, `EDITOR_PUBLIC_URL`, `TEACHER_PUBLIC_URL`, `API_PUBLIC_URL`, `AUTH_PUBLIC_URL`, `AUTH_PUBLIC_HOST` |
| Loopback-Ports | `API_LOOPBACK_PORT`, `HOMEPAGE_LOOPBACK_PORT`, `EDITOR_LOOPBACK_PORT`, `TEACHER_LOOPBACK_PORT`, `AUTH_LOOPBACK_PORT` |
| Realm | `KEYCLOAK_REALM_FILE` |
| Geheimnisse | `PLATFORM_DB_PASSWORD`, `KEYCLOAK_DB_PASSWORD`, `STRAPI_APP_KEYS`, `STRAPI_API_TOKEN_SALT`, `STRAPI_ADMIN_JWT_SECRET`, `STRAPI_TRANSFER_TOKEN_SALT`, `STRAPI_JWT_SECRET`, `PLANTNET_API_KEY`, `KEYCLOAK_ADMIN_USERNAME`, `KEYCLOAK_ADMIN_PASSWORD` |
| Verwaltungskonto | `PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID`, `PLATFORM_KEYCLOAK_ADMIN_CLIENT_SECRET` |
| PlantNet | `PLANTNET_PROJECT`, `PLANTNET_LANGUAGE`, `PLANTNET_MAX_RESULTS`, `PLANTNET_DAILY_REQUEST_LIMIT`, `PLANTNET_QUOTA_RESERVE`, `PLANTNET_CIRCUIT_FAILURE_THRESHOLD`, `PLANTNET_CIRCUIT_COOLDOWN_MS` |
| Inhalte | `PLATFORM_SEED_DEMO_CONTENT`, `PLATFORM_EXTERNAL_PLANT_PHOTOS` |
| Nur Eingang (fehlen in der Vorlage) | `PLANTINI_DOMAIN`, `ACME_EMAIL`, `WEB_ROOT`, `DOWNLOADS_DIR`, `CADDY_IMAGE` |
| Nur Skripte (fehlen in der Vorlage) | `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD` (für `configure-smtp.sh`) |

!!! warning "Stolperfalle: `PLATFORM_KEYCLOAK_ADMIN_CLIENT_ID` leer lassen"
    Beide Variablen haben in der Compose-Datei den Standard `:-` (leer). Dann sind Einladungen und das Anlegen verwalteter Schülerkonten deaktiviert, ohne dass der Start fehlschlägt. Die Vorlage nennt als Rechte nur `view-users`, `manage-users` und `view-realm`; das Skript `tools/scripts/configure-managed-accounts.mjs` vergibt tatsächlich vier (`manage-users`, `view-users`, `query-users`, `view-realm`). Gilt der Code: vier Rollen.

## Prüfen, ohne etwas zu starten

Diese Befehle ändern nichts am Host:

```bash
# Fehlende Pflichtvariablen sofort sichtbar machen (liest nur die Datei)
docker compose --env-file <deploy-root>/production.env \
  -f infra/compose.production.yaml config --quiet

# Aufgelöste Konfiguration anzeigen (enthält Geheimnisse – nicht in Logs/Tickets kopieren)
docker compose --env-file <deploy-root>/production.env \
  -f infra/compose.production.yaml config

# Zustand und Healthchecks
docker compose --env-file <deploy-root>/production.env \
  -f infra/compose.production.yaml ps
```

## Weiterführend

- [Betrieb: Überblick](index.md) – Zielbild und Netzdiagramm
- [Deployment](deployment.md) – Images bauen, übertragen, `up -d`
- [Identität und Keycloak](identity-keycloak.md) – Realm-Import und Clients
- [Konfiguration (generiert)](konfiguration.md) und [Ports und Dienste (generiert)](../referenz/ports-dienste.md)
- [Plattform](../backend/plattform.md) – was `platform` im Container ausführt
- Quellen: `infra/compose.production.yaml`, `infra/compose.e2e.yaml`, `infra/compose.yaml`, `infra/production/compose.proxy.yaml`, `infra/production/Caddyfile`, `infra/production.env.example`, `services/identity/Dockerfile`, `services/platform/Dockerfile`
