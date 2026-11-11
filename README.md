# Plantini

**Pflanzen kennenlernen – in Ökosystemen lernen, draußen entdecken, Funde sammeln.**

Plantini ist eine offene Lernplattform für Artenkenntnis, gedacht besonders für Schulen. Lernende wandern durch Wald, Wiese und Alpen, lernen in kurzen Leveln Pflanzen kennen, üben mit Quiz und Karteikarten, fotografieren Pflanzen draußen, lassen sie bestimmen und legen ein privates Herbarium an, das auch offline funktioniert. Lehrende verwalten Klassen und sehen den Lernfortschritt; eine Redaktion pflegt Steckbriefe und Fragen.

> **Früher Stand.** Plantini läuft öffentlich als Demo unter <https://plantini.eu>, ist aber kein fertiges Produkt: 30 Arten in 3 Ökosystemen, Inhalte botanisch noch nicht freigegeben, iOS nicht gebaut. Offene Punkte: [`todos.md`](todos.md).

## Teile

| Teil | Pfad | Technik |
|---|---|---|
| App (Web, Android, Linux; iOS vorbereitet) | `apps/flutter` | Flutter 3.47, `isar_plus` offline |
| Fach-API und Redaktions-Backend | `services/platform` | Strapi 4.25, Node 20, PostgreSQL, Redis |
| Anmeldung | `services/identity` | Keycloak 24 (OIDC, PKCE) |
| Studio (Redaktion) | `apps/editor` | statische Web-App |
| Lehrendenportal | `apps/teacher` | statische Web-App |
| Homepage | `apps/homepage` | Vite, three.js |
| API-Vertrag | `contracts/api.yaml` | OpenAPI 3.1, generierter Dart-Client in `packages/api` |
| Betrieb | `infra` | Docker Compose, Caddy |
| Handbuch | `docs-site` | MkDocs |

Die App spricht nur mit der Fach-API und Keycloak. Pflanzenbestimmung über [Pl@ntNet](https://plantnet.org) läuft ausschließlich auf dem Server und ist lokal durch einen Mock ersetzt.

## Schnellstart

Voraussetzungen: Docker mit Compose v2, Flutter in der Version aus `.flutter-version`, Node 20.

```sh
git clone https://github.com/noahilli/plantini.git
cd plantini
tools/scripts/start-local-demo.sh
```

Das Skript baut die Web-App, startet einen frischen, isolierten Stack und gibt die Zugangsdaten eines Test-Lernkontos aus. Danach: App unter <http://127.0.0.1:3000>, API unter <http://127.0.0.1:1338/api/v1/health>.

Tests und Prüfungen: `tools/scripts/ci-check.sh`. Einzelheiten zu Setup, Ports und Stolperfallen: [`docs-site/docs/mitmachen/setup.md`](docs-site/docs/mitmachen/setup.md).

## Dokumentation

- **Handbuch:** [`docs-site/docs/`](docs-site/docs/index.md), lokal mit `cd docs-site && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt && .venv/bin/mkdocs serve`
- **Für KI-Agenten und schnellen Einstieg:** [`AGENT.md`](AGENT.md)
- **Änderungsprotokoll:** <https://plantini.eu/changelog/>

## Mitmachen

Beiträge zu Code, Inhalten, Übersetzungen und Tests sind willkommen. Bitte zuerst [`CONTRIBUTING.md`](CONTRIBUTING.md) lesen. Sicherheitslücken bitte vertraulich melden: [`SECURITY.md`](SECURITY.md). Es gilt der [Verhaltenskodex](CODE_OF_CONDUCT.md).

## Lizenz

- Code: **GNU Affero General Public License v3.0 oder später** ([`LICENSE`](LICENSE)). Wer Plantini verändert und weitergibt oder als Dienst betreibt, muss den Quelltext seiner Fassung ebenfalls offenlegen.
- Lerninhalte (Texte, Quizfragen, 3D-Modelle, Handbuch): **CC BY-SA 4.0** ([`LICENSES/CC-BY-SA-4.0.txt`](LICENSES/CC-BY-SA-4.0.txt)).
- Ausnahmen (Fotos Dritter, Schriften, Unterlagen unter `knowledge/references/`) und Fremdkomponenten: [`NOTICE`](NOTICE).

© 2026 Noah Illmann. Die Idee zu Plantini stammt von einer dritten Person, die der Veröffentlichung zugestimmt hat.
