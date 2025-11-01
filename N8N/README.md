# N8N Docker Setup mit SSL & PostgreSQL

## 📋 Übersicht

Professionelles N8N Setup für lokale Entwicklung mit:
- ✅ SSL/TLS Verschlüsselung (selbstsigniert via mkcert)
- ✅ PostgreSQL Datenbank (separater Container)
- ✅ Basic Authentication
- ✅ Persistente Datenspeicherung
- ✅ Health Checks & Auto-Restart
- ✅ Strukturierte Logs

## 🖥️ System-Anforderungen

- **OS**: macOS 15.7.1 (Intel)
- **Docker**: 28.5.1+
- **mkcert**: v1.4.4+
- **RAM**: Mindestens 4GB verfügbar
- **Disk**: ~2GB für Container & Daten

## 🏗️ Architektur

```
┌─────────────────────────────────────────────┐
│          Host: MAC-PRO-INTEL.local          │
│              IP: 10.0.0.171                 │
└─────────────────────────────────────────────┘
                    │
                    │ Port 5678 (HTTPS)
                    │
        ┌───────────▼──────────────┐
        │   Docker Network         │
        │   (n8n-network)          │
        │                          │
        │  ┌────────────────────┐  │
        │  │   N8N Container    │  │
        │  │   Port: 5678       │  │
        │  │   SSL: ✓           │  │
        │  └──────────┬─────────┘  │
        │             │             │
        │             │ PostgreSQL  │
        │             │ Protocol    │
        │  ┌──────────▼─────────┐  │
        │  │ PostgreSQL:16      │  │
        │  │ Port: 5432         │  │
        │  │ Internal only      │  │
        │  └────────────────────┘  │
        └──────────────────────────┘
```

## 📁 Verzeichnisstruktur

```
/Volumes/PROJECTS/N8N_Projects/
├── docker-compose.yml       # Docker Orchestrierung
├── .env                     # Umgebungsvariablen (NICHT in Git!)
├── .env.example            # Template für .env
├── .gitignore              # Git Ignore Rules
├── README.md               # Diese Datei
│
├── certs/                  # SSL-Zertifikate
│   ├── cert.pem           # Öffentliches Zertifikat
│   └── key.pem            # Privater Schlüssel
│
├── data/                   # N8N Workflows & Konfiguration
│   ├── database.sqlite    # Lokale N8N Metadaten
│   └── .n8n/              # Workflows, Credentials, etc.
│
├── postgres_data/          # PostgreSQL Daten (persistent)
│
├── logs/                   # Application Logs
│   ├── n8n.log            # N8N Logs
│   └── postgresql/        # PostgreSQL Logs
│
└── backups/               # Backup-Verzeichnis
    ├── n8n_backup_*.tar.gz
    └── postgres_*.dump
```

## 🚀 Installation & Start

### 1. Repository klonen / Verzeichnis wechseln

```bash
cd /Volumes/PROJECTS/N8N_Projects
```

### 2. SSL-Zertifikate überprüfen

Die Zertifikate wurden bereits erstellt und sind gültig bis **1. Februar 2028**.

Überprüfen:
```bash
ls -la certs/
# cert.pem und key.pem sollten vorhanden sein
```

### 3. Umgebungsvariablen konfigurieren

Die `.env` Datei wurde bereits mit sicheren Passwörtern erstellt.

**Wichtig**: Passwörter wurden automatisch generiert und sind in `.env` gespeichert.

### 4. Container starten

```bash
# Container im Hintergrund starten
docker-compose up -d

# Logs anzeigen
docker-compose logs -f

# Status prüfen
docker-compose ps
```

### 5. N8N aufrufen

Nach dem Start ist N8N erreichbar unter:

- **Via Hostname**: https://MAC-PRO-INTEL.local:5678
- **Via IP**: https://10.0.0.171:5678
- **Localhost**: https://localhost:5678

**Login-Daten** (aus `.env` Datei):
- Username: `admin`
- Passwort: In `.env` unter `N8N_BASIC_AUTH_PASSWORD`

## 🔐 Sicherheit

### SSL/TLS
- Selbstsignierte Zertifikate via mkcert
- Gültig für alle Zugriffswege (Hostname, IP, localhost)
- Browser zeigt Warnung → "Trotzdem fortfahren"
- Zertifikate als **read-only** im Container gemountet


### Passwörter
- **PostgreSQL**: In `.env` unter `POSTGRES_PASSWORD`
- **N8N Basic Auth**: In `.env` unter `N8N_BASIC_AUTH_PASSWORD`
- Alle Passwörter mit 32 Zeichen, kryptografisch sicher generiert

### Netzwerk-Isolation
- PostgreSQL ist **nur** über internes Docker-Netzwerk erreichbar
- Kein Port-Exposure für PostgreSQL nach außen
- N8N exponiert nur Port 5678 (HTTPS)

### Best Practices
- ✅ `.env` Datei NIEMALS in Git committen
- ✅ Zertifikate regelmäßig erneuern (alle 2-3 Jahre)
- ✅ Passwörter in Password Manager speichern
- ✅ Regelmäßige Backups erstellen
- ✅ Logs monitoren auf Anomalien

## 🔧 Betrieb & Verwaltung

### Container-Management

```bash
# Status anzeigen
docker-compose ps

# Logs anzeigen (alle Services)
docker-compose logs -f

# Logs nur N8N
docker-compose logs -f n8n

# Logs nur PostgreSQL
docker-compose logs -f postgres

# Container stoppen
docker-compose stop

# Container starten
docker-compose start

# Container neustarten
docker-compose restart

# Container stoppen & entfernen (Daten bleiben!)
docker-compose down

# Container inkl. Volumes entfernen (ACHTUNG: Datenverlust!)
docker-compose down -v
```

### Health Checks

Beide Container haben Health Checks integriert:

```bash
# Gesundheitsstatus prüfen
docker inspect n8n-app | grep -A 10 Health
docker inspect n8n-postgres | grep -A 10 Health
```

### Updates durchführen

```bash
# Neue Images pullen
docker-compose pull

# Container mit neuen Images neu starten
docker-compose up -d

# Alte Images entfernen
docker image prune -f
```

## 💾 Backup & Restore

### N8N Workflows sichern

```bash
# Manuelles Backup erstellen
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf backups/n8n_backup_$DATE.tar.gz data/

# Backup wiederherstellen
tar -xzf backups/n8n_backup_YYYYMMDD_HHMMSS.tar.gz
```

### PostgreSQL Datenbank sichern

```bash
# Datenbank-Dump erstellen
docker-compose exec postgres pg_dump -U n8n_user -d n8n > backups/postgres_$(date +%Y%m%d_%H%M%S).dump

# Komplettes Backup mit custom Format
docker-compose exec postgres pg_dump -U n8n_user -Fc -d n8n -f /tmp/backup.dump
docker cp n8n-postgres:/tmp/backup.dump backups/postgres_$(date +%Y%m%d_%H%M%S).dump

# Datenbank wiederherstellen
docker-compose exec -T postgres psql -U n8n_user -d n8n < backups/postgres_YYYYMMDD_HHMMSS.dump
```

### Automatisiertes Backup (Optional)

Erstelle ein Cronjob für automatische Backups:

```bash
# Backup-Script erstellen
cat > backup.sh << 'EOF'
#!/bin/bash
cd /Volumes/PROJECTS/N8N_Projects
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T postgres pg_dump -U n8n_user -d n8n > backups/postgres_$DATE.dump
tar -czf backups/n8n_backup_$DATE.tar.gz data/
# Alte Backups löschen (älter als 30 Tage)
find backups/ -name "*.dump" -mtime +30 -delete
find backups/ -name "*.tar.gz" -mtime +30 -delete
EOF

chmod +x backup.sh

# Cronjob hinzufügen (täglich um 2 Uhr nachts)
# crontab -e
# 0 2 * * * /Volumes/PROJECTS/N8N_Projects/backup.sh
```

## 🔍 Troubleshooting

### Container startet nicht

```bash
# Logs prüfen
docker-compose logs n8n
docker-compose logs postgres

# Health Status prüfen
docker-compose ps

# Container neu bauen
docker-compose down
docker-compose up -d --force-recreate
```

### SSL-Zertifikat wird nicht akzeptiert


1. **mkcert CA installieren** (falls noch nicht geschehen):
```bash
mkcert -install
```

2. **Browser-Cache leeren** und Seite neu laden

3. **Zertifikat manuell im Keychain hinzufügen** (macOS):
```bash
open certs/cert.pem
# Im Keychain: Zertifikat auf "Immer vertrauen" setzen
```

### PostgreSQL Verbindungsfehler

```bash
# Prüfen ob PostgreSQL läuft
docker-compose ps postgres

# PostgreSQL Logs prüfen
docker-compose logs postgres

# Manuell verbinden und testen
docker-compose exec postgres psql -U n8n_user -d n8n

# Verbindung von N8N aus testen
docker-compose exec n8n wget -O- http://postgres:5432 2>&1 | head
```

### Port 5678 bereits belegt

```bash
# Prozess identifizieren
lsof -i :5678

# Alternative: Port in docker-compose.yml ändern
# ports:
#   - "5679:5678"
```

### Daten gehen verloren nach Neustart

- Prüfe ob Volumes korrekt gemountet sind:
```bash
docker-compose exec n8n ls -la /home/node/.n8n
docker-compose exec postgres ls -la /var/lib/postgresql/data
```

- Prüfe Verzeichnis-Permissions:
```bash
ls -la data/
ls -la postgres_data/
```

### Performance-Probleme

```bash
# Container-Ressourcen prüfen
docker stats n8n-app n8n-postgres

# Docker Desktop Ressourcen erhöhen:
# Docker Desktop → Settings → Resources
# Empfohlen: CPU: 4+ Cores, RAM: 8GB+
```

## 📊 Monitoring & Logs

### Log-Locations

```bash
# N8N Application Logs
tail -f logs/n8n.log

# PostgreSQL Logs
docker-compose logs -f postgres

# Docker Container Logs
docker-compose logs -f
```

### Health-Endpoints

- **N8N Health**: https://MAC-PRO-INTEL.local:5678/healthz
- **PostgreSQL**: Via Health Check im Container

```bash
# Health Check manuell ausführen
docker-compose exec postgres pg_isready -U n8n_user -d n8n
```

## 🔄 Lifecycle Management

### Entwicklung

```bash
# Container starten
docker-compose up -d

# Logs live verfolgen
docker-compose logs -f n8n

# Bei Code-Änderungen: Container neu bauen
docker-compose up -d --build
```

### Testing

```bash
# Saubere Test-Umgebung
docker-compose down -v  # ACHTUNG: Löscht Daten!
docker-compose up -d

# Smoke Tests
curl -k https://localhost:5678/healthz
curl -k https://10.0.0.171:5678/healthz
curl -k https://MAC-PRO-INTEL.local:5678/healthz
```

### Production Readiness

Für den Übergang zu Production:

1. **Zertifikate**: Ersetze selbstsignierte durch offizielle
2. **Secrets Management**: Nutze Docker Secrets oder Vault
3. **Backups**: Automatisiere Backup-Prozess
4. **Monitoring**: Integriere Prometheus/Grafana
5. **High Availability**: Nutze Docker Swarm oder Kubernetes
6. **Reverse Proxy**: Erwäge Traefik oder Nginx für Load Balancing

## 📚 Weiterführende Dokumentation

### Offizielle Dokumentation
- **N8N**: https://docs.n8n.io/
- **PostgreSQL**: https://www.postgresql.org/docs/
- **Docker Compose**: https://docs.docker.com/compose/

### Compliance & Standards
- **CIS Docker Benchmark**: https://www.cisecurity.org/benchmark/docker
- **OWASP Container Security**: https://owasp.org/www-project-docker-top-10/

### Best Practices
- **Docker Security**: https://docs.docker.com/engine/security/
- **N8N Security**: https://docs.n8n.io/hosting/security/

## 🛠️ Konfiguration

### Umgebungsvariablen (.env)

| Variable | Beschreibung | Standard |
|----------|--------------|----------|
| `POSTGRES_DB` | PostgreSQL Datenbankname | `n8n` |
| `POSTGRES_USER` | PostgreSQL Benutzer | `n8n_user` |
| `POSTGRES_PASSWORD` | PostgreSQL Passwort | Auto-generiert |
| `N8N_HOST` | N8N Hostname | `MAC-PRO-INTEL.local` |
| `N8N_BASIC_AUTH_USER` | N8N Login Username | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | N8N Login Passwort | Auto-generiert |
| `TIMEZONE` | System Timezone | `Europe/Berlin` |

### Erweiterte N8N Konfiguration


Weitere N8N Optionen können in `docker-compose.yml` unter `environment` hinzugefügt werden:

```yaml
# Beispiele für erweiterte Konfiguration:
N8N_ENCRYPTION_KEY: "your-encryption-key"  # Für Credentials-Verschlüsselung
N8N_USER_MANAGEMENT_DISABLED: "true"       # User Management deaktivieren
N8N_DIAGNOSTICS_ENABLED: "false"           # Telemetrie deaktivieren
N8N_HIRING_BANNER_ENABLED: "false"         # Hiring Banner ausblenden
EXECUTIONS_TIMEOUT: "300"                  # Execution Timeout (Sekunden)
EXECUTIONS_TIMEOUT_MAX: "600"              # Max Execution Timeout
```

Siehe: https://docs.n8n.io/hosting/configuration/environment-variables/

## 🆘 Support & Kontakt

### N8N Community
- **Forum**: https://community.n8n.io/
- **Discord**: https://discord.gg/n8n
- **GitHub**: https://github.com/n8n-io/n8n

### Dieses Setup
- **Repository**: `/Volumes/PROJECTS/Github/N8N`
- **Dokumentation**: Diese README.md
- **Logs**: `logs/` Verzeichnis

## ⚠️ Wichtige Hinweise

### Sicherheit
- ⚠️ Dieses Setup ist für **lokale Entwicklung** optimiert
- ⚠️ Selbstsignierte Zertifikate sind **nicht für Production** geeignet
- ⚠️ Passwörter sind in `.env` im Klartext (für Dev akzeptabel)
- ⚠️ Keine Firewall-Regeln oder erweiterte Härtung implementiert

### Daten
- ✅ Alle Daten sind persistent in Volumes gespeichert
- ✅ Backups sollten regelmäßig erstellt werden
- ✅ `.env` und Zertifikate sind in `.gitignore` ausgeschlossen

### Performance
- 💡 Docker Desktop sollte mindestens 4GB RAM haben
- 💡 SSD wird für optimale Performance empfohlen
- 💡 Regelmäßiges Pruning von alten Images empfohlen

## 📝 Änderungshistorie

### Version 1.0.0 (2025-11-01)
- ✨ Initial Setup
- ✅ N8N mit SSL/TLS
- ✅ PostgreSQL Integration
- ✅ Basic Authentication
- ✅ Health Checks
- ✅ Strukturierte Logs
- ✅ Persistente Volumes
- ✅ Umfangreiche Dokumentation

## 📄 Lizenz

Dieses Setup basiert auf:
- **N8N**: Fair-code licensed (Sustainable Use License)
- **PostgreSQL**: PostgreSQL License (permissive)
- **Docker Compose Konfiguration**: MIT License (implizit für diese Config)

## 🎯 Quick Reference

```bash
# Start
docker-compose up -d

# Stop
docker-compose stop

# Logs
docker-compose logs -f

# Status
docker-compose ps

# Backup
./backup.sh  # (nach Erstellung)

# Update
docker-compose pull && docker-compose up -d

# Cleanup
docker-compose down
```

## 📞 Zugriff im Überblick

| Methode | URL | Port | Protokoll |
|---------|-----|------|-----------|
| Hostname | https://MAC-PRO-INTEL.local:5678 | 5678 | HTTPS |
| IP-Adresse | https://10.0.0.171:5678 | 5678 | HTTPS |
| Localhost | https://localhost:5678 | 5678 | HTTPS |

**Login**: `admin` / Passwort aus `.env` Datei

---

**Status**: ✅ Production Ready für lokale Entwicklung  
**Letzte Aktualisierung**: 2025-11-01  
**Maintainer**: IT-Architektur Team
