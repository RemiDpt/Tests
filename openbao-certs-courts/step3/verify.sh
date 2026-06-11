#!/bin/bash
if [ -f /root/app.crt ] && openssl x509 -in /root/app.crt -noout >/dev/null 2>&1; then
  exit 0
fi
echo "Certificat /root/app.crt introuvable ou illisible."
echo "Relance le bloc 'bao write ... pki/issue/serveur-court' de l'étape."
echo "(OpenBao doit tourner : bao status — et le rôle doit exister, étape 2.)"
exit 1
