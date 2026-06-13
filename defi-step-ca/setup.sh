#!/bin/bash
# Exécuté en foreground pendant l'intro (Killercoda attend la fin avant l'étape 1).
# Installe step CLI + step-ca (.deb officiels), initialise une CA avec le support SSH
# activé, et la démarre. Les défis travaillent ensuite CONTRE cette CA.
set -e
cd /tmp
wget -q https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
wget -q https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
dpkg -i step-cli_amd64.deb step-ca_amd64.deb || apt-get install -f -y

# jq sert à éditer ca.json aux défis 3 et 4.
apt-get update -qq
apt-get install -y -qq jq

# Mot de passe de lab volontairement trivial. NE JAMAIS reproduire en production.
echo "LabPKI-non-securise" > /root/.step-password
chmod 600 /root/.step-password

# CA autonome AVEC clés SSH (nécessaire au défi 2). Provisioner JWK "admin".
# ⚠️ À TESTER EN LIVE : l'option --ssh selon la version du step CLI installée.
step ca init --deployment-type standalone --name "Defi Lab Root CA" \
  --dns localhost --address ":4443" --provisioner admin \
  --password-file /root/.step-password --ssh

# Démarrage de la CA en arrière-plan (chaque étape la relance si besoin).
nohup step-ca "$(step path)/config/ca.json" --password-file /root/.step-password \
  >/var/log/step-ca.log 2>&1 &

touch /root/.setup-done
