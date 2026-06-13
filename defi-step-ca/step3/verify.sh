#!/bin/bash
ROOT="$(step path)/certs/root_ca.crt"
CAURL="https://localhost:4443"

# 1) Le certificat conforme doit exister (cherché sans supposer le dossier).
GOOD=""
for d in "$PWD" /root /tmp "$HOME"; do
  [ -f "$d/good.crt" ] && { GOOD="$d/good.crt"; break; }
done
if [ -z "$GOOD" ]; then
  echo "good.crt introuvable (cherché dans le dossier courant, /root, /tmp)."
  echo "Émets d'abord un certificat conforme pour app.lab.local dans good.crt."
  exit 1
fi
if ! openssl x509 -in "$GOOD" -noout -text | grep -qi "lab.local"; then
  echo "$GOOD ne vise pas un nom *.lab.local."
  exit 1
fi

# 2) La politique doit RÉELLEMENT refuser un nom hors lab.local.
#    On tente une émission interdite : elle DOIT échouer.
rm -f /tmp/evil.crt /tmp/evil.key
TOKEN=$(step ca token app.evil.com --provisioner admin --password-file /root/.step-password \
  --ca-url "$CAURL" --root "$ROOT" 2>/dev/null)
step ca certificate app.evil.com /tmp/evil.crt /tmp/evil.key --token "$TOKEN" \
  --ca-url "$CAURL" --root "$ROOT" --force >/dev/null 2>&1

if [ -f /tmp/evil.crt ]; then
  echo "ÉCHEC : la CA a émis un certificat pour app.evil.com — la politique ne bloque pas."
  rm -f /tmp/evil.crt /tmp/evil.key
  exit 1
fi

exit 0
