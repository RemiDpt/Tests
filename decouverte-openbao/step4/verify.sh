#!/bin/bash
# Vérifie la mise en place de la policy "issuer" + AppRole "runner".
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root

bao status >/dev/null 2>&1 || { echo "OpenBao ne répond pas. Relance l'étape 1."; exit 1; }

bao auth list 2>/dev/null | grep -q '^approle/' || {
  echo "La méthode d'auth 'approle' n'est pas activée (bao auth enable approle)."; exit 1; }

bao policy read issuer >/dev/null 2>&1 || {
  echo "La policy 'issuer' est absente (bao policy write issuer ...)."; exit 1; }

bao read auth/approle/role/runner >/dev/null 2>&1 || {
  echo "Le rôle AppRole 'runner' n'existe pas (bao write auth/approle/role/runner ...)."; exit 1; }

echo "Policy 'issuer' + AppRole 'runner' : OK."
exit 0
