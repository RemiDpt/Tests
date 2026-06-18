#!/bin/bash
# Vérifie le réenrôlement : chaque service de /root/parc doit avoir un équivalent dans
# /root/parc-new, signé par la NOUVELLE racine ECDSA, en clé EC, identité préservée.
OLD=/root/parc
NEW=/root/parc-new
OR=/root/old_root.crt
NR=/root/new_root.crt

if [ ! -d "$NEW" ]; then
  echo "/root/parc-new n'existe pas : crée-le et dépose-y les certificats réenrôlés."
  exit 1
fi

extract_cn() {
  openssl x509 -in "$1" -noout -subject -nameopt RFC2253 \
    | sed -n 's/.*CN=\([^,]*\).*/\1/p'
}
extract_sans() {
  openssl x509 -in "$1" -noout -ext subjectAltName 2>/dev/null \
    | grep -oP 'DNS:\K[^,[:space:]]+' | sort -u | tr '\n' ','
}

shopt -s nullglob
count=0
for f in "$OLD"/svc*.crt; do
  count=$((count+1))
  base=$(basename "$f" .crt)
  nf="$NEW/$base.crt"

  if [ ! -f "$nf" ]; then
    echo "Service $base non réenrôlé : $nf manquant. Aucun service ne doit être oublié."
    exit 1
  fi
  # (a) chaîne vers la nouvelle racine
  if ! openssl verify -CAfile "$NR" "$nf" >/dev/null 2>&1; then
    echo "$base : le nouveau certificat ne se vérifie pas contre la nouvelle racine ECDSA ($NR)."
    exit 1
  fi
  # (b) ne chaîne PLUS vers l'ancienne racine
  if openssl verify -CAfile "$OR" "$nf" >/dev/null 2>&1; then
    echo "$base : le nouveau certificat est encore signé par l'ANCIENNE racine. Re-signe-le avec new_root."
    exit 1
  fi
  # (c) clé EC
  if ! openssl x509 -in "$nf" -noout -text | grep -q "id-ecPublicKey"; then
    echo "$base : la clé n'est pas en ECDSA. L'algorithme doit changer (l'ancienne était RSA) : utilise --kty EC."
    exit 1
  fi
  # (d) même CN
  ocn=$(extract_cn "$f"); ncn=$(extract_cn "$nf")
  if [ "$ocn" != "$ncn" ]; then
    echo "$base : le CN a changé ('$ocn' -> '$ncn'). L'identité doit être préservée."
    exit 1
  fi
  # (e) même ensemble de SAN
  osan=$(extract_sans "$f"); nsan=$(extract_sans "$nf")
  if [ "$osan" != "$nsan" ]; then
    echo "$base : les SAN ne correspondent pas. Attendu [$osan], obtenu [$nsan]. Recopie TOUS les SAN d'origine."
    exit 1
  fi
done

if [ "$count" -eq 0 ]; then
  echo "Aucun certificat trouvé dans /root/parc : le setup est-il terminé ?"
  exit 1
fi

echo "OK : $count services réenrôlés sous la nouvelle racine ECDSA, identités préservées."
exit 0
