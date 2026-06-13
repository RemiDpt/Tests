#!/bin/bash
# Exécuté en foreground pendant l'intro (Killercoda attend la fin avant l'étape 1).
# Installe step CLI + step-ca via les paquets .deb officiels Smallstep.
set -e
cd /tmp
wget -q https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
wget -q https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
dpkg -i step-cli_amd64.deb step-ca_amd64.deb || apt-get install -f -y

# Mot de passe de lab volontairement trivial. NE JAMAIS reproduire en production.
echo "LabPKI-non-securise" > /root/.step-password
chmod 600 /root/.step-password
touch /root/.setup-done
