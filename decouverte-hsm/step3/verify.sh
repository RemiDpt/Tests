#!/bin/bash
if [ ! -f /root/ca-hsm.crt ]; then
  echo "Certificat racine /root/ca-hsm.crt introuvable."
  echo "C'est la commande 'openssl req ... -engine pkcs11' qui le produit (étape la plus sensible)."
  echo "Engine PKCS#11 selon la version d'OpenSSL (1.1 vs 3), PKCS11_MODULE_PATH, p11-kit."
  exit 1
fi
if openssl x509 -in /root/ca-hsm.crt -noout -subject 2>/dev/null | grep -qi 'Lab Root CA HSM'; then
  exit 0
fi
echo "/root/ca-hsm.crt présent mais ne ressemble pas au certificat attendu."
echo "Vérifie le sujet : openssl x509 -in /root/ca-hsm.crt -noout -subject"
exit 1
