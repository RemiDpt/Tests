#!/bin/bash
if softhsm2-util --show-slots 2>/dev/null | grep -q 'CA-Root-HSM'; then
  exit 0
fi
echo "Token 'CA-Root-HSM' introuvable."
echo "Lance le bloc 'softhsm2-util --init-token ...' de l'étape, puis re-clique sur Check."
echo "Si l'init échoue, vérifie que SoftHSM2 est installé : softhsm2-util --version"
exit 1
