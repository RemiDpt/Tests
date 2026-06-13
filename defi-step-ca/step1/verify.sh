#!/bin/bash
cd /root || exit 1
for f in root.crt intermediate.crt leaf.crt; do
  [ -f "$f" ] || { echo "Fichier manquant : $f"; exit 1; }
done

# La chaîne complète doit se vérifier : leaf -> intermediate -> root.
if ! openssl verify -CAfile root.crt -untrusted intermediate.crt leaf.crt >/dev/null 2>&1; then
  echo "La chaîne ne se vérifie pas (openssl verify échoue)."
  echo "Vérifie que l'intermédiaire est bien signé par la racine, et la feuille par l'intermédiaire."
  exit 1
fi

# L'intermédiaire doit être une CA.
if ! openssl x509 -in intermediate.crt -noout -text | grep -q "CA:TRUE"; then
  echo "intermediate.crt n'est pas marqué CA:TRUE."
  exit 1
fi

# La feuille ne doit PAS être une CA.
if openssl x509 -in leaf.crt -noout -text | grep -q "CA:TRUE"; then
  echo "leaf.crt est marqué CA:TRUE alors qu'une feuille ne doit pas être une CA."
  exit 1
fi

# La feuille doit concerner www.lab.local (sujet ou SAN).
if ! openssl x509 -in leaf.crt -noout -text | grep -qi "www.lab.local"; then
  echo "leaf.crt ne concerne pas www.lab.local."
  exit 1
fi

exit 0
