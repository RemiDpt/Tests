#!/bin/bash
if [ -f /etc/letsencrypt/live/ci-runner.lab.local/fullchain.pem ]; then
  exit 0
fi
echo "Certificat non obtenu. Si certbot échoue sur le challenge, c'est le port 80 :"
echo "vérifie que rien d'autre n'écoute dessus et que la CA tourne."
exit 1
