#!/bin/bash
if [ -f /root/.step/certs/root_ca.crt ] && [ -f /root/.step/certs/intermediate_ca.crt ]; then
  exit 0
fi
echo "PKI pas encore générée. Lance 'step ca init' et termine l'assistant."
exit 1
