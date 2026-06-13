#!/bin/bash
cd /root/openxpki-docker 2>/dev/null || { echo "Dossier /root/openxpki-docker introuvable : l'installation de l'intro a échoué."; exit 1; }

# 1) Le service OpenXPKI doit répondre en interne (HTTPS direct).
CODE_TLS=$(curl -sk -o /dev/null -w '%{http_code}' https://localhost:8443/webui/index/ 2>/dev/null)
if [ "$CODE_TLS" != "200" ]; then
  echo "L'interface OpenXPKI ne répond pas encore (code HTTP : ${CODE_TLS:-aucun})."
  echo "Regarde l'état des services : cd /root/openxpki-docker && docker-compose ps"
  echo "Si un service n'est pas 'healthy', attends une minute puis re-clique sur Check."
  exit 1
fi

# 2) Le pont HTTP->HTTPS (socat) doit répondre : c'est lui que le lien Killercoda emprunte.
CODE_BRIDGE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8888/webui/index/ 2>/dev/null)
if [ -z "$CODE_BRIDGE" ] || [ "$CODE_BRIDGE" = "000" ]; then
  echo "Le pont HTTP->HTTPS (port 8888) ne répond pas : as-tu lancé le bloc 'socat' de l'étape ?"
  echo "Relance-le : nohup socat TCP-LISTEN:8888,fork,reuseaddr OPENSSL-CONNECT:127.0.0.1:8443,verify=0 >/tmp/socat-openxpki.log 2>&1 &"
  exit 1
fi

exit 0
