# n8n Linux Internal Deployment (Single Node)

## Zielbild
- Nur **interne Erreichbarkeit** (Port 5678 intern)
- **Kein Reverse Proxy**
- **Single Node** mit Docker Compose
- **Lokales Backup-Ziel**
- **Self-signed Zertifikate** für TLS

## Architektur
- `n8n` (App)
- `postgres` (Datenbank)

Cloud-AI-Agents konsumieren n8n über **outbound Integrationen** (z. B. Queue/Polling), nicht über öffentliches Inbound-Webhooking.

## Voraussetzungen
- Linux Server (Ubuntu 22.04+/Debian 12+)
- Docker + Docker Compose Plugin
- DNS intern auf Host-IP (z. B. `n8n.intern.local`)
- Firewall-Regel: Zugriff auf 5678 nur aus internem Netz/VPN

## Initial Setup
```bash
cd n8n-linux-internal-deployment
make init
```

1. `.env` anpassen (Pflichtfelder):
   - `N8N_HOST`
   - `N8N_ENCRYPTION_KEY`
   - `N8N_BASIC_AUTH_USER`
   - `N8N_BASIC_AUTH_PASSWORD`
   - `POSTGRES_PASSWORD`

2. Zertifikate erzeugen (self-signed):
```bash
N8N_HOST=n8n.intern.local make certs
```

3. Stack starten:
```bash
make up
```

4. Test:
```bash
curl -kI https://n8n.intern.local:5678
```

## OIDC / Entra Hinweis (wichtig)
Ohne Reverse Proxy ist OIDC/Entra in dieser Variante **nicht** über `oauth2-proxy` umsetzbar.

Optionen:
1. n8n Enterprise SSO (direkt in n8n, lizenzabhängig)
2. Reverse-Proxy-/Access-Gateway-Schicht (explizit von dir aktuell nicht gewünscht)

Bis dahin ist die sichere Standardvariante:
- intern-only Netzwerkzugriff
- TLS (self-signed)
- starkes n8n Basic Auth
- VPN/Segmentierung + Host-Firewall

## Betrieb
```bash
make status
make logs
make backup
```

## Restore
```bash
make restore POSTGRES_DUMP=./backups/postgres_YYYYMMDD_HHMMSS.dump N8N_ARCHIVE=./backups/n8n_data_YYYYMMDD_HHMMSS.tar.gz
```

## Security Baseline
- Keine direkte Exposition von n8n/postgres nach außen
- Host-Firewall aktiv (nur 5678 intern)
- Secrets nur in `.env`, Dateirechte 600
- `N8N_ENCRYPTION_KEY` sicher sichern (für Credentials zwingend)
- Regelmäßige Updates + monatlicher Restore-Test

## Self-signed Zertifikate in Clients vertrauen
Optional für interne Clients:
- `certs/n8n.crt` in lokale Trust Stores importieren
- Sonst `curl -k` oder Browser-Ausnahme für interne Nutzung
