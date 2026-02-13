.PHONY: help init certs up down restart logs status backup restore validate harden-env

help:
	@echo "N8N Internal Linux Deployment"
	@echo ""
	@echo "make init      - Verzeichnisse anlegen, .env aus Vorlage kopieren"
	@echo "make certs     - Self-signed Zertifikate erzeugen"
	@echo "make up        - Stack starten"
	@echo "make down      - Stack stoppen"
	@echo "make restart   - Stack neu starten"
	@echo "make logs      - Logs anzeigen"
	@echo "make status    - Containerstatus"
	@echo "make backup    - Backup erstellen"
	@echo "make restore   - Restore (POSTGRES_DUMP=... N8N_ARCHIVE=...)"
	@echo "make validate  - Compose-Datei validieren"
	@echo "make harden-env - .env Dateirechte auf 600 setzen"

init:
	@mkdir -p certs backups scripts
	@if [ ! -f .env ]; then cp .env.example .env; echo "[OK] .env aus Vorlage erstellt"; else echo "[INFO] .env existiert bereits"; fi

certs:
	@bash ./scripts/generate-self-signed-certs.sh ./certs

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose down && docker compose up -d

logs:
	docker compose logs -f --tail=200

status:
	docker compose ps

backup:
	@bash ./scripts/backup.sh

restore:
	@test -n "$(POSTGRES_DUMP)" || (echo "POSTGRES_DUMP fehlt" && exit 1)
	@test -n "$(N8N_ARCHIVE)" || (echo "N8N_ARCHIVE fehlt" && exit 1)
	@bash ./scripts/restore.sh "$(POSTGRES_DUMP)" "$(N8N_ARCHIVE)"

validate:
	docker compose config >/dev/null && echo "[OK] docker-compose.yml ist valide"

harden-env:
	@chmod 600 .env && echo "[OK] .env Rechte auf 600 gesetzt"
