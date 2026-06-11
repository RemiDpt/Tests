#!/bin/bash
CFG="/root/.step/config/ca.json"
if [ ! -f "$CFG" ]; then
  echo "PKI absente ($CFG introuvable). Lance d'abord le bloc 'step ca init' de l'étape."
  exit 1
fi
if grep -qi '"type": *"ACME"' "$CFG"; then
  exit 0
fi
echo "PKI présente, mais provisioner ACME manquante. Lance 'step ca provisioner add acme --type ACME'."
exit 1
