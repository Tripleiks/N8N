.PHONY: help init certs up down restart logs status backup restore validate harden-env init-v2 validate-v2 up-v2 down-v2 logs-v2 status-v2

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
	@echo ""
	@echo "Variante 2 (OIDC/Entra via oauth2-proxy):"
	@echo "make init-v2   - .env.v2-oidc aus Vorlage erzeugen"
	@echo "make validate-v2 - OIDC Compose validieren"
	@echo "make up-v2     - OIDC Stack starten"
	@echo "make down-v2   - OIDC Stack stoppen"
	@echo "make logs-v2   - OIDC Stack Logs"
	@echo "make status-v2 - OIDC Stack Status"

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

init-v2:
	@if [ ! -f .env.v2-oidc ]; then cp .env.v2-oidc.example .env.v2-oidc; echo "[OK] .env.v2-oidc aus Vorlage erstellt"; else echo "[INFO] .env.v2-oidc existiert bereits"; fi

validate-v2:
	docker compose --env-file .env.v2-oidc -f docker-compose.v2-oidc.yml config >/dev/null && echo "[OK] docker-compose.v2-oidc.yml ist valide"

up-v2:
	docker compose --env-file .env.v2-oidc -f docker-compose.v2-oidc.yml up -d

down-v2:
	docker compose --env-file .env.v2-oidc -f docker-compose.v2-oidc.yml down

logs-v2:
	docker compose --env-file .env.v2-oidc -f docker-compose.v2-oidc.yml logs -f --tail=200

status-v2:
	docker compose --env-file .env.v2-oidc -f docker-compose.v2-oidc.yml ps
