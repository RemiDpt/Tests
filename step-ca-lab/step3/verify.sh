#!/bin/bash
if [ -f /root/test.crt ] && step certificate inspect /root/test.crt --short >/dev/null 2>&1; then
  exit 0
fi
echo "Certificat /root/test.crt introuvable ou illisible. Relance la commande d'émission."
exit 1
