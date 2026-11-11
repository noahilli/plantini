---
title: Plantini Handbuch
hide:
  - navigation
  - toc
---

<div class="pl-hero" markdown>
<span class="pl-eyebrow">Handbuch für Mitwirkende</span>

# Plantini verstehen, betreiben, erweitern.

Plantini macht Pflanzenkunde zugänglich: in Ökosystemen lernen, draußen entdecken, Pflanzen per Foto bestimmen
und im privaten Herbarium sammeln. Dieses Handbuch erklärt **wie Plantini gebaut ist**, wie du **mitentwickelst**,
wie Redaktion und Review **Inhalte pflegen** und wie das System **benutzt** wird.
</div>

<div class="pl-status" markdown>
**Projektstatus.** Plantini ist ein früher, unvollständiger Stand und **Open Source** (Code: AGPL-3.0-or-later,
Inhalte: CC BY-SA 4.0). Die Idee stammt von einer dritten Person, die der Veröffentlichung zugestimmt hat; Urheber
des Codes ist Noah Illmann. Es gibt keinen kommerziellen Hintergrund; es wurden und werden weder Spenden noch Zahlungen angenommen.
Details: [Projektstatus und Rechte](start/status.md).
</div>

## Wo möchtest du anfangen?

<div class="pl-cards">
  <a class="pl-card" href="mitmachen/"><strong>Mitmachen</strong><span>Umgebung aufsetzen, Repository verstehen, Konventionen, Tests.</span></a>
  <a class="pl-card" href="architektur/"><strong>Architektur</strong><span>Komponenten, Datenflüsse, Datenmodell, Sicherheit, Entscheidungen.</span></a>
  <a class="pl-card" href="backend/"><strong>Backend &amp; API</strong><span>Strapi-Plattform, Fach-API, Vertrag, neue Endpunkte, Releases.</span></a>
  <a class="pl-card" href="app/"><strong>App</strong><span>Flutter: Struktur, Anmeldung, Offline, Bilder und Karte, Release.</span></a>
  <a class="pl-card" href="3d/"><strong>3D &amp; Blender</strong><span>Welt-Module, Tageszeit und Licht, Charaktere, Performance.</span></a>
  <a class="pl-card" href="studio/"><strong>Studio &amp; Portal</strong><span>Redaktions-Studio und Lehrendenportal technisch erklärt.</span></a>
  <a class="pl-card" href="betrieb/"><strong>Betrieb</strong><span>Compose, Deployment, Keycloak, Backups, Android-Release.</span></a>
  <a class="pl-card" href="moderation/"><strong>Moderation</strong><span>Inhalte pflegen, Review, Qualität und Bildlizenzen.</span></a>
  <a class="pl-card" href="nutzung/"><strong>Nutzung</strong><span>Die App und das Portal mit Screenshots und kurzen Animationen.</span></a>
  <a class="pl-card" href="referenz/stolperfallen/"><strong>Stolperfallen</strong><span>Fehler, die schon Zeit gekostet haben – und ihre Lösung.</span></a>
</div>

## Auf einen Blick

```mermaid
flowchart LR
  subgraph Clients
    APP["App<br/>Flutter · Web, Android, Linux"]
    STUDIO["Studio<br/>Redaktion"]
    PORTAL["Portal<br/>Lehrende"]
  end
  CADDY["Caddy<br/>HTTPS"]
  API["Fach-API<br/>Strapi 4 · Node 20"]
  KC["Keycloak<br/>OIDC"]
  PG[("PostgreSQL")]
  RD[("Redis")]
  PN["Pl@ntNet<br/>(extern)"]
  APP --> CADDY
  STUDIO --> CADDY
  PORTAL --> CADDY
  CADDY --> API
  CADDY --> KC
  API --> PG
  API --> RD
  API --> PN
  API -. JWKS .-> KC
```

Die App spricht ausschließlich mit der Fach-API und mit Keycloak – nie mit Strapi-Admin, Datenbank oder Pl@ntNet.
Mehr dazu auf der Seite [Architektur](architektur/index.md).
