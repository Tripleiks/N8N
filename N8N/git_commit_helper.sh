#!/bin/bash
# ============================================================================
# Git Commit Helper für Initial Setup
# ============================================================================

cd /Volumes/PROJECTS/Github/N8N

echo "🔍 Git Status vor Commit:"
git status

echo ""
echo "📦 Füge Dateien hinzu..."
git add .gitignore
git add .gitattributes
git add docker-compose.yml
git add .env.example
git add Makefile
git add backup.sh
git add README.md
git add CHANGELOG.md
git add SECURITY.md
git add QUICKSTART.md

echo ""
echo "✅ Dateien zum Commit vorbereitet"
echo ""
echo "📝 Commit Message:"
echo "─────────────────────────────────────────────"
cat << 'EOF'
feat: Initial N8N Docker setup with PostgreSQL and SSL

🎉 Initial commit for production-ready N8N Docker environment

Features:
- ✨ N8N latest with SSL/TLS support (self-signed via mkcert)
- ✨ PostgreSQL 16 Alpine as separate container
- ✨ Basic Authentication enabled
- ✨ Persistent volumes for data retention
- ✨ Health checks for both containers
- ✨ Auto-restart policy (unless-stopped)
- ✨ Structured logging configuration

Security:
- 🔐 Cryptographically secure auto-generated passwords
- 🔐 SSL/TLS encryption for all connections
- 🔐 PostgreSQL accessible only via internal network
- 🔐 Read-only mount for SSL certificates
- 🔐 Sensitive data excluded via .gitignore

Documentation:
- 📚 Comprehensive README with architecture diagram
- 📚 Quick Start Guide for rapid deployment
- 📚 Security Policy (SECURITY.md)
- 📚 Changelog for version tracking
- 📚 Troubleshooting guide
- 📚 Backup & Restore procedures

Tooling:
- 🛠️ Makefile for common operations
- 🛠️ Automated backup script (backup.sh)
- 🛠️ Docker Compose orchestration

Technical Stack:
- Docker Compose v3.8
- N8N (latest)
- PostgreSQL 16 Alpine
- mkcert for SSL certificates

Access:
- https://MAC-PRO-INTEL.local:5678
- https://10.0.0.171:5678
- https://localhost:5678

Compliance:
- Partially implements CIS Docker Benchmark
- Follows OWASP Container Security guidelines
- ISO 27001 relevant controls addressed

Files Added:
- docker-compose.yml (Container orchestration)
- .env.example (Environment template)
- .gitignore (Security: exclude sensitive data)
- .gitattributes (Git LF normalization)
- Makefile (Operation shortcuts)
- backup.sh (Automated backup script)
- README.md (Full documentation)
- QUICKSTART.md (5-minute setup guide)
- CHANGELOG.md (Version history)
- SECURITY.md (Security policy)

Version: 1.0.0
Created: 2025-11-01
System: macOS 15.7.1 Intel
Docker: 28.5.1
EOF
echo "─────────────────────────────────────────────"
echo ""
echo "🚀 Führe Commit aus mit:"
echo "   git commit -F commit_message.txt"
echo ""
echo "📤 Danach pushen mit:"
echo "   git push origin main"
