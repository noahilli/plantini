# Operations Runbook: Production Deployment & Health Monitoring

## 1. Voraussetzungen & Checkliste vor dem Deployment

1. Alle CI-Pipelines sind grün (`.github/workflows/ci.yml` oder `.gitlab-ci.yml`).
2. Release-Tag auf `main` gesetzt (z. B. `git tag -a v1.0.0-rc1 -m "Release Candidate 1"`).
3. Echte Produktiv-Secrets via Environment-Variablen / Secret-Store bereitgestellt (keine Defaults aus `compose.yaml`).

---

## 2. Produktiv-Umgebungsvariablen Checkliste

| Variable | Beschreibung | Erforderlich |
|---|---|---|
| `PLATFORM_DB_PASSWORD` | Sicheres Passwort für PostgreSQL Platform | Ja |
| `KEYCLOAK_DB_PASSWORD` | Sicheres Passwort für PostgreSQL Keycloak | Ja |
| `MINIO_ROOT_USER` & `PASSWORD` | S3 Root Credentials | Ja |
| `STRAPI_APP_KEYS` | Kommagetrennte kryptographische App-Schlüssel | Ja |
| `STRAPI_API_TOKEN_SALT` | Salt für interne API Tokens | Ja |
| `STRAPI_ADMIN_JWT_SECRET` | Secret für Admin-Panel JWTs | Ja |
| `STRAPI_JWT_SECRET` | Secret für User Session JWTs | Ja |
| `PLANTNET_API_KEY` | Echter Produktions-API-Key für Pl@ntNet | Ja |

---

## 3. Deployment-Schritte

```bash
# 1. Neueste Version beziehen
git checkout tags/v1.0.0-rc1

# 2. Container mit Produktionsvariablen starten
docker compose -f infra/compose.yaml up -d --remove-orphans

# 3. Healthcheck verifizieren
curl -f http://localhost:1338/_health || exit 1
curl -f http://localhost:8082/realms/plantini || exit 1
```

---

## 4. Rollback-Strategie

Sollte nach einem Deployment ein Fehler auftreten:
```bash
# 1. Auf vorherigen stabilen Tag zurückwechseln
git checkout tags/v1.0.0-prev

# 2. Container neu ausrollen
docker compose -f infra/compose.yaml up -d

# 3. Falls Schema-Migrationen inkompatibel waren: DB-Restore gem. backup-restore.md durchführen
```
