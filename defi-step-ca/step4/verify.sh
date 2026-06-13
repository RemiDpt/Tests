#!/bin/bash
ROOT="$(step path)/certs/root_ca.crt"
CAURL="https://localhost:4443"

# Émet un certificat de test SANS demander d'OU : c'est le template qui doit l'imposer.
rm -f /tmp/tpl.crt /tmp/tpl.key
TOKEN=$(step ca token tpl-check.lab.local --provisioner admin --password-file /root/.step-password \
  --ca-url "$CAURL" --root "$ROOT" 2>/dev/null)
step ca certificate tpl-check.lab.local /tmp/tpl.crt /tmp/tpl.key --token "$TOKEN" \
  --ca-url "$CAURL" --root "$ROOT" --force >/dev/null 2>&1

if [ ! -f /tmp/tpl.crt ]; then
  echo "Émission de test impossible : le template casse peut-être l'émission."
  echo "Regarde les logs de la CA : tail -n 20 /var/log/step-ca.log"
  exit 1
fi

if ! openssl x509 -in /tmp/tpl.crt -noout -subject | grep -qi "PKI-Defi"; then
  echo "Le certificat émis ne porte pas l'OU 'PKI-Defi' : le template n'impose pas le contenu."
  echo -n "Sujet obtenu : "; openssl x509 -in /tmp/tpl.crt -noout -subject
  rm -f /tmp/tpl.crt /tmp/tpl.key
  exit 1
fi

rm -f /tmp/tpl.crt /tmp/tpl.key
exit 0
