#!/bin/bash
# Exécuté en foreground pendant l'intro (Killercoda attend la fin avant l'étape 1).
# Installe OpenBao via le .deb officiel des releases GitHub, + jq pour lire le JSON.
set -e

# ⚠️ Version épinglée — vérifier que cette release existe et que l'URL répond.
BAO_VERSION="2.3.1"

cd /tmp
wget -q "https://github.com/openbao/openbao/releases/download/v${BAO_VERSION}/bao_${BAO_VERSION}_linux_amd64.deb"
dpkg -i "bao_${BAO_VERSION}_linux_amd64.deb" || apt-get install -f -y

apt-get update -qq
apt-get install -y -qq jq

touch /root/.setup-done
