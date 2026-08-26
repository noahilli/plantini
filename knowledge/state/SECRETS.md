# Secret Management

Die Applikation und das Backend verwalten Secrets lokal und in Produktion strikt getrennt vom Repository.

## PlantNet Credentials
Die echten PlantNet API-Zugangsdaten (Subscription und API_KEY) wurden bereitgestellt und lokal unter `docs/plantnet-credentials` abgelegt.

**WICHTIG:**
- Die Datei `docs/plantnet-credentials` ist in der `.gitignore` registriert und darf **niemals** in das Git-Repository eingecheckt werden (siehe Risk 05 in `RISKS.md`).
- Das Backend (Services) liest die Credentials bei Bedarf zur Laufzeit als Umgebungsvariablen (z.B. über `.env`-Dateien, die diese Werte injizieren).
- In Produktion müssen diese Keys über einen Secure Vault oder die CI/CD-Umgebungsvariablen an den Docker-Container übergeben werden.
