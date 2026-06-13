#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200

# Localise le token sans supposer le dossier.
TFILE=""
for d in "$PWD" /root /tmp "$HOME"; do
  [ -f "$d/ci_token.txt" ] && { TFILE="$d/ci_token.txt"; break; }
done
if [ -z "$TFILE" ]; then
  echo "ci_token.txt introuvable (cherché dans le dossier courant, /root, /tmp)."
  echo "Sauve le token obtenu par le login AppRole dans ci_token.txt."
  exit 1
fi
T=$(tr -d ' \t\r\n' < "$TFILE")
[ -n "$T" ] || { echo "$TFILE est vide."; exit 1; }
[ "$T" = "root" ] && { echo "C'est le token root, pas un token AppRole. Utilise le token issu du login AppRole."; exit 1; }

# 1) Le token doit POUVOIR émettre via pki/issue/prod.
if ! BAO_TOKEN="$T" bao write -format=json pki/issue/prod common_name=ci.lab.local ttl=10m >/dev/null 2>&1; then
  echo "Le token AppRole ne peut pas émettre via pki/issue/prod."
  echo "La policy est-elle bien liée au rôle, et le rôle 'prod' existe-t-il (Défi 1) ?"
  exit 1
fi

# 2) Le token ne doit PAS pouvoir créer un rôle (hors de sa policy).
if BAO_TOKEN="$T" bao write pki/roles/hack allowed_domains=evil.com allow_any_name=true >/dev/null 2>&1; then
  echo "ÉCHEC : le token AppRole a pu créer un rôle PKI — la policy n'est pas restreinte à l'émission."
  exit 1
fi

exit 0
