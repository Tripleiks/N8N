#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <postgres_dump_file> <n8n_data_archive>" >&2
  echo "Example: $0 ./backups/postgres_20260213_020000.dump ./backups/n8n_data_20260213_020000.tar.gz" >&2
  exit 1
fi

POSTGRES_DUMP="$1"
N8N_ARCHIVE="$2"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "[ERR] .env fehlt. Bitte .env.example kopieren und anpassen." >&2
  exit 1
fi

if [[ ! -f "$POSTGRES_DUMP" || ! -f "$N8N_ARCHIVE" ]]; then
  echo "[ERR] Backup-Datei(en) nicht gefunden." >&2
  exit 1
fi

set -a
source ./.env
set +a

echo "[WARN] Restore überschreibt bestehende n8n- und DB-Daten."
read -r -p "Fortfahren? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
  echo "[INFO] Abgebrochen."
  exit 0
fi

docker compose up -d postgres

# Warten bis Postgres bereit ist
until docker compose exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
  sleep 2
done

echo "[INFO] Datenbank zurücksetzen ..."
docker compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${POSTGRES_DB}' AND pid <> pg_backend_pid();" >/dev/null
docker compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres -c "DROP DATABASE IF EXISTS \"${POSTGRES_DB}\";" >/dev/null
docker compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE \"${POSTGRES_DB}\";" >/dev/null

echo "[INFO] PostgreSQL Restore ..."
docker compose exec -T postgres pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$POSTGRES_DUMP"

echo "[INFO] n8n Daten-Volume Restore ..."
docker run --rm \
  -v n8n_app_data:/data \
  -v "$(cd "$(dirname "$N8N_ARCHIVE")" && pwd)":/backup:ro \
  alpine:3.20 \
  sh -c "rm -rf /data/* && tar -xzf /backup/$(basename "$N8N_ARCHIVE") -C /"

docker compose up -d

echo "[OK] Restore abgeschlossen"
