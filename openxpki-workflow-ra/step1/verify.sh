#!/bin/bash
cd /root/openxpki-docker 2>/dev/null || { echo "Dossier /root/openxpki-docker introuvable : l'installation de l'intro a échoué."; exit 1; }
CODE=$(curl -sk -o /dev/null -w '%{http_code}' https://localhost:8443/webui/index/ 2>/dev/null)
if [ "$CODE" = "200" ]; then
  exit 0
fi
echo "L'interface ne répond pas (code HTTP : ${CODE:-aucun})."
echo "Regarde l'état des services : cd /root/openxpki-docker && docker compose ps"
echo "Si un service n'est pas 'healthy', attends une minute puis re-clique sur Check."
exit 1
