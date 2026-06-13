#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root

[ -f /root/ext_root.crt ] || { echo "/root/ext_root.crt manquant (la racine externe)."; exit 1; }

# 1) pki_int doit avoir une CA signée.
if ! bao read -field=certificate pki_int/cert/ca > /tmp/int.crt 2>/dev/null; then
  echo "pki_int n'a pas de certificat de CA : mount 'pki_int' absent ou set-signed non effectué."
  exit 1
fi

# 2) L'intermédiaire doit être signée par la racine externe.
if ! openssl verify -CAfile /root/ext_root.crt /tmp/int.crt >/dev/null 2>&1; then
  echo "L'intermédiaire de pki_int n'est pas signée par /root/ext_root.crt."
  exit 1
fi

# 3) Une feuille émise par pki_int doit chaîner jusqu'à la racine externe.
if ! bao write -format=json pki_int/issue/leaf common_name=svc.lab.local ttl=10m > /tmp/leaf.json 2>/dev/null; then
  echo "Émission impossible via pki_int/issue/leaf : crée le rôle 'leaf' sur pki_int."
  exit 1
fi
jq -r .data.certificate /tmp/leaf.json > /tmp/leaf.crt
if ! openssl verify -CAfile /root/ext_root.crt -untrusted /tmp/int.crt /tmp/leaf.crt >/dev/null 2>&1; then
  echo "La chaîne feuille -> intermédiaire -> racine externe ne se vérifie pas."
  exit 1
fi

exit 0
