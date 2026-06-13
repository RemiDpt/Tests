#!/bin/bash
if [ -f /root/cert.pem ] && step certificate inspect /root/cert.pem --short >/dev/null 2>&1; then
  exit 0
fi
echo "Certificat /root/cert.pem introuvable ou illisible."
echo "Enchaîne les deux blocs de l'étape DANS LE MÊME terminal : le token (variable \$TOKEN)"
echo "doit encore être en mémoire quand tu lances 'step ca certificate'."
echo "Vérifie aussi que la CA répond : curl -sk https://localhost:4443/health"
exit 1
