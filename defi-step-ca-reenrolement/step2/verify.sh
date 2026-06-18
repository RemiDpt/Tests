#!/bin/bash
# Vérifie l'exclusion des services hors-service + la cohérence du rapport de migration.
OLD=/root/parc
NEW=/root/parc-new
NR=/root/new_root.crt
LIST=/root/parc/decommissionnes.txt
REPORT=/root/migration-report.csv

[ -f "$LIST" ]   || { echo "decommissionnes.txt introuvable : le setup est-il terminé ?"; exit 1; }
[ -f "$REPORT" ] || { echo "Rapport /root/migration-report.csv manquant : produis-le (colonnes 'service,statut')."; exit 1; }

# En-tête attendu.
if ! head -n1 "$REPORT" | grep -qx "service,statut"; then
  echo "La première ligne du rapport doit être exactement : service,statut"
  exit 1
fi

# 1) Les services décommissionnés : absents de parc-new ET marqués exclus dans le rapport.
while read -r svc; do
  [ -z "$svc" ] && continue
  if [ -f "$NEW/$svc.crt" ] || [ -f "$NEW/$svc.key" ]; then
    echo "$svc est décommissionné mais encore présent dans parc-new : il ne doit PAS être réenrôlé."
    exit 1
  fi
  if ! grep -qi "^$svc,.*exclu" "$REPORT"; then
    echo "Le rapport ne marque pas $svc comme exclu (attendu : '$svc,exclu-decommissionne')."
    exit 1
  fi
done < "$LIST"

# 2) Tous les autres services : présents, valides sous new_root, et marqués migrés.
shopt -s nullglob
for f in "$OLD"/svc*.crt; do
  base=$(basename "$f" .crt)
  grep -qx "$base" "$LIST" && continue   # décommissionné : déjà traité au-dessus
  nf="$NEW/$base.crt"
  if [ ! -f "$nf" ]; then
    echo "$base n'est pas décommissionné mais $nf manque : il devrait être migré."
    exit 1
  fi
  if ! openssl verify -CAfile "$NR" "$nf" >/dev/null 2>&1; then
    echo "$base : son certificat ne se vérifie pas contre la nouvelle racine."
    exit 1
  fi
  if ! grep -qi "^$base,.*migr" "$REPORT"; then
    echo "Le rapport ne marque pas $base comme migré (attendu : '$base,migré')."
    exit 1
  fi
done

echo "OK : services hors-service exclus, parc actif migré, rapport conforme."
exit 0
