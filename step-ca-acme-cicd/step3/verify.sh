#!/bin/bash
if [ -f /etc/letsencrypt/live/ci-runner.lab.local/fullchain.pem ]; then
  exit 0
fi
echo "Certificat non obtenu. Causes fréquentes :"
echo " - la CA ne tourne pas (curl -sk https://localhost:4443/health) ;"
echo " - le port 80 est occupé (certbot --standalone en a besoin) ;"
grep -q ci-runner.lab.local /etc/hosts || echo " - entrée /etc/hosts manquante : echo '127.0.0.1 ci-runner.lab.local' >> /etc/hosts"
exit 1
