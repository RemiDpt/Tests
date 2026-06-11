#!/bin/bash
if [ ! -f /root/serveur1.p12 ]; then
  echo "Keystore /root/serveur1.p12 introuvable."
  echo "Enchaîne les trois blocs de l'étape : addendentity + setclearpwd, batch, puis docker cp."
  exit 1
fi
if openssl pkcs12 -in /root/serveur1.p12 -passin pass:LabPKI-non-securise -nokeys >/dev/null 2>&1; then
  exit 0
fi
echo "/root/serveur1.p12 présent mais illisible avec le mot de passe du lab."
echo "Recommence l'enrôlement : l'étape 'ra setclearpwd' a peut-être été sautée avant le batch."
exit 1
