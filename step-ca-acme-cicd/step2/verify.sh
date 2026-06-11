#!/bin/bash
if curl -sk https://localhost:4443/acme/acme/directory 2>/dev/null | grep -qi 'newOrder'; then
  exit 0
fi
if curl -sk https://localhost:4443/health 2>/dev/null | grep -q '"status":"ok"'; then
  echo "La CA répond, mais pas l'endpoint ACME. La provisioner ACME a-t-elle été ajoutée AVANT le démarrage ?"
  echo "Si besoin : pkill step-ca, puis redémarre la CA (bloc de l'étape 2)."
else
  echo "La CA ne répond pas. Démarre-la : step-ca \$(step path)/config/ca.json --password-file /root/.step-password &"
fi
exit 1
