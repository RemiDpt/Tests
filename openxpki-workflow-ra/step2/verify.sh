#!/bin/bash
# Verify volontairement léger : l'action décisive (soumission) se passe dans l'UI.
if [ -f /root/demandeur.csr ] && openssl req -in /root/demandeur.csr -noout -verify >/dev/null 2>&1; then
  exit 0
fi
echo "CSR /root/demandeur.csr introuvable ou invalide."
echo "Relance le bloc 'openssl req' de l'étape, puis soumets la CSR dans l'interface web."
exit 1
