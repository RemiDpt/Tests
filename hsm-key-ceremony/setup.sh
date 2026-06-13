#!/bin/bash
# Exécuté en foreground pendant l'intro (Killercoda attend la fin avant l'étape 1).
# Installe SoftHSM2 (le "HSM logiciel"), pkcs11-tool (paquet opensc) et l'engine
# PKCS#11 d'OpenSSL pour faire signer par une clé qui reste dans le HSM.
# ⚠️ TOUT ce lab est à valider en live : noms de paquets et chemins peuvent varier
#    selon la version d'Ubuntu de l'image Killercoda.
set -e
apt-get update -qq
apt-get install -y -qq softhsm2 opensc libengine-pkcs11-openssl

# Repérer le module PKCS#11 de SoftHSM2 (le chemin varie selon la distribution).
MODULE=$(ls /usr/lib/softhsm/libsofthsm2.so /usr/lib/*/softhsm/libsofthsm2.so 2>/dev/null | head -1)
echo "Module SoftHSM2 détecté : ${MODULE:-INTROUVABLE}"

touch /root/.setup-done
