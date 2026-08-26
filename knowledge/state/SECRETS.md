# Secret Management

Die Applikation und das Backend verwalten Secrets lokal und in Produktion strikt getrennt vom Repository.

## PlantNet Credentials

Die lokale Datei `docs/plantnet-credentials` ist ein ignoriertes Entwickler-Secret. Sie darf weder eingecheckt, in ein Image kopiert, noch in App-Code, Screenshots, Testartefakte oder Logs übernommen werden. Lokale Nutzer:innen sollten ihre Dateirechte auf den eigenen Account beschränken (z. B. `chmod 600 docs/plantnet-credentials`).

Für einen expliziten lokalen Lauf gegen PlantNet wird ausschließlich das Overlay verwendet:

```bash
docker compose -f infra/compose.yaml -f infra/compose.plantnet.local.yaml up platform
```

Das Overlay liest die ignorierte Datei nur als `env_file`, setzt den Provider auf `real` und überführt ihren lokalen `API_KEY` beim Containerstart in `PLANTNET_API_KEY`. Danach entfernt es `API_KEY` und `SUBSCRIPTION` aus der Prozessumgebung des Backends. Es veröffentlicht keine zusätzlichen lokalen Ports; lokale Aufrufe bleiben bei `127.0.0.1`, nicht `localhost`. Für den externen PlantNet-Host bleibt HTTPS verpflichtend; die lokale Node-Laufzeit bevorzugt IPv4.

Die Schlüsselprüfung ist bewusst getrennt vom App- und E2E-Ablauf:

```bash
node tools/scripts/verify-plantnet-credentials.mjs
```

Der Verifizierer ruft ausschließlich den PlantNet-HTTPS-Quota-Endpunkt mit Timeout auf. Er gibt weder Schlüssel, vollständige Request-URLs, Response-Bodies noch die Umgebung aus. CI und `infra/compose.e2e.yaml` verwenden weiterhin ausschließlich den PlantNet-Mock und dürfen dieses Overlay nicht einbinden.

In Staging und Produktion wird ausschließlich `PLANTNET_API_KEY` aus dem zugelassenen Secret Management zur Laufzeit injiziert. Das lokale Overlay ist kein Produktionsmechanismus und ersetzt weder Rotation noch Secret-Scanning.
