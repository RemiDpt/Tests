#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root

# Localise le fichier du serial sans supposer le dossier.
SFILE=""
for d in "$PWD" /root /tmp "$HOME"; do
  [ -f "$d/revoked_serial.txt" ] && { SFILE="$d/revoked_serial.txt"; break; }
done
if [ -z "$SFILE" ]; then
  echo "revoked_serial.txt introuvable (cherché dans le dossier courant, /root, /tmp)."
  echo "Écris-y le numéro de série du certificat révoqué."
  exit 1
fi
SERIAL=$(tr -d ' \t\r\n' < "$SFILE")
[ -n "$SERIAL" ] || { echo "$SFILE est vide."; exit 1; }

CRLTXT=$(curl -s "$BAO_ADDR/v1/pki/crl/pem" | openssl crl -noout -text 2>/dev/null)
if ! echo "$CRLTXT" | grep -qi "Revoked Certificate"; then
  echo "La CRL ne contient aucune révocation. As-tu bien révoqué le certificat ?"
  exit 1
fi

# Comparaison normalisée (sans deux-points, en majuscules).
NORM=$(echo "$SERIAL" | tr -d ':' | tr 'a-f' 'A-F')
if ! echo "$CRLTXT" | tr -d ':' | tr 'a-f' 'A-F' | grep -q "$NORM"; then
  echo "Le numéro de série $SERIAL n'apparaît pas dans la CRL."
  echo "Vérifie que la série enregistrée est bien celle du certificat révoqué."
  exit 1
fi

exit 0
