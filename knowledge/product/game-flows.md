# Spiel- und Nutzungsabläufe

## Kernschleife

```mermaid
flowchart TD
  A[Ökosystem entdecken] --> B[Arten lernen]
  B --> C[Quiz üben]
  C --> D{Lernschwelle erreicht?}
  D -- Nein --> B
  D -- Ja --> E[Feldaufgabe]
  E --> F[Foto und PlantNet-Abgleich]
  F --> G{Zielart hinreichend bestätigt?}
  G -- Nein oder unsicher --> E
  G -- Ja --> H[Herbarium und Levelabschluss]
  H --> I[Nächstes Level oder Wiederholung]
```

## Levelzustände

| Zustand | Eintritt | Übergang |
|---|---|---|
| gesperrt | Voraussetzungen fehlen | Freigabe nach konfigurierbarer Regel |
| aktiv | erste Einheit gestartet | Lernen, Quiz, Pause, Sync |
| feldbereit | Lern-/Quizschwelle erfüllt | Feldaufgabe oder weiteres Üben |
| Nachweis ausstehend | Foto lokal oder Job läuft | Ergebnis, Retry, Offline-Queue |
| abgeschlossen | Server bestätigt Abschluss | Erfolg, Herbarium, nächstes Level |
| Wiederholung fällig | Regel/Unsicherheitsprofil greift | fokussiertes Quiz ohne Abschlussverlust |

## Redaktion

```mermaid
stateDiagram-v2
  [*] --> Entwurf
  Entwurf --> Review: einreichen
  Review --> Entwurf: Korrektur
  Review --> Freigegeben: botanisch und didaktisch geprüft
  Freigegeben --> Veröffentlicht: Content Release
  Veröffentlicht --> Archiviert: ersetzen oder zurückziehen
```

Ein App-Client sieht ausschließlich Inhalte eines atomaren veröffentlichten Content-Releases. Drafts oder teilweise freigegebene Beziehungen dürfen nie im Manifest erscheinen.
