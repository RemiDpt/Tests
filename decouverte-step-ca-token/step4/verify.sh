#!/bin/bash
# Vérifie qu'un certificat a bien été obtenu par ACME et qu'il chaîne jusqu'à la racine.
FULL=$(ls /root/.acme.sh/acme.lab.local*/fullchain.cer 2>/dev/null | head -1)
LEAF=$(ls /root/.acme.sh/acme.lab.local*/acme.lab.local.cer 2>/dev/null | head -1)
CERT="${FULL:-$LEAF}"

if [ -z "$CERT" ]; then
  echo "Certificat ACME introuvable sous /root/.acme.sh/acme.lab.local*/."
  echo "Lance le bloc 'acme.sh --issue ...' de l'étape, puis re-clique sur Check."
  exit 1
fi

if step certificate verify "$CERT" --roots /root/.step/certs/root_ca.crt 2>/dev/null; then
  echo "Certificat ACME obtenu et signé par ta CA : OK ($CERT)."
  exit 0
fi

echo "Le certificat ACME ($CERT) ne se vérifie pas contre la racine de la CA."
echo "Vérifie que la provisioner ACME est active et que l'émission a réussi."
exit 1
