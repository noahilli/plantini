# ADR 002: Fach-API v1 als stabiler App-Vertrag

## Status

Akzeptiert für Slice A bis C am 2026-08-25.

## Kontext

Die vorhandenen Strapi-Custom-Routen, der generierte Dart-Client und die
Architekturdokumentation verwendeten widersprüchliche Pfade und Datenmodelle.
Mock-Identitäten und lokal simulierte Synchronisation können keinen sicheren
oder wiederholbaren Kernpfad nachweisen.

## Entscheidung

- Die öffentliche Fach-API beginnt hinter dem Proxy mit `/api/v1`.
- `contracts/api.yaml` ist der kanonische Vertrag. Strapi bleibt zunächst die
  Host-Anwendung für Custom-Routes; Controller delegieren in testbare Dienste.
- Tokens werden vor jeder privaten Route validiert. Der `sub`-Claim wird auf
  eine stabile interne Nutzer-ID abgebildet; fremde Ressourcen antworten wie
  nicht vorhanden.
- Alle Offline-Schreibvorgänge tragen `Idempotency-Key` und eine stabile
  Client-ID. Fortschritt und Levelabschluss sind serverautoritativ.
- Identifikation ist ein persistenter asynchroner Job. Der PlantNet-Mock ist
  ausschließlich ein Adapter hinter diesem Jobvertrag.
- Alte `/api/*`-Mock-Routen sind keine Produktionsschnittstelle. Ein
  zeitlich begrenzter Kompatibilitätsadapter darf nur in Dev existieren.

## Konsequenzen

Backend, Flutter und E2E migrieren gemeinsam auf die v1-Operationen. Die
generierte Dart-Bibliothek wird erst nach einem reproduzierbaren Codegen-Gate
aktualisiert; bis dahin kapselt die App HTTP-DTOs hinter Repository-Ports.

## Betroffene Anforderungen

AUTH-01–03, CONTENT-01–06, LEARN-04–06, FIELD-03–07, OFFLINE-03–08,
API-02–07, QA-05–07 und NFA002/NFA020/NFA021/NFA022.
