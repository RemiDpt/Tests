#!/bin/bash
# Exécuté en foreground pendant l'intro (Killercoda attend la fin avant l'étape 1).
# Démarre EJBCA Community (image officielle Keyfactor) et attend qu'il soit prêt.
# ⚠️ EJBCA est lourd (WildFly/Java) : démarrage en 2 à 5 minutes, annoncé dans l'intro.
set -e

# Docker est normalement préinstallé sur l'image Killercoda ubuntu.
command -v docker >/dev/null || apt-get install -y -qq docker.io

# TLS_SETUP_ENABLED=simple : accès Admin UI en HTTPS SANS certificat client.
# Réservé aux tests jetables (doc officielle) — exactement notre cas. Jamais en prod.
docker run -d --name ejbca -h ca.lab.local \
  -p 80:8080 -p 443:8443 \
  -e TLS_SETUP_ENABLED=simple \
  keyfactor/ejbca-ce

# Attente active du healthcheck applicatif (réponse "ALLOK").
echo "Démarrage d'EJBCA en cours (2 à 5 minutes)..."
for i in $(seq 1 90); do
  if curl -s http://localhost/ejbca/publicweb/healthcheck/ejbcahealth 2>/dev/null | grep -q ALLOK; then
    echo "EJBCA est prêt."
    break
  fi
  sleep 5
done

touch /root/.setup-done
