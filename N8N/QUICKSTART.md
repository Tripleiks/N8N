# Quick Start Guide - N8N Docker Setup

## 🚀 Schnellstart (5 Minuten)

### Voraussetzungen prüfen
```bash
docker --version    # Sollte 20.10+ sein
mkcert -version     # Sollte v1.4+ sein
```

### 1. Repository klonen
```bash
cd /Volumes/PROJECTS
git clone <dein-repo-url> N8N_Projects
cd N8N_Projects
```

### 2. Umgebungsvariablen einrichten
```bash
# Template kopieren
cp .env.example .env

# Passwörter generieren
echo "POSTGRES_PASSWORD=$(openssl rand -base64 24)" >> .env
echo "N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 24)" >> .env

# .env editieren und Werte anpassen
nano .env  # oder vim, code, etc.
```

### 3. SSL-Zertifikate erstellen
```bash
# Verzeichnis erstellen
mkdir -p certs

# Zertifikate generieren (ersetze mit deinen Werten)
cd certs
mkcert -cert-file cert.pem -key-file key.pem \
    $(hostname) \
    $(ipconfig getifaddr en0) \
    localhost \
    127.0.0.1 \
    ::1
cd ..
```

### 4. Verzeichnisse erstellen
```bash
mkdir -p data postgres_data logs backups
```

### 5. Container starten
```bash
# Mit Docker Compose
docker-compose up -d

# ODER mit Makefile
make start
```

### 6. Status prüfen
```bash
# Mit Docker Compose
docker-compose ps
docker-compose logs -f

# ODER mit Makefile
make status
make logs
```

### 7. N8N aufrufen
```bash
# Im Browser öffnen:
# https://localhost:5678
# https://<deine-ip>:5678
# https://<dein-hostname>:5678

# Login mit Credentials aus .env Datei:
# Username: admin
# Password: <N8N_BASIC_AUTH_PASSWORD>
```

## 📱 Makefile Shortcuts

Falls `make` installiert ist:

```bash
make start      # Container starten
make stop       # Container stoppen
make logs       # Logs anzeigen
make status     # Status prüfen
make backup     # Backup erstellen
make test       # Verbindung testen
make help       # Alle Befehle anzeigen
```

## 🆘 Troubleshooting

### Port bereits belegt
```bash
# Prozess identifizieren
lsof -i :5678

# Container-Port ändern in docker-compose.yml
ports:
  - "5679:5678"  # Nutze anderen Host-Port
```

### Zertifikat-Warnung im Browser
```bash
# mkcert CA installieren
mkcert -install

# Browser-Cache leeren und neu laden
```

### PostgreSQL startet nicht
```bash
# Logs prüfen
docker-compose logs postgres

# Permissions prüfen
ls -la postgres_data/

# Fresh Start
docker-compose down -v
docker-compose up -d
```

## 📚 Weitere Informationen

Siehe vollständige [README.md](README.md) für:
- Detaillierte Architektur
- Sicherheits-Best-Practices
- Backup & Restore Prozeduren
- Erweiterte Konfiguration
- Production Deployment

## 🔗 Wichtige Links

- **N8N Dokumentation**: https://docs.n8n.io/
- **Docker Compose Docs**: https://docs.docker.com/compose/
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

---

**Bei Problemen**: Siehe [README.md - Troubleshooting](README.md#-troubleshooting)
