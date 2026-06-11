#!/bin/bash
if curl -s http://localhost/ejbca/publicweb/healthcheck/ejbcahealth 2>/dev/null | grep -q ALLOK; then
  exit 0
fi
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^ejbca$'; then
  echo "Le conteneur ejbca tourne mais l'application ne répond pas encore ALLOK."
  echo "EJBCA démarre lentement : attends une minute, puis re-clique sur Check."
  echo "Pour suivre le démarrage : docker logs -f ejbca"
else
  echo "Le conteneur ejbca ne tourne pas. L'installation de l'intro a échoué ou il s'est arrêté."
  echo "Regarde : docker ps -a && docker logs ejbca"
fi
exit 1
