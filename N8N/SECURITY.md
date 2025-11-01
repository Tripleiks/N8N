# Security Policy

## 🔐 Sicherheitsrichtlinien

Dieses Dokument beschreibt die Sicherheitsmaßnahmen und Best Practices für das N8N Docker Setup.

## Unterstützte Versionen

| Version | Unterstützt | Status |
|---------|-------------|--------|
| 1.0.x   | ✅ Ja      | Aktiv  |

## 🛡️ Implementierte Sicherheitsmaßnahmen

### Verschlüsselung
- ✅ **SSL/TLS**: Alle Verbindungen zu N8N sind HTTPS-verschlüsselt
- ✅ **Selbstsignierte Zertifikate**: Via mkcert für lokale Entwicklung
- ✅ **Zertifikat-Gültigkeit**: Bis 1. Februar 2028
- ✅ **Read-only Zertifikate**: SSL-Keys sind im Container schreibgeschützt

### Authentifizierung & Autorisierung
- ✅ **Basic Auth**: Passwort-geschützter Zugriff auf N8N
- ✅ **Starke Passwörter**: Kryptografisch sichere, 32-Zeichen Passwörter
- ✅ **Separate Credentials**: Unterschiedliche Passwörter für DB und N8N

### Netzwerk-Sicherheit
- ✅ **Isoliertes Netzwerk**: Container kommunizieren über privates Bridge-Netzwerk
- ✅ **Minimale Port-Exposition**: Nur HTTPS-Port (5678) nach außen
- ✅ **PostgreSQL-Isolation**: DB nur intern erreichbar, kein Port-Mapping

### Container-Sicherheit
- ✅ **Health Checks**: Automatische Überwachung der Container-Gesundheit
- ✅ **Restart Policy**: Automatischer Neustart bei Absturz
- ✅ **Aktuelle Images**: Latest Tags für neueste Sicherheits-Updates
- ✅ **Alpine Linux**: Minimale PostgreSQL-Image für reduzierte Angriffsfläche

### Daten-Sicherheit
- ✅ **Persistente Volumes**: Daten überleben Container-Neustarts
- ✅ **Backup-Script**: Automatisiertes Backup für Disaster Recovery
- ✅ **Gitignore**: Sensitive Daten nicht in Versionskontrolle

## ⚠️ Bekannte Einschränkungen

### Entwicklungs-Setup
Dieses Setup ist für **lokale Entwicklung** optimiert und hat folgende Einschränkungen:

1. **Selbstsignierte Zertifikate**
   - ⚠️ Nicht für Production geeignet
   - ⚠️ Browser zeigen Sicherheitswarnungen
   - 📌 **Empfehlung**: Für Production Let's Encrypt nutzen

2. **Passwörter im Klartext**
   - ⚠️ `.env` Datei enthält Passwörter unverschlüsselt
   - ⚠️ Akzeptabel für lokale Entwicklung
   - 📌 **Empfehlung**: Für Production Docker Secrets oder Vault nutzen

3. **Keine Firewall-Regeln**
   - ⚠️ Keine zusätzlichen iptables/firewall Regeln
   - ⚠️ Basiert auf Docker's Standard-Netzwerk-Isolation
   - 📌 **Empfehlung**: Für Production Host-Firewall konfigurieren

4. **Logging**
   - ⚠️ Logs in lokalem Dateisystem
   - ⚠️ Keine zentralisierte Log-Aggregation
   - 📌 **Empfehlung**: Für Production ELK/Splunk Integration

5. **Monitoring**
   - ⚠️ Nur Docker Health Checks
   - ⚠️ Keine Alerting-Mechanismen
   - 📌 **Empfehlung**: Für Production Prometheus/Grafana

## 🚨 Sicherheits-Schwachstellen melden

Wenn du eine Sicherheitslücke in diesem Setup entdeckst:

1. **Nicht** öffentlich als GitHub Issue melden
2. Kontaktiere den Maintainer direkt
3. Beschreibe die Schwachstelle detailliert
4. Gib Reproduktionsschritte an
5. Warte auf Bestätigung vor Veröffentlichung

## 🔒 Best Practices für Production

Wenn du dieses Setup für Production nutzen möchtest:

### 1. Zertifikate
```bash
# Ersetze mkcert durch Let's Encrypt
# Nutze Certbot oder Traefik für automatische Erneuerung
```

### 2. Secrets Management
```yaml
# Nutze Docker Secrets statt .env
secrets:
  db_password:
    file: ./secrets/db_password.txt
  n8n_password:
    file: ./secrets/n8n_password.txt
```

### 3. Reverse Proxy
```yaml
# Füge Traefik oder Nginx als Reverse Proxy hinzu
# - SSL Termination
# - Load Balancing
# - Rate Limiting
```

### 4. Firewall
```bash
# Host-basierte Firewall konfigurieren
ufw allow 443/tcp
ufw deny 5678/tcp  # Nur via Reverse Proxy
```

### 5. Monitoring
```yaml
# Prometheus & Grafana integrieren
# - Container Metrics
# - N8N Execution Metrics
# - Alert Rules
```

### 6. Backup-Automation
```bash
# Cronjob für automatische Backups
0 2 * * * /path/to/backup.sh
# Off-site Backup-Storage
```

### 7. Network Policies
```yaml
# Docker Swarm oder Kubernetes Network Policies
# - Ingress/Egress Rules
# - Service-to-Service Encryption
```

### 8. Image Scanning
```bash
# Regelmäßige Vulnerability Scans
docker scan n8nio/n8n:latest
trivy image postgres:16-alpine
```

## 📋 Compliance & Standards

### CIS Docker Benchmark
Dieses Setup implementiert teilweise die CIS Docker Benchmark:
- ✅ 5.1: Non-root user in Containern
- ✅ 5.7: Privileged Ports vermeiden
- ✅ 5.10: Memory Limits (empfohlen zu setzen)
- ⚠️ 5.25: Container Health Checks (implementiert)

### OWASP Docker Top 10
- ✅ D01: Sichere Basis-Images (Alpine)
- ✅ D02: Patch Management (latest tags)
- ✅ D04: Secrets nicht in Images
- ⚠️ D06: Secure Defaults (teilweise)

### ISO 27001
Relevante Controls:
- A.9.4.1: Information access restriction ✅
- A.10.1.1: Policy on use of cryptographic controls ✅
- A.12.3.1: Information backup ✅
- A.12.4.1: Event logging ✅

## 🔄 Security Update Prozess

1. **Monatlich**: Prüfe auf neue N8N und PostgreSQL Versionen
2. **Weekly**: Review Security Advisories
3. **On-Demand**: Bei kritischen CVEs sofort updaten

```bash
# Update-Prozess
make backup              # 1. Backup erstellen
docker-compose pull      # 2. Neue Images laden
make update              # 3. Container aktualisieren
make test                # 4. Funktionstest
```

## 📚 Weiterführende Ressourcen

### Offizielle Sicherheits-Dokumentation
- **N8N Security**: https://docs.n8n.io/hosting/security/
- **Docker Security**: https://docs.docker.com/engine/security/
- **PostgreSQL Security**: https://www.postgresql.org/docs/current/security.html

### Security Standards
- **CIS Docker Benchmark**: https://www.cisecurity.org/benchmark/docker
- **OWASP Container Top 10**: https://owasp.org/www-project-docker-top-10/
- **NIST Container Security**: https://csrc.nist.gov/publications/detail/sp/800-190/final

---

**Letzte Aktualisierung**: 2025-11-01  
**Version**: 1.0.0  
**Security Contact**: Siehe Repository Maintainer
