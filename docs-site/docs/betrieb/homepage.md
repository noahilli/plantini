# Projekt-Homepage

Die Projekt-Homepage in `apps/homepage` ist eine rein statische Seite (Vite + three.js), die ein kleiner nginx-Container ausliefert. Sie stellt Plantini vor, zeigt die drei Ökosysteme als interaktive 3D-Szenen, hostet die Rückkehrseite für die Android-Anmeldung und verweist auf den APK-Download. Sie lädt nichts von Drittanbietern nach.

!!! note "Wo sie im Betrieb sitzt"
    Der Container `homepage` (Port 8080, am Host `127.0.0.1:8083`) bedient die Apex-Domain `<domain>`. Caddy leitet alles außer `/download/*` an ihn weiter und liefert `/download/*` selbst aus einem Verzeichnis des Servers ([Überblick](index.md#zielbild)). Die Web-App läuft getrennt unter `app.<domain>`.

## Aufbau des Projekts

```
apps/homepage/
├── index.html                 Startseite
├── technik/index.html         „So ist Plantini gebaut“
├── impressum/index.html       Impressum
├── datenschutz/index.html     Datenschutzerklärung
├── bildnachweise/index.html   Foto-Urheber und Lizenzen (aus content.json erzeugt)
├── app/login/index.html       Rückkehrseite der App-Anmeldung
├── src/
│   ├── main.js                Startseite: Navigation, 3D-Bühnen, Karten, Download-Hinweis
│   ├── world.js               Blender-Module → three.js-Geometrie
│   ├── cards.js               Pflanzen-Karteikarten als DOM
│   ├── config.js              Store-Links
│   ├── applink.js             Logik der Seite /app/login
│   ├── legal.js               Bildnachweise rendern
│   ├── content.json           Inhalte-Snapshot (Ökosysteme, Pflanzen, Fotos)
│   └── style.css              gemeinsames Stylesheet
├── public/                    wird unverändert nach dist/ kopiert
│   ├── photos/                verkleinerte Pflanzenfotos
│   ├── worlds/{forest,meadow,alpine}.json   Blender-Module (gerundet)
│   ├── .well-known/assetlinks.json          Android App Links
│   ├── flutter_service_worker.js            selbst-deregistrierender Service Worker
│   ├── 404.html, favicon.svg, robots.txt
├── scripts/snapshot-content.mjs
├── nginx.conf, security-headers.conf, Dockerfile
└── vite.config.js
```

`package.json` zieht nur vier Abhängigkeiten: `three` (0.186.1), `vite` (8.3.1) und die selbst gehosteten Schriften `@fontsource-variable/fraunces` und `@fontsource-variable/inter` (je 5.3.0). Node ≥ 20 ist erforderlich (`engines`).

### Seiten

| Adresse | Datei | Inhalt |
|---|---|---|
| `/` | `index.html` | Abschnitte Idee, Ökosysteme (3D), Karteikarten, Schulen, Mitmachen, Preise, Software; Download-Hinweis |
| `/technik/` | `technik/index.html` | Architekturüberblick, Anbieterwahl, Erweiterbarkeit, ehrlicher Stand |
| `/impressum/` | `impressum/index.html` | Anbieterkennzeichnung (Angaben des Betreibers), Kontakt `noah@illmann.net` |
| `/datenschutz/` | `datenschutz/index.html` | Verantwortlicher, was die Seite technisch tut, Hosting, Weitergabe, Betroffenenrechte |
| `/bildnachweise/` | `bildnachweise/index.html` | Liste aller Fotos mit Urheber, Lizenz und Quelle |
| `/app/login` | `app/login/index.html` | Brücke zurück in die Android-App ([Android-Release](android-release.md#anmeldung-und-app-links)) |
| jede unbekannte Adresse | `public/404.html` | Fehlerseite, `noindex` |

Alle Rechtsseiten und die Technikseite tragen am Ende einen Abschnitt „Hinweis zum Stand des Projekts“ mit den vier Aussagen: Die Ideen stammen von einer dritten Person; das Projekt ist noch nicht veröffentlicht (die Seite zeigt einen unvollständigen Teaser); es gibt keinen kommerziellen Hintergrund (keine Spenden, keine Zahlungen); es ist noch nicht Open Source, weil die Rechte nicht beim Entwickler liegen. Dieselben Aussagen gelten für dieses Handbuch.

!!! warning "Offener Punkt: widersprüchliche Texte auf der Startseite"
    `apps/homepage/index.html` verwendet in der Meta-Beschreibung, im Open-Graph-Text und im Hero-Eyebrow noch ein Lizenz-Etikett (Treffer für `Source` in der Datei) und enthält einen Abschnitt „Ein offenes Projekt, das wächst“. Das widerspricht dem Projektstatus und den Hinweisen auf den übrigen Seiten. Auch `technik/index.html` sagt, „automatisierte Sicherungen und Überwachung fehlen noch“ – eine nächtliche Sicherung existiert inzwischen ([Backup und Beobachtung](backup-monitoring.md)), Überwachung nicht. Die Texte müssen vom Betreiber bereinigt werden; dieses Handbuch ändert sie nicht.

Das README nennt „markierte Platzhalter (`.todo`)“ in den Rechtsseiten. In den aktuellen HTML-Dateien gibt es keinen Treffer mehr; nur die CSS-Klasse `.legal .todo` in `src/style.css` ist übrig. Rechtliche Angaben (Anbieter, Verantwortlicher, Hoster) sind **betreiberspezifisch**: Wer eine eigene Instanz betreibt, ersetzt sie vollständig.

## Inhalte

### `src/content.json` – der Inhalte-Snapshot

Die Homepage hat zur Laufzeit **keine** API-Abhängigkeit. Alle Pflanzentexte und Foto-Metadaten stehen in einer eingecheckten Datei, die `scripts/snapshot-content.mjs` erzeugt. Struktur (gekürzt):

```json title="apps/homepage/src/content.json (Struktur)"
{
  "generatedAt": "…",
  "releaseVersion": "demo",
  "ecosystems": [
    {
      "key": "wald", "short": "Wald", "world": "forest",
      "slug": "mitteleuropaeischer-laubwald",
      "name": "…", "description": "…",
      "plants": [
        {
          "slug": "rotbuche", "commonName": "Rotbuche",
          "scientificName": "Fagus sylvatica", "family": "…",
          "description": "…", "warning": "…",
          "notes": [{ "heading": "Rinde", "text": "…" }],
          "photos": [{
            "file": "rotbuche-1.jpg", "alt": "…", "author": "…",
            "license": "cc-by", "licenseLabel": "CC BY", "source": "https://…"
          }]
        }
      ]
    }
  ]
}
```

Der Snapshot enthält drei Ökosysteme (`wald`, `wiese`, `alpen`) mit je sechs Pflanzen, zusammen 26 Fotos. Er entsteht so (`scripts/snapshot-content.mjs`):

- Die **Texte** kommen aus dem Demo-Datensatz der Plattform (`services/platform/src/api/platform/services/core/content/demo-content.de.json`), je Ökosystem die ersten sechs Pflanzen („Stationen“), je Pflanze höchstens drei Lernkarten als `notes`.
- Die **Fotos** holt das Skript von der Fach-API (`/api/v1/plants/<id>`) des angegebenen Ursprungs (`node scripts/snapshot-content.mjs [api-origin]`) und übernimmt höchstens zwei je Pflanze.
- **Lizenzfilter:** nur `cc0`, `pd` (gemeinfrei), `cc-by` und `cc-by-sa`; ein Foto ohne Autor oder Quelle wird übersprungen. Nicht verifizierte oder NC/ND-Fotos kommen nie hinein.
- Jedes Foto wird mit Python/Pillow auf höchstens 1000 px Kantenlänge verkleinert (JPEG, Qualität 80, progressiv) und unter `public/photos/` abgelegt. Das Skript braucht daher `python3` mit Pillow und löscht `public/photos/` zu Beginn.
- Eine redaktionelle Tabelle `PREFERRED_FIRST` legt fest, welches Foto zuerst gezeigt wird.

Das Feld `generatedAt` im Snapshot zeigt, wann er zuletzt gezogen wurde. Der Snapshot wird **von Hand** erneuert – es gibt keine Automatik.

### `src/config.js` – Store-Links

```javascript title="apps/homepage/src/config.js"
export const STORE_URLS = {
  play: null, // e.g. 'https://play.google.com/store/apps/details?id=...'
  apple: null, // e.g. 'https://apps.apple.com/app/id...'
};
```

Solange ein Wert `null` ist, bleibt die Schaltfläche ein deaktivierter Hinweis „Bald bei Google Play“. Trägst du eine URL ein, ersetzt `initStores()` in `main.js` das Element durch einen Link und ändert „Bald“ in „Jetzt“. Es gibt aktuell keine Store-Einträge ([Android-Release](android-release.md#nicht-gepruft)).

### `src/cards.js` – Karteikarten

`renderCard(plant, ecosystem, { compact })` baut eine Karte (Kopf „PLANTINI / FELDNOTIZEN“, Foto mit Urheber-Zeile, Name, Familie, Beschreibung, nummerierte Merkmale, Sicherheitshinweis). `renderMosaic` zeigt zwölf Fotos (zuerst je ein Foto jeder Pflanze, dann die zweiten), `renderCredits` erzeugt die Liste der Bildnachweise.

Alle Texte werden ausschließlich über `textContent` eingefügt (Dateikommentar: „inserted with textContent only“). Das erfüllt zugleich die strenge Content-Security-Policy und schließt Skript-Einschleusung über Inhalte aus.

### `src/world.js` – 3D-Module

Die Dateien `public/worlds/{forest,meadow,alpine}.json` sind die Blender-Module der App in gerundeter Form (Quelle laut README: `apps/flutter/assets/worlds`). `world.js` übersetzt sie in three.js:

- Blender ist z-nach-oben, three.js y-nach-oben: `toThree([x, y, z]) = [x, z, -y]`.
- Meshes werden **nach Verhalten zusammengefasst** (`static`, `sway`, `water`, `ranger`), damit eine Szene nur eine Handvoll Draw-Calls kostet. `mergeGeometries` aus three.js übernimmt das; die Flächen werden nicht indiziert, was den flachen Low-Poly-Look ergibt.
- Pflanzen und Bäume schwanken über einen kleinen Vertex-Shader-Einschub (`onBeforeCompile` mit `aWeight`, `aPhase`, `aAmp`, `uTime`), Wasserflächen glitzern über die Alpha-Komponente, der Ranger hüpft leicht (`ranger.position.y`).
- `slots` sind die sechs Stationen eines Moduls; `main.js` legt dort nummerierte Schaltflächen über das Bild.
- Daten werden pro URL zwischengespeichert (`loadWorldData`).

Wie die Module in Blender entstehen, beschreibt die Seite [Blender-Pipeline](../3d/blender-pipeline.md).

### Download-Hinweis

`initApk()` in `main.js` lädt `/download/plantini.json` (`cache: 'no-cache'`) und baut daraus den Hinweis „Testversion · Version … · … MB · ab Android … SHA-256: …“. Fehlt die Datei oder schlägt der Abruf fehl, bleibt der statische Text stehen. So zeigt die Seite nie Zahlen, die nicht zur verlinkten Datei gehören. Die JSON-Datei erzeugt `tools/scripts/prepare-app-release.mjs` ([Android-Release](android-release.md#metadaten-und-veroffentlichung)).

## Adaptive Qualität und Lite-Modus

Die Szenen sind klein (unter 20 000 Vertices); die Kosten entstehen durch Pixelmenge und Bildrate. `src/main.js` begrenzt deshalb beides und passt sich der Leistung an:

| Mechanismus | Wert im Code |
|---|---|
| Pixeldichte | höchstens 1,5; auf Touch-Geräten (`pointer: coarse`) 1,25; bei Software-Rendering 1 |
| Bildrate | höchstens ~30 Bilder pro Sekunde (Mindestabstand 30 ms) |
| Pausieren | Zeichnet nur, solange die Bühne sichtbar (`IntersectionObserver`, Schwelle 5 %) und der Tab im Vordergrund ist |
| Auflösung senken | Median von 12 Frames > 50 ms → Pixeldichte × 0,75, mindestens 0,65 |
| Lite-Modus (automatisch) | wenn die Auflösung nicht mehr hilft, oder bei drei Frames über 500 ms hintereinander |
| Lite-Modus (sofort) | Software-Renderer (SwiftShader, llvmpipe, softpipe …, erkannt über `WEBGL_debug_renderer_info`), `prefers-reduced-motion` oder `?perf=lite` |
| Erzwingen | `?perf=lite` oder `?perf=full` an die URL |

Im **Lite-Modus** läuft keine Dauerschleife: die Szene wird nur bei Interaktion (Ziehen, Hover, Auswahl) neu gezeichnet; Schwanken und Autorotation entfallen. An jeder Bühne gibt es einen Schalter „Animation pausieren/abspielen“ (WCAG 2.2.2). Fehlt WebGL, zeigt die Bühne einen Hinweis („Die 3D-Ansicht braucht WebGL … die App funktioniert trotzdem“) und der Rest der Seite bleibt benutzbar. Die zweite Bühne (Demo) startet über `requestIdleCallback`, damit der Seitenaufbau nicht blockiert.

```javascript title="apps/homepage/src/main.js"
const forcedPerf = new URLSearchParams(window.location.search).get('perf');
const software = forcedPerf === 'lite' || (forcedPerf !== 'full' && softwareRenderer());
const coarsePointer = window.matchMedia('(pointer: coarse)').matches;
const maxRatio = software ? 1 : Math.min(window.devicePixelRatio || 1, coarsePointer ? 1.25 : 1.5);
```

## Build und Image

Lokal (Befehle aus `apps/homepage/README.md` und `package.json`):

```bash
cd apps/homepage
npm ci && npm run dev            # Entwicklung mit Vite
npm run build                    # erzeugt dist/
docker build -t plantini/homepage:dev .
```

`vite.config.js` erzeugt sechs HTML-Einstiegspunkte (`main`, `impressum`, `datenschutz`, `bildnachweise`, `technik`, `applogin`) und ersetzt in allen HTML-Dateien den Platzhalter `__APP_URL__` durch die Adresse der Web-App (Plugin `plantini-tokens`):

```javascript title="apps/homepage/vite.config.js"
const APP_URL = process.env.PLANTINI_APP_URL || 'https://app.<Projektdomain>';   // im Quelltext: die Produktionsadresse des Projekts
```

Der Standard ist die fest eingetragene Produktionsadresse des Projekts; für eine eigene Instanz übergibst du sie beim Image-Build:

```bash
docker build -t plantini/homepage:$REL --build-arg PLANTINI_APP_URL=https://app.<domain> apps/homepage
```

Das Dockerfile hat zwei Stufen: `node:20.20.2-bookworm-slim` führt `npm ci` und `npm run build` aus; `nginxinc/nginx-unprivileged:1.27.4-alpine` liefert `dist/` auf Port 8080 aus (`EXPOSE 8080`, kein root). Im Betrieb läuft der Container `read_only` mit `tmpfs: [/tmp]`, `cap_drop: [ALL]` und `no-new-privileges` ([Compose-Dateien](compose.md#statische-container-homepage-teacher-editor)).

Lokal ausprobieren (Muster, nicht aus einem Skript):

```bash
docker run --rm -p 127.0.0.1:8083:8080 --read-only --tmpfs /tmp plantini/homepage:dev
curl -fsS http://127.0.0.1:8083/healthz     # ok
```

## nginx und Sicherheits-Header

`nginx.conf` und `security-headers.conf` werden ins Image kopiert (`/etc/nginx/conf.d/default.conf`, `/etc/nginx/plantini-headers.conf`).

| Pfad | Verhalten |
|---|---|
| `/healthz` | `200 ok` (Text) – Healthcheck des Containers und des Eingangs |
| `/assets/` | gehashte Build-Ausgabe: `Cache-Control: public, max-age=31536000, immutable` |
| `/photos/…`, `/worlds/…` | `public, max-age=86400` (Namen bleiben gleich → tägliche Revalidierung) |
| `/flutter_service_worker.js` | `no-cache` |
| `/app/login` | `no-store`, liefert `/app/login/index.html` **ohne** Verzeichnis-Weiterleitung |
| alles andere | `no-cache`, `try_files $uri $uri/ =404`; Fehlerseite `404.html` |

Weitere Einstellungen: `absolute_redirect off` und `server_tokens off`, `gzip` für Text-, JSON- und SVG-Typen.

!!! warning "Stolperfalle: `add_header` wird nicht vererbt"
    In nginx gelten `add_header`-Zeilen eines äußeren Blocks nicht mehr, sobald ein `location` eigene `add_header` setzt. Deshalb steht `include /etc/nginx/plantini-headers.conf;` in **jedem** `location` (Kommentar in `security-headers.conf`). Wer einen neuen `location`-Block ergänzt, muss die Einbindung wiederholen, sonst fehlt die CSP auf diesem Pfad.

Inhalt von `security-headers.conf`:

```nginx title="apps/homepage/security-headers.conf"
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; font-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=(), interest-cohort=()" always;
```

Konsequenzen der strikten CSP:

- Es darf **kein** Inline-Skript und kein Inline-`<style>` oder `style="…"`-Attribut im HTML stehen; alles kommt aus Dateien desselben Ursprungs. Vite erzeugt diese Dateien im Build. Stile, die zur Laufzeit per Skript gesetzt werden (`element.style.transform` für die Stationsmarker), sind davon nicht betroffen.
- `connect-src 'self'`: `fetch` geht nur an den eigenen Ursprung (z. B. `/download/plantini.json`, `/worlds/*.json`).
- `img-src 'self' data:`: Fotos kommen aus `/photos/`; Fremdbilder würden blockiert.
- `form-action 'none'`: die Seite hat keine Formulare. Kontakt läuft über einen `mailto:`-Link.

Zusätzlich setzt Caddy für den Apex-Host `Strict-Transport-Security`, `X-Content-Type-Options` und `Referrer-Policy` und entfernt den `Server`-Header (`(security_headers)` im `Caddyfile`).

## Selbst-deregistrierender Service Worker

Früher lieferte dieser Ursprung die Flutter-Web-App aus, die einen Service Worker registrierte. Wiederkehrende Besucher hätten sonst weiter die gecachte App statt der Homepage gesehen. `public/flutter_service_worker.js` ersetzt den alten Worker durch einen, der sich beim Aktivieren selbst abmeldet und alle offenen Fenster neu lädt:

```javascript title="apps/homepage/public/flutter_service_worker.js"
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    await self.registration.unregister();
    for (const client of await self.clients.matchAll({ type: 'window' })) client.navigate(client.url);
  })());
});
```

nginx liefert die Datei mit `Cache-Control: no-cache`, damit Browser den Ersatz sofort holen. Auf einer neuen Domain, auf der nie eine Flutter-App lag, ist die Datei überflüssig und kann entfallen.

## Android App Links

Zwei Dateien der Homepage gehören zur Anmeldung der Android-App:

- `public/.well-known/assetlinks.json` – ordnet `https://<domain>` dem Paket `eu.plantini.app` und dem Signatur-Fingerabdruck zu (Struktur und Bestimmung des Fingerabdrucks: [Android-Release](android-release.md#assetlinksjson)). Die Datei enthält das SHA-256 des Release-Zertifikats; bei einem Schlüsselwechsel muss sie angepasst werden.
- `app/login/index.html` + `src/applink.js` – die Seite, auf die Keycloak nach der Anmeldung zurückleitet. Hat Android die App nicht schon direkt geöffnet, leitet `applink.js` nach 150 ms `code` und `state` an `eu.plantini.app://oauth2redirect` weiter und zeigt den Knopf „In Plantini öffnen“. Bei einem `error`-Parameter erscheint „Anmeldung abgebrochen“; ohne `code` ein Hinweis und kein Knopf.

## Datenschutzprinzip

Die Seite ist so gebaut, dass beim Besuch **keine Drittanbieter** kontaktiert werden:

- Schriften (`@fontsource-variable/*`), three.js, Bilder und 3D-Modelle kommen vom eigenen Server; im Build liegen die `.woff2`-Dateien unter `dist/assets/`.
- Die Content-Security-Policy erzwingt das (`default-src 'self'`).
- Es gibt weder Analyse noch Cookies; die Datenschutzerklärung sagt es ausdrücklich („Keine Cookies, kein Tracking, keine Analyse“).
- Externe Adressen erscheinen nur als Links, die erst beim Klick geöffnet werden (Bildquellen, Web-App).

Ein Vorbehalt: Welche Server-Logs der Host und der Eingang tatsächlich schreiben, ist nicht Teil der Seite; Caddy hat im `Caddyfile` keine `log`-Direktive ([Backup und Beobachtung](backup-monitoring.md#logs)). Die Datenschutzerklärung nennt „Server-Protokolle … dauerhaft gespeichert“; ob das mit der tatsächlichen Konfiguration übereinstimmt, ist nicht geprüft.

## Neue Instanz: Checkliste

- [ ] `PLANTINI_APP_URL` beim Build setzen (`--build-arg`)
- [ ] `index.html` (`og:url`) und `app/login/index.html` (Link zur Web-App) auf die eigene Domain ändern
- [ ] `public/.well-known/assetlinks.json` mit dem Fingerabdruck des eigenen Release-Schlüssels
- [ ] Impressum und Datenschutz mit eigenen Angaben ersetzen; Startseitentexte zum Projektstatus prüfen
- [ ] `node scripts/snapshot-content.mjs <eigene-api>` ausführen, wenn der Katalog abweicht
- [ ] Bei Bedarf `STORE_URLS` eintragen
- [ ] Image bauen, übertragen, `HOMEPAGE_IMAGE` setzen, `up -d homepage` ([Deployment](deployment.md))

## Weiterführend

- [Betrieb: Überblick](index.md) · [Compose-Dateien](compose.md) · [Deployment](deployment.md) · [Android-Release](android-release.md)
- [Blender-Pipeline](../3d/blender-pipeline.md) – Herkunft der 3D-Module
- Quellen: `apps/homepage/src/main.js`, `apps/homepage/src/world.js`, `apps/homepage/src/cards.js`, `apps/homepage/src/config.js`, `apps/homepage/nginx.conf`, `apps/homepage/security-headers.conf`, `apps/homepage/Dockerfile`, `apps/homepage/vite.config.js`, `apps/homepage/scripts/snapshot-content.mjs`, `apps/homepage/README.md`
