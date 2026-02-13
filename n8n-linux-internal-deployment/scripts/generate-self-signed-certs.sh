#!/usr/bin/env bash
set -Eeuo pipefail

CERT_DIR="${1:-./certs}"
CERT_DAYS="${CERT_DAYS:-825}"
N8N_HOST="${N8N_HOST:-n8n.intern.local}"

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout "$CERT_DIR/n8n.key" \
  -out "$CERT_DIR/n8n.crt" \
  -days "$CERT_DAYS" \
  -subj "/C=DE/ST=NRW/L=Internal/O=Local/CN=${N8N_HOST}" \
  -addext "subjectAltName=DNS:${N8N_HOST},IP:127.0.0.1"

chmod 600 "$CERT_DIR/n8n.key"
chmod 644 "$CERT_DIR/n8n.crt"

echo "[OK] Self-signed Zertifikate erstellt in: $CERT_DIR"
echo "      CRT: $CERT_DIR/n8n.crt"
echo "      KEY: $CERT_DIR/n8n.key"
