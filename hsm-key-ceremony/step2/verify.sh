#!/bin/bash
MODULE=$(ls /usr/lib/softhsm/libsofthsm2.so /usr/lib/*/softhsm/libsofthsm2.so 2>/dev/null | head -1)
if [ -z "$MODULE" ]; then
  echo "Module SoftHSM2 introuvable. Cherche-le : find / -name 'libsofthsm2.so' 2>/dev/null"
  exit 1
fi
OBJ=$(pkcs11-tool --module "$MODULE" --token-label "CA-Root-HSM" --login --pin 1234 --list-objects 2>/dev/null)
if echo "$OBJ" | grep -qi 'Private Key' && echo "$OBJ" | grep -q 'ca-root-key'; then
  exit 0
fi
echo "Clé privée 'ca-root-key' non trouvée dans le token."
echo "Lance le bloc 'pkcs11-tool ... --keypairgen ...' de l'étape, puis re-clique sur Check."
exit 1
