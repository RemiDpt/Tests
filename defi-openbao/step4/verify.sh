#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root

# Localise la racine externe sans supposer le dossier.
EXT=""
for d in "$PWD" /root /tmp "$HOME"; do
  [ -f "$d/ext_root.crt" ] && { EXT="$d/ext_root.crt"; break; }
done
if [ -z "$EXT" ]; then
  echo "ext_root.crt introuvable (cherché dans le dossier courant, /root, /tmp)."
  echo "Crée la racine externe (OpenSSL) sous le nom ext_root.crt."
  exit 1
fi

# 1) pki_int doit avoir une CA signée.
if ! bao read -field=certificate pki_int/cert/ca > /tmp/int.crt 2>/dev/null; then
  echo "pki_int n'a pas de certificat de CA : mount 'pki_int' absent ou set-signed non effectué."
  exit 1
fi

# 2) L'intermédiaire doit être signée par la racine externe.
if ! openssl verify -CAfile "$EXT" /tmp/int.crt >/dev/null 2>&1; then
  echo "L'intermédiaire de pki_int n'est pas signée par $EXT."
  exit 1
fi

# 3) Un certificat émis par pki_int doit chaîner jusqu'à la racine externe.
if ! bao write -format=json pki_int/issue/endentity common_name=svc.lab.local ttl=10m > /tmp/endentity.json 2>/dev/null; then
  echo "Émission impossible via pki_int/issue/endentity : crée le rôle 'endentity' sur pki_int."
  exit 1
fi
jq -r .data.certificate /tmp/endentity.json > /tmp/endentity.crt
if ! openssl verify -CAfile "$EXT" -untrusted /tmp/int.crt /tmp/endentity.crt >/dev/null 2>&1; then
  echo "La chaîne entité finale -> intermédiaire -> racine externe ne se vérifie pas."
  exit 1
fi

exit 0
