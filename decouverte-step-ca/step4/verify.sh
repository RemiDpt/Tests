#!/bin/bash
# Vérifie qu'un certificat SSH utilisateur pour le principal "deploy" a bien été émis.
CERT=""
for d in /root "$PWD" /tmp "$HOME"; do
  if [ -f "$d/id_deploy-cert.pub" ]; then CERT="$d/id_deploy-cert.pub"; break; fi
done
if [ -z "$CERT" ]; then
  echo "id_deploy-cert.pub introuvable (cherché dans /root, dossier courant, /tmp, \$HOME)."
  echo "Lance le bloc 'step ssh certificate ...' de l'étape, puis re-clique sur Check."
  exit 1
fi
OUT=$(ssh-keygen -L -f "$CERT" 2>/dev/null)
if [ $? -ne 0 ]; then
  echo "$CERT n'est pas un certificat SSH lisible."
  exit 1
fi
echo "$OUT" | grep -qi "user certificate" || { echo "Ce n'est pas un certificat SSH *utilisateur*."; exit 1; }
echo "$OUT" | grep -q "deploy" || { echo "Le principal 'deploy' est absent du certificat."; exit 1; }
echo "Certificat SSH utilisateur pour 'deploy' : OK."
exit 0
