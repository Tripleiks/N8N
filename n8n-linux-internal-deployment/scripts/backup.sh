#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "[ERR] .env fehlt. Bitte .env.example kopieren und anpassen." >&2
  exit 1
fi

set -a
source ./.env
set +a

BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
STAMP="$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

echo "[INFO] PostgreSQL Backup ..."
docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc > "$BACKUP_DIR/postgres_${STAMP}.dump"

echo "[INFO] n8n Datenverzeichnis Backup ..."
docker run --rm \
  -v n8n_app_data:/data:ro \
  -v "$ROOT_DIR/$BACKUP_DIR":/backup \
  alpine:3.20 \
  sh -c "tar -czf /backup/n8n_data_${STAMP}.tar.gz -C / data"

echo "[INFO] Alte Backups entfernen (>${RETENTION_DAYS} Tage) ..."
find "$BACKUP_DIR" -type f \( -name "postgres_*.dump" -o -name "n8n_data_*.tar.gz" \) -mtime +"$RETENTION_DAYS" -delete

echo "[OK] Backup fertig: $BACKUP_DIR"
