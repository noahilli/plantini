#!/usr/bin/env bash
# Nightly backup of everything that cannot be rebuilt from the repository:
# both PostgreSQL databases, the private photo volume, TLS state of Caddy and
# the configuration (production.env, realm file, compose/Caddy files).
# Run as root (systemd timer plantini-backup.timer). Keeps KEEP_DAYS days.
# Restore: see operations/runbooks/production-deploy.md ("Sicherung und Wiederherstellung").
set -euo pipefail

ROOT=${PLANTINI_ROOT:-/opt/plantini}
DEST=${BACKUP_DIR:-/var/backups/plantini}
KEEP_DAYS=${KEEP_DAYS:-14}
PROJECT=${COMPOSE_PROJECT:-plantini-production}
stamp=$(date -u +%Y%m%dT%H%M%SZ)
dir="$DEST/$stamp"

umask 077
mkdir -p "$dir"

# Databases: consistent logical dumps (custom format, restorable with pg_restore).
docker exec "${PROJECT}-postgres-platform-1" pg_dump -U plantini -d plantini -Fc > "$dir/platform.dump"
docker exec "${PROJECT}-postgres-keycloak-1" pg_dump -U keycloak -d keycloak -Fc > "$dir/keycloak.dump"

# Uploaded photos (private media) and Caddy's certificates/account.
for volume in "${PROJECT}_private-media:private-media" "plantini-proxy_caddy-data:caddy-data"; do
  name=${volume%%:*}; label=${volume##*:}
  docker run --rm -v "$name":/data:ro -v "$dir":/out alpine:3.20 tar -C /data -czf "/out/$label.tar.gz" .
done

# Configuration (contains secrets: the directory is 0700, root only).
tar -C "$ROOT" -czf "$dir/config.tar.gz" production.env realm-production.json infra downloads/plantini.json

# Verify the dumps can be read back before declaring success.
for f in platform keycloak; do
  docker run --rm -i postgres:16.4-alpine pg_restore --list < "$dir/$f.dump" > /dev/null
done
sha256sum "$dir"/* > "$dir/SHA256SUMS"
echo "$stamp ok" >> "$DEST/backup.log"

# Retention.
find "$DEST" -mindepth 1 -maxdepth 1 -type d -mtime +"$KEEP_DAYS" -exec rm -rf {} +
