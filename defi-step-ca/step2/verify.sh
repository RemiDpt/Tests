#!/bin/bash
CERT=/root/id_deploy-cert.pub
[ -f "$CERT" ] || { echo "Certificat SSH introuvable : $CERT"; exit 1; }

INFO=$(ssh-keygen -L -f "$CERT" 2>/dev/null)
if [ -z "$INFO" ]; then
  echo "$CERT n'est pas un certificat SSH lisible (ssh-keygen -L échoue)."
  exit 1
fi

# Doit être un certificat UTILISATEUR (pas host).
if ! echo "$INFO" | grep -qi "Type:.*user certificate"; then
  echo "Ce certificat n'est pas de type 'user' (attendu : certificat SSH utilisateur)."
  echo "$INFO" | grep -i "Type:"
  exit 1
fi

# Doit porter le principal 'deploy'.
if ! echo "$INFO" | grep -qi "deploy"; then
  echo "Le principal 'deploy' n'apparaît pas dans le certificat."
  exit 1
fi

exit 0
