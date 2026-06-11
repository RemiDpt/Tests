#!/bin/bash
# Exécuté en foreground pendant l'intro (Killercoda attend la fin avant l'étape 1).
# Déploie OpenXPKI via le docker-compose officiel (openxpki-docker) + config communautaire.
# ⚠️ Le pull des images prend plusieurs minutes : c'est voulu, l'intro l'annonce.
set -e

# Docker est normalement préinstallé sur l'image Killercoda ubuntu.
# ⚠️ Garde-fou à valider en live : si absent, on tente l'installation apt.
command -v docker >/dev/null || apt-get install -y -qq docker.io docker-compose-v2

cd /root
git clone --quiet https://github.com/openxpki/openxpki-docker.git
cd openxpki-docker
git clone --quiet https://github.com/openxpki/openxpki-config.git \
  --single-branch --branch=community

# 1) Clé d'authentification CLI (requise par le quickstart officiel) :
#    clé EC générée ici, clé publique injectée dans config.d/system/cli.yaml.
mkdir -p config
openssl ecparam -name prime256v1 -genkey -noout -out config/client.key
chmod 644 config/client.key
PUBKEY=$(openssl pkey -in config/client.key -pubout)
cat > openxpki-config/config.d/system/cli.yaml <<EOF
auth:
  admin:
    key: |
$(echo "$PUBKEY" | sed 's/^/      /')
    role: RA Operator
EOF

# 2) Secret de chiffrement du datavault : remplace le placeholder ##SVAULTKEY##.
SVAULT=$(openssl rand -hex 32)
sed -i "s|you must put your own 64 characters key here ##SVAULTKEY##|$SVAULT|" \
  openxpki-config/config.d/system/crypto.yaml

# 3) Démarrage de la pile (db -> server -> client -> web, healthchecks en cascade).
docker compose up -d web

# 4) Config d'exemple : CA racine + émettrice de démo, comptes de test
#    (bob/alice côté utilisateurs, raop/rob/rose côté opérateurs, mdp "openxpki").
docker compose exec -u pkiadm server /bin/bash /etc/openxpki/contrib/sampleconfig.sh

touch /root/.setup-done
