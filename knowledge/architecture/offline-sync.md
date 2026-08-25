# Offline- und Synchronisationskonzept

## Content-Sync

1. Manifest mit ETag abrufen und Version/Hashes vergleichen.
2. Fehlende Daten/Medien als Delta in eine lokale Staging-Version laden.
3. Schema, Abhängigkeiten und Prüfsummen validieren.
4. Content-Version atomar aktivieren; alte funktionierende Version bis dahin behalten.
5. Rückgezogene Pflichtwarnungen oder Releases priorisiert behandeln.

## Persönliche Daten und Fortschritt

- Lern-/Quizereignisse sind append-only, haben Client-ID, Payload-Version und UTC-Zeit.
- Server quittiert bekannte Client-IDs ohne doppelte Wirkung.
- Fortschritt wird serverseitig autoritativ materialisiert; offline zeigt die App einen vorläufigen Stand.
- Notizen/Observation-Metadaten tragen `baseVersion`. Konkurrenz erzeugt sichtbaren Konflikt, nicht stille Überschreibung.
- Löschung erzeugt Tombstone und asynchrone Medienlöschung; lokale Clients erhalten den Tombstone über Cursor.
- Foto-/Identifikationsaufträge besitzen eine persistente Queue, Netzwerkpräferenz, Retrybudget und Abbruchstatus.

## Konfliktmatrix

| Datentyp | Autorität | Strategie |
|---|---|---|
| veröffentlichter Content | Server/Content Release | Server ersetzt lokale Version atomar |
| Learning Event | append-only beidseitig | Set-Union nach Client-ID |
| Progress | Server | neu berechnen/abgleichen |
| persönliche Notiz | Nutzer + Basisversion | Konflikt anzeigen, beide Versionen erhalten |
| Observation-Löschung | Nutzerwunsch/Server-Tombstone | Löschung gewinnt nach Bestätigung |
| Identifikationsjob | Serverworker | Client pollt/statusiert, kein Doppeljob |

## Pflichttests

Zwei Geräte, doppelte Zustellung, Reihenfolgewechsel, Prozessabbruch an jeder Sync-Grenze, Speicherknappheit, Datenbankmigration über zwei Vorversionen, Offline-Foto mit späterem Upload und Provider-429.
