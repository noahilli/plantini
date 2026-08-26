# API-Vertrag v1 und Migrationsregel

`contracts/api.yaml` ist ab Slice A die einzige normative Beschreibung der
öffentlichen Fach-API. Die fachliche Basisadresse lautet `/api/v1`.

## Nicht verhandelbare Invarianten

- Keine private Route akzeptiert einen nicht validierten Keycloak-Token.
- Eine Ressource wird immer gegen den authentifizierten internen Nutzer und
  gegebenenfalls dessen Organisationsscope geprüft.
- Schreibvorgänge sind anhand von `Idempotency-Key` und Client-ID sicher
  wiederholbar.
- Fortschritt, Abschluss und Identifikationsstatus werden vom Server
  bestimmt. Lokale Werte sind nur vorläufige Offline-Darstellung.
- Fehler sind `application/problem+json` mit stabilem `code` und `traceId`.
- Content- und Medienreleases werden erst nach kompletter Integritätsprüfung
  aktiviert.

## Migrationsreihenfolge

1. Backend implementiert Route, Validierung, Service und Contract-Test.
2. Flutter ergänzt DTO-Mapper/Repository-Port und entfernt einen Mockpfad.
3. QA ergänzt eine positive und eine negative E2E-/Integrationserwartung.
4. Erst bei grünem Codegen-/Contract-Gate wird der API-Client erneuert.

Ein nicht im Vertrag beschriebenes Feld oder Verhalten ist kein erlaubter
Fallback. Es wird als Änderungsantrag mit Requirement-ID dokumentiert.
