# Operations Runbook: Backup & Disaster Recovery

## 1. Übersicht RPO & RTO

- **RPO (Recovery Point Objective):** < 4 Stunden (Datenverlust maximal 4 Stunden)
- **RTO (Recovery Time Objective):** < 30 Minuten (Systemwiederherstellung)

---

## 2. Manuelles Backup erstellen

### 2.1 Platform / Strapi PostgreSQL Backup
```bash
# Dump der Plattform-Datenbank (Ökosysteme, Pflanzen, Quizzes, Beobachtungen)
docker exec -t plantini-postgres-platform-1 pg_dump -U plantini -d plantini -F c -b -v -f /tmp/platform_backup.dump
docker cp plantini-postgres-platform-1:/tmp/platform_backup.dump ./backups/platform_$(date +%Y%m%d_%H%M%S).dump
```

### 2.2 Keycloak PostgreSQL Backup
```bash
# Dump der Keycloak-Datenbank (Realms, Clients, Benutzer & Rollen)
docker exec -t plantini-postgres-keycloak-1 pg_dump -U keycloak -d keycloak -F c -b -v -f /tmp/keycloak_backup.dump
docker cp plantini-postgres-keycloak-1:/tmp/keycloak_backup.dump ./backups/keycloak_$(date +%Y%m%d_%H%M%S).dump
```

### 2.3 Medien-Uploads (MinIO / S3)
```bash
# S3 / MinIO Objektdaten sichern
tar -czvf ./backups/minio_data_$(date +%Y%m%d_%H%M%S).tar.gz -C ./services/platform/public/uploads .
```

---

## 3. Disaster Recovery / Restore-Prozedur

### 3.1 Platform-Datenbank wiederherstellen
```bash
# 1. Ziel-Container bereinigen
docker exec -i plantini-postgres-platform-1 psql -U plantini -d postgres -c "DROP DATABASE IF EXISTS plantini WITH (FORCE);"
docker exec -i plantini-postgres-platform-1 psql -U plantini -d postgres -c "CREATE DATABASE plantini;"

# 2. Dump einspielen
docker cp ./backups/<BACKUP_FILE>.dump plantini-postgres-platform-1:/tmp/restore.dump
docker exec -t plantini-postgres-platform-1 pg_restore -U plantini -d plantini -v /tmp/restore.dump

# 3. Strapi neu starten
docker compose -f infra/compose.yaml restart platform
```

### 3.2 Keycloak-Datenbank wiederherstellen
```bash
# 1. Datenbank zurücksetzen
docker exec -i plantini-postgres-keycloak-1 psql -U keycloak -d postgres -c "DROP DATABASE IF EXISTS keycloak WITH (FORCE);"
docker exec -i plantini-postgres-keycloak-1 psql -U keycloak -d postgres -c "CREATE DATABASE keycloak;"

# 2. Dump einspielen
docker cp ./backups/<KEYCLOAK_BACKUP>.dump plantini-postgres-keycloak-1:/tmp/restore.dump
docker exec -t plantini-postgres-keycloak-1 pg_restore -U keycloak -d keycloak -v /tmp/restore.dump

# 3. Keycloak neu starten
docker compose -f infra/compose.yaml restart keycloak
```
