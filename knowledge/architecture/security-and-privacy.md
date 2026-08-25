# Security und Privacy Baseline

## Schutzbedarf

Besonders schützenswert sind Minderjährigenbezug, Identität, private Fotos, genaue GPS-Daten, Einwilligungen, Forschungszuordnung, Tokens und Provider-/Signierschlüssel.

## Mindestkontrollen

- TLS überall außerhalb isolierter Containerkommunikation; HSTS im produktiven Gateway
- OIDC PKCE, kurze Access Tokens, sichere Rotation/Revocation, MFA für Admins
- Secrets ausschließlich im Secret Management; keine Secrets in Git, Image, App, Screenshot oder Playwright-Trace
- objekt- und organisationsbezogene Autorisierung in jedem API-Aufruf
- getrennte private/public Buckets und kurzlebige signierte URLs
- Uploadtyp, Größe, Magic Bytes, Hash und Bildverarbeitung validieren
- keine Freitexte, Fotos, exakten Orte oder Tokens in Analytik/Logs
- getrennte, versionierte Einwilligungszwecke und Löschregeln
- Admin-/Publish-/Rollenänderungen manipulationsgeschützt auditieren
- SAST, Dependency-/Container-/Secret-Scan, SBOM, DAST und Pen-Test vor Go-live

## Datenschutz-Defaults

Standort ist optional; Ablehnung blockiert Herbarium/Fotografie nicht. Genauigkeit kann reduziert werden. Exporte und geteilte Dateien entfernen/vergröbern GPS standardmäßig. Forschung ist von App-Nutzung getrennt und beginnt erst nach passender Rechtsgrundlage/Einwilligung.

## Entwicklungsdaten

Ausschließlich synthetische Konten, Bilder und Orte. Keine Produktionskopien in Dev/Staging. Screenshots und Traces werden vor Commit auf Namen, E-Mails, Tokens, GPS und Cookies geprüft.

## Stop-Bedingungen

Änderungen an Alterslogik, Einwilligung, Datenübermittlung, Aufbewahrung, Rollenmatrix, Verschlüsselung oder Account-Linking benötigen Security/Privacy-Review und ggf. rechtliche Freigabe.
