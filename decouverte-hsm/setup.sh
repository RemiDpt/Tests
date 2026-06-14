#!/bin/bash
set -e
apt-get update -qq
apt-get install -y -qq softhsm2 opensc libengine-pkcs11-openssl
MODULE=$(ls /usr/lib/softhsm/libsofthsm2.so /usr/lib/*/softhsm/libsofthsm2.so 2>/dev/null | head -1)
echo "Module SoftHSM2 : ${MODULE:-INTROUVABLE}"
touch /root/.setup-done
