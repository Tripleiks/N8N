#!/bin/bash
# ============================================================================
# N8N Backup Script
# ============================================================================
# Erstellt Backups von N8N Workflows und PostgreSQL Datenbank
# Verwendung: ./backup.sh
# ============================================================================

set -e  # Bei Fehler abbrechen

# Konfiguration
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}N8N Backup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Prüfen ob Docker läuft
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker läuft nicht! Bitte Docker starten.${NC}"
    exit 1
fi

# Prüfen ob Container laufen
if ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Container laufen nicht. Starte Container...${NC}"
    docker-compose up -d
    sleep 10
fi

# Backup-Verzeichnis erstellen
mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}📦 Erstelle PostgreSQL Backup...${NC}"
if docker-compose exec -T postgres pg_dump -U n8n_user -Fc -d n8n > "$BACKUP_DIR/postgres_$DATE.dump"; then
    echo -e "${GREEN}✅ PostgreSQL Backup erfolgreich: postgres_$DATE.dump${NC}"
    POSTGRES_SIZE=$(du -h "$BACKUP_DIR/postgres_$DATE.dump" | cut -f1)
    echo -e "   Größe: $POSTGRES_SIZE"
else
    echo -e "${RED}❌ PostgreSQL Backup fehlgeschlagen!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}📦 Erstelle N8N Daten Backup...${NC}"
if tar -czf "$BACKUP_DIR/n8n_backup_$DATE.tar.gz" data/ 2>/dev/null; then
    echo -e "${GREEN}✅ N8N Backup erfolgreich: n8n_backup_$DATE.tar.gz${NC}"
    N8N_SIZE=$(du -h "$BACKUP_DIR/n8n_backup_$DATE.tar.gz" | cut -f1)
    echo -e "   Größe: $N8N_SIZE"
else
    echo -e "${RED}❌ N8N Backup fehlgeschlagen!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🗑️  Lösche alte Backups (älter als $RETENTION_DAYS Tage)...${NC}"
DELETED_COUNT=$(find "$BACKUP_DIR" \( -name "*.dump" -o -name "*.tar.gz" \) -mtime +$RETENTION_DAYS -delete -print | wc -l)
if [ "$DELETED_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ $DELETED_COUNT alte Backup(s) gelöscht${NC}"
else
    echo -e "   Keine alten Backups gefunden"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Backup erfolgreich abgeschlossen!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Backup-Location: $BACKUP_DIR"
echo "Timestamp: $DATE"
echo ""
echo "Backups:"
ls -lh "$BACKUP_DIR" | grep "$DATE"
