# Flutter-Architektur

## Schichten

| Schicht | Verantwortung | Kennt |
|---|---|---|
| Presentation | Widgets, Navigation, Semantik, Zustandsdarstellung | Application, Designsystem |
| Application | Use Cases, Orchestrierung, atomare Abläufe | Domain-Ports |
| Domain | Entitäten, Value Objects, Regeln und Ports | keine Frameworks/Adapter |
| Infrastructure | REST, OIDC, Isar/Web-Store, Kamera, GPS, Datei, Telemetrie | implementiert Ports |

## Vertikale Module

```text
lib/
  app/                 shell, router, bootstrap, localization
  design_system/       tokens, components, semantics, states
  core/                errors, result, IDs, clock, small shared primitives
  features/
    auth/
    catalog/
    learning/
    quiz/
    field/
    herbarium/
    sync/
    profile/
  adapters/            platform-wide HTTP/OIDC/storage/device implementations
```

Jedes Feature enthält nach Bedarf `presentation`, `application`, `domain` und `infrastructure`. Kleine Features dürfen Ordner zusammenfassen; die Abhängigkeitsrichtung bleibt unverändert.

## Verbindliche Regeln

- Features sprechen über Use Cases, Domain Events und schmale Verträge, nicht über fremde Widgets oder Datenbanktabellen.
- Domainobjekte importieren kein Flutter, Isar, HTTP, Kamera-, GPS- oder PlantNet-Paket.
- Isar-Typen bleiben in Mobile-Adaptern. Web implementiert denselben Repository-Port.
- Sync entscheidet Transport/Konflikt, nicht Levelregeln.
- `field` erzeugt Beobachtung und Job; ein Domain-Use-Case bewertet das normalisierte TaxonMatch.
- UI zeigt Online, Offline, Pending, Konflikt und Fehler explizit; optimistischer Abschluss ist als vorläufig markiert.
- Text, Farbe und Animation folgen dem Plantini-Designsystem und WCAG 2.2 AA.

## Tests

- Domain: reine Unit-Tests, kritische Regeln ≥90 % Branch Coverage
- Application: Use-Case-Tests mit Fake Ports/Clock/IDs
- Presentation: Widget-, Semantik- und Zustandsprüfungen
- Infrastructure: Repository-Migration, HTTP-Contract, Plattformadapter
- E2E: Flutter Web plus Playwright; native Kamera/GPS zusätzlich auf Gerät/Simulator
