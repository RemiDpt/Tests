#!/bin/bash
# Cherche un certificat SSH UTILISATEUR portant le principal 'deploy', sans supposer
# le chemin ni le nom de la clé : tout fichier *-cert.pub des dossiers candidats.
FOUND=""
for d in "$PWD" /root /tmp "$HOME"; do
  for f in "$d"/*-cert.pub; do
    [ -f "$f" ] || continue
    INFO=$(ssh-keygen -L -f "$f" 2>/dev/null) || continue
    if echo "$INFO" | grep -qi "Type:.*user certificate" && echo "$INFO" | grep -qi "deploy"; then
      FOUND="$f"; break 2
    fi
  done
done

if [ -z "$FOUND" ]; then
  echo "Aucun certificat SSH *utilisateur* portant le principal 'deploy' n'a été trouvé."
  echo "Cherché : *-cert.pub dans le dossier courant, /root, /tmp."
  echo "Émets-le (ex. dans /root/id_deploy-cert.pub) puis relance Check."
  exit 1
fi

exit 0
