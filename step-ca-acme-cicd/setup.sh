#!/bin/bash
# Exécuté pendant la lecture de l'intro (foreground : Killercoda attend la fin).
# Installe step CLI + step-ca + certbot (le client ACME, "Let's Encrypt" du lab).
set -e
cd /tmp
wget -q https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
wget -q https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
dpkg -i step-cli_amd64.deb step-ca_amd64.deb || apt-get install -f -y

apt-get update -qq
apt-get install -y -qq certbot

# Nom d'hôte du runner CI simulé, résolu localement (pour le challenge HTTP-01).
grep -q ci-runner.lab.local /etc/hosts || echo "127.0.0.1 ci-runner.lab.local" >> /etc/hosts

# Mot de passe de lab volontairement trivial. NE JAMAIS reproduire en production.
echo "LabPKI-non-securise" > /root/.step-password
chmod 600 /root/.step-password
touch /root/.setup-done
