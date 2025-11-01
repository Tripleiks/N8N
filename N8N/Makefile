# ============================================================================
# N8N Docker Makefile
# ============================================================================
# Vereinfacht häufige Docker-Operationen
# Verwendung: make [target]
# ============================================================================

.PHONY: help start stop restart logs status backup clean update test

# Standard-Ziel: Hilfe anzeigen
help:
	@echo "========================================="
	@echo "N8N Docker Management"
	@echo "========================================="
	@echo ""
	@echo "Verfügbare Befehle:"
	@echo ""
	@echo "  make start       - Container starten"
	@echo "  make stop        - Container stoppen"
	@echo "  make restart     - Container neu starten"
	@echo "  make logs        - Logs anzeigen (live)"
	@echo "  make logs-n8n    - Nur N8N Logs"
	@echo "  make logs-db     - Nur PostgreSQL Logs"
	@echo "  make status      - Container-Status anzeigen"
	@echo "  make backup      - Backup erstellen"
	@echo "  make clean       - Container stoppen & entfernen"
	@echo "  make clean-all   - Container + Volumes entfernen (ACHTUNG!)"
	@echo "  make update      - Images aktualisieren"
	@echo "  make test        - Verbindungstest durchführen"
	@echo "  make shell-n8n   - Shell in N8N Container"
	@echo "  make shell-db    - Shell in PostgreSQL Container"
	@echo ""

# Container starten
start:
	@echo "🚀 Starte N8N Container..."
	docker-compose up -d
	@echo "✅ Container gestartet!"
	@echo ""
	@echo "Zugriff:"
	@echo "  https://MAC-PRO-INTEL.local:5678"
	@echo "  https://10.0.0.171:5678"
	@echo ""

# Container stoppen
stop:
	@echo "⏸️  Stoppe Container..."
	docker-compose stop
	@echo "✅ Container gestoppt!"

# Container neu starten
restart:
	@echo "🔄 Starte Container neu..."
	docker-compose restart
	@echo "✅ Container neu gestartet!"

# Logs anzeigen
logs:
	docker-compose logs -f

# N8N Logs
logs-n8n:
	docker-compose logs -f n8n

# PostgreSQL Logs
logs-db:
	docker-compose logs -f postgres

# Status anzeigen
status:
	@echo "📊 Container Status:"
	@echo ""
	docker-compose ps
	@echo ""
	@echo "🏥 Health Status:"
	@docker inspect n8n-app --format='N8N: {{.State.Health.Status}}' 2>/dev/null || echo "N8N: Container nicht gefunden"
	@docker inspect n8n-postgres --format='PostgreSQL: {{.State.Health.Status}}' 2>/dev/null || echo "PostgreSQL: Container nicht gefunden"

# Backup erstellen
backup:
	@echo "💾 Erstelle Backup..."
	./backup.sh

# Container cleanup
clean:
	@echo "🧹 Entferne Container..."
	docker-compose down
	@echo "✅ Container entfernt (Daten bleiben erhalten)"

# Vollständiges Cleanup (inkl. Volumes)
clean-all:
	@echo "⚠️  WARNUNG: Dieser Befehl löscht ALLE Daten!"
	@echo "Abbruch mit Ctrl+C möglich..."
	@sleep 5
	docker-compose down -v
	@echo "✅ Container und Volumes entfernt"

# Images aktualisieren
update:
	@echo "📥 Lade neue Images..."
	docker-compose pull
	@echo "🔄 Starte Container mit neuen Images..."
	docker-compose up -d
	@echo "🗑️  Entferne alte Images..."
	docker image prune -f
	@echo "✅ Update abgeschlossen!"

# Verbindungstest
test:
	@echo "🧪 Teste Verbindungen..."
	@echo ""
	@echo "Testing localhost..."
	@curl -k -s -o /dev/null -w "  Status: %{http_code}\n" https://localhost:5678/healthz
	@echo ""
	@echo "Testing IP (10.0.0.171)..."
	@curl -k -s -o /dev/null -w "  Status: %{http_code}\n" https://10.0.0.171:5678/healthz
	@echo ""
	@echo "Testing Hostname..."
	@curl -k -s -o /dev/null -w "  Status: %{http_code}\n" https://MAC-PRO-INTEL.local:5678/healthz
	@echo ""
	@echo "✅ Tests abgeschlossen (200 = OK, 401 = Basic Auth aktiv)"

# Shell in N8N Container
shell-n8n:
	docker-compose exec n8n /bin/sh

# Shell in PostgreSQL Container
shell-db:
	docker-compose exec postgres /bin/bash

# PostgreSQL Kommandozeile
psql:
	docker-compose exec postgres psql -U n8n_user -d n8n
