#!/bin/bash
if [ -f /root/.step/certs/root_ca.crt ] && [ -f /root/.step/certs/intermediate_ca.crt ]; then
  exit 0
fi
echo "PKI pas encore générée : /root/.step/certs/root_ca.crt introuvable."
echo "Lance le bloc 'step ca init ...' de l'étape, puis re-clique sur Check."
exit 1
