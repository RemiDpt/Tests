#!/bin/bash
# Verify volontairement léger : l'approbation se passe dans l'UI ; on contrôle le
# certificat rapatrié côté terminal.
if [ ! -f /root/demandeur.crt ]; then
  echo "Certificat /root/demandeur.crt introuvable."
  echo "Après approbation dans l'UI, copie le PEM dans le fichier (bloc 'cat > /root/demandeur.crt' de l'étape)."
  exit 1
fi
if ! openssl x509 -in /root/demandeur.crt -noout >/dev/null 2>&1; then
  echo "/root/demandeur.crt n'est pas un certificat PEM valide. Recopie le bloc complet, lignes BEGIN/END comprises."
  exit 1
fi
if ! openssl x509 -in /root/demandeur.crt -noout -issuer 2>/dev/null | grep -qi 'openxpki'; then
  echo "Le certificat n'a pas été émis par la CA OpenXPKI de démo. As-tu copié le bon PEM ?"
  exit 1
fi
exit 0
