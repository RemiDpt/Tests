#!/bin/bash
# Exécuté en arrière-plan pendant la lecture de l'intro.
# Installe step CLI + step-ca via le dépôt apt officiel Smallstep.
set -e
curl -fsSL https://packages.smallstep.com/keys/apt/repo-signing-key.gpg \
  -o /etc/apt/trusted.gpg.d/smallstep.asc
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/smallstep.asc] https://packages.smallstep.com/stable/debian debs main' \
  > /etc/apt/sources.list.d/smallstep.list
apt-get update -qq
apt-get install -y -qq step-cli step-ca

# Mot de passe de lab volontairement trivial. NE JAMAIS reproduire en production :
# la clé privée d'une CA se protège par HSM ou passphrase forte + stockage hors-ligne.
echo "LabPKI-non-securise" > /root/.step-password
chmod 600 /root/.step-password
touch /root/.setup-done
