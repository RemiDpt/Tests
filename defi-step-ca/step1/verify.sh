#!/bin/bash
# Cherche les trois fichiers ENSEMBLE dans un même dossier (sans supposer lequel) :
# dossier courant, /root, /tmp, home.
DIR=""
for d in "$PWD" /root /tmp "$HOME"; do
  if [ -f "$d/root.crt" ] && [ -f "$d/intermediate.crt" ] && [ -f "$d/leaf.crt" ]; then
    DIR="$d"; break
  fi
done
if [ -z "$DIR" ]; then
  echo "root.crt, intermediate.crt et leaf.crt n'ont pas été trouvés ensemble."
  echo "Cherché dans : le dossier courant, /root, /tmp. Mets les trois dans le même dossier."
  exit 1
fi

# La chaîne complète doit se vérifier : leaf -> intermediate -> root.
if ! openssl verify -CAfile "$DIR/root.crt" -untrusted "$DIR/intermediate.crt" "$DIR/leaf.crt" >/dev/null 2>&1; then
  echo "La chaîne ne se vérifie pas (openssl verify échoue) dans $DIR."
  echo "Vérifie que l'intermédiaire est signé par la racine, et la feuille par l'intermédiaire."
  exit 1
fi

# L'intermédiaire doit être une CA.
if ! openssl x509 -in "$DIR/intermediate.crt" -noout -text | grep -q "CA:TRUE"; then
  echo "intermediate.crt n'est pas marqué CA:TRUE."
  exit 1
fi

# La feuille ne doit PAS être une CA.
if openssl x509 -in "$DIR/leaf.crt" -noout -text | grep -q "CA:TRUE"; then
  echo "leaf.crt est marqué CA:TRUE alors qu'une feuille ne doit pas être une CA."
  exit 1
fi

# La feuille doit concerner www.lab.local (sujet ou SAN).
if ! openssl x509 -in "$DIR/leaf.crt" -noout -text | grep -qi "www.lab.local"; then
  echo "leaf.crt ne concerne pas www.lab.local."
  exit 1
fi

exit 0
