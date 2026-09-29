# Plantini Homepage

Statische Projektseite (Vite + three.js), ausgeliefert von nginx in einem Container. Keine Drittanbieter-Anfragen: Schriften, three.js, Bilder und 3D-Modelle kommen vom eigenen Server.

```sh
npm ci && npm run dev            # lokale Entwicklung
npm run build                    # nach dist/
node scripts/snapshot-content.mjs [api-origin]   # Steckbriefe und lizenzfreie Fotos neu ziehen
docker build -t plantini/homepage:dev .
```

- **Inhalte:** `src/content.json` und `public/photos/` sind ein Snapshot der veröffentlichten Inhalte. Nur CC0, gemeinfrei, CC BY und CC BY-SA werden übernommen; Urheber, Lizenz und Quelle stehen an jedem Foto (`/bildnachweise/`).
- **3D:** `public/worlds/*.json` sind die Blender-Module der App (`apps/flutter/assets/worlds`), gerundet; `src/world.js` baut daraus three.js-Geometrie.
- **Store-Links:** `src/config.js` (`STORE_URLS`). Solange `null`, zeigt die Seite „Bald verfügbar“.
- **Rechtstexte:** `impressum/`, `datenschutz/` enthalten markierte Platzhalter (`.todo`), die der Betreiber ausfüllen muss.
