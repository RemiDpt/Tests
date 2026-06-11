#!/bin/bash
if docker exec ejbca /opt/keyfactor/bin/ejbca.sh ca listcas 2>/dev/null | grep -q 'LabRootCA'; then
  exit 0
fi
echo "CA 'LabRootCA' introuvable."
echo "Relance le bloc 'ejbca.sh ca init' de l'étape. Si la commande échoue, lis son"
echo "message d'erreur : un argument mal placé est la cause la plus fréquente."
exit 1
