#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root
if ! bao secrets list 2>/dev/null | grep -q '^pki/'; then
  echo "Moteur PKI non monté. Lance : bao secrets enable pki"
  echo "(OpenBao doit tourner : bao status)"
  exit 1
fi
if ! bao read -field=certificate pki/cert/ca >/dev/null 2>&1; then
  echo "Moteur PKI monté, mais pas de CA racine. Lance le bloc 'pki/root/generate/internal' de l'étape."
  exit 1
fi
if ! bao read pki/roles/serveur-court >/dev/null 2>&1; then
  echo "CA présente, mais rôle 'serveur-court' manquant. Lance le bloc 'pki/roles/serveur-court' de l'étape."
  exit 1
fi
exit 0
