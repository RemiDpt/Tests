#!/bin/bash
if [ -f /root/test.crt ] && step certificate inspect /root/test.crt --short >/dev/null 2>&1; then
  exit 0
fi
echo "Certificat /root/test.crt introuvable ou illisible."
echo "Vérifie que la CA répond (curl -sk https://localhost:4443/health), puis relance le bloc d'émission de l'étape."
exit 1
