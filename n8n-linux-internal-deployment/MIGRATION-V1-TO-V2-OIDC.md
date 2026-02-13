# Mini-Migrationsroadmap: Variante 1 -> Variante 2

Ziel: Migration von **No-Proxy + Basic Auth** zu **oauth2-proxy + Entra OIDC** bei internem Linux Single-Node Betrieb.

## Scope
- Beibehalten: Single Node, Postgres, lokale Backups, interne Erreichbarkeit
- Neu: Access-Schicht mit `oauth2-proxy` und (optional) `nginx` für TLS/Headers
- Entfernen: direkter Browser-Login per n8n Basic Auth (nach erfolgreicher Umstellung)

---

## Phase 0 - Vorbereitung (0.5 Tag)

## 0.1 Technische Voraussetzungen
- Entra App Registration vorhanden
- Interner DNS-Name (z. B. `n8n.intern.local`)
- Firewall intern (nur gewünschte Quellnetze)

## 0.2 Entra App Registration
- Redirect URI anlegen:
  - `https://n8n.intern.local/oauth2/callback`
- Scopes: `openid profile email`
- Optional: Gruppenzuweisung für Zugriff

## 0.3 Secret-Plan
- Client Secret und Cookie Secret vorbereiten
- `.env` Rechte absichern (`chmod 600 .env`)

---

## Phase 1 - Infrastrukturänderung (0.5 Tag)

## 1.1 Compose anpassen
In `docker-compose.yml`:
1. `oauth2-proxy` Service hinzufügen
2. optional `nginx` Service vor `oauth2-proxy` (TLS-Terminierung)
3. n8n nur intern exposen (kein direkter Public-Path)
4. Forwarded Headers korrekt setzen

## 1.2 .env erweitern
Zusätzliche Variablen:
- `OIDC_ISSUER_URL=https://login.microsoftonline.com/<TENANT_ID>/v2.0`
- `OIDC_CLIENT_ID=...`
- `OIDC_CLIENT_SECRET=...`
- `OAUTH2_PROXY_COOKIE_SECRET=...`
- `OIDC_ALLOWED_EMAIL_DOMAIN=...`

## 1.3 TLS
- Self-signed Zertifikate weiterverwenden oder neu generieren
- Zertifikat intern verteilen (Trust Store), damit Warnungen entfallen

---

## Phase 2 - Cutover (0.5 Tag)

## 2.1 Wartungsfenster
- Backup ausführen:
  - `make backup`
- Aktuellen Stand taggen/branchen

## 2.2 Deployment
- Neue Services starten:
  - `docker compose up -d`
- Health/Logs prüfen:
  - `docker compose ps`
  - `docker compose logs -f oauth2-proxy`
  - `docker compose logs -f n8n`

## 2.3 Auth-Test
- Browser: `https://n8n.intern.local`
- Erwartung: Redirect zu Entra Login
- Nach Login: Zugriff auf n8n UI

---

## Phase 3 - Validierung (0.5 Tag)

## 3.1 Funktionale Tests
- Login mit berechtigtem User -> Erfolg
- Login mit unberechtigtem User -> Block
- Workflow-Manuellauf -> Erfolg
- Beispiel-Webhook/Trigger -> Erfolg

## 3.2 Security Tests
- Direkter Zugriff auf n8n-Backend (Bypass) blockiert
- Nur interne Netze kommen durch Firewall
- Session/Cookie Verhalten prüfen (secure, httponly)

## 3.3 Betriebsprüfung
- Backup/Restore unverändert funktionsfähig
- Logging ausreichend für Audit/Troubleshooting

---

## Rollback-Plan (max. 15-30 Min)

Wenn OIDC-Cutover fehlschlägt:
1. Stack stoppen
2. Compose auf V1 (No-Proxy) zurückstellen
3. `docker compose up -d`
4. Basic Auth Login testen
5. Incident Notiz + Root Cause nachziehen

---

## Risiken & Gegenmaßnahmen

1. **Falsche Redirect URI**
   - Gegenmaßnahme: URI exakt prüfen (`/oauth2/callback`)

2. **Cookie Secret ungültig**
   - Gegenmaßnahme: 32-byte base64 (`openssl rand -base64 32`)

3. **Header/Proxy-Konfiguration unvollständig**
   - Gegenmaßnahme: `X-Forwarded-*` sauber setzen, Testlogin durchführen

4. **Zertifikatswarnungen**
   - Gegenmaßnahme: internes Trust-Deployment für self-signed CRT

---

## Abnahme-Checkliste
- [ ] Entra Login funktioniert (MFA/Conditional Access wirksam)
- [ ] Nur autorisierte User erhalten Zugang
- [ ] Workflows laufen nach Login stabil
- [ ] Backup/Restore getestet
- [ ] Rollback-Schritte dokumentiert und getestet
- [ ] Monitoring/Logs in Betrieb

---

## Empfehlung für Umsetzung
1. Erst in Staging mit identischer Entra App testen
2. Produktiv-Cutover in kleinem Wartungsfenster
3. Nach Go-Live 48h engmaschiges Monitoring
