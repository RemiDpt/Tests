#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root

[ -f /root/revoked_serial.txt ] || { echo "Écris le numéro de série révoqué dans /root/revoked_serial.txt"; exit 1; }
SERIAL=$(tr -d ' \t\r\n' < /root/revoked_serial.txt)
[ -n "$SERIAL" ] || { echo "/root/revoked_serial.txt est vide."; exit 1; }

CRLTXT=$(curl -s "$BAO_ADDR/v1/pki/crl/pem" | openssl crl -noout -text 2>/dev/null)
if ! echo "$CRLTXT" | grep -qi "Revoked Certificate"; then
  echo "La CRL ne contient aucune révocation. As-tu bien révoqué le certificat ?"
  exit 1
fi

# Comparaison normalisée (sans deux-points, en majuscules).
NORM=$(echo "$SERIAL" | tr -d ':' | tr 'a-f' 'A-F')
if ! echo "$CRLTXT" | tr -d ':' | tr 'a-f' 'A-F' | grep -q "$NORM"; then
  echo "Le numéro de série $SERIAL n'apparaît pas dans la CRL."
  echo "Vérifie que la série dans /root/revoked_serial.txt est bien celle du certificat révoqué."
  exit 1
fi

exit 0
