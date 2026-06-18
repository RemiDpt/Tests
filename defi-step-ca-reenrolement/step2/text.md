# Défi 2 — Ne réenrôle pas les services hors-service

Migrer, c'est bien. Migrer **n'importe quoi**, c'est un trou de sécurité. Une partie des
services du parc sont **hors-service** : les réenrôler reviendrait à redonner un
certificat valide tout neuf à des machines qu'on a débranchées. La liste est dans
`/root/parc/decommissionnes.txt`.

Tu repars de ta migration du Défi 1 (`/root/parc-new/`).

## 🚩 Objectif
1. Faire en sorte que les services listés dans `decommissionnes.txt` **ne soient plus**
   présents dans `/root/parc-new/` (ni `.crt` ni `.key`).
2. Garder tous les **autres** services migrés et valides sous la nouvelle racine.
3. Produire un **rapport** `/root/migration-report.csv` avec l'en-tête `service,statut`,
   une ligne par service, statut `migré` ou `exclu-decommissionne`.

## 🔎 Critère de réussite
Le `verify.sh` vérifie que :
- chaque service décommissionné est **absent** de `parc-new/` **et** marqué
  `exclu-decommissionne` dans le rapport ;
- chaque autre service est **présent**, se vérifie contre `new_root.crt`, **et** marqué
  `migré` dans le rapport.

Clique sur **Check** quand le parc et le rapport sont cohérents.

---

<details>
<summary>🧩 Indice</summary>

Deux briques. D'abord **retirer** de `parc-new/` les services de la liste : une boucle
`while read svc; do rm -f /root/parc-new/$svc.crt /root/parc-new/$svc.key; done <
/root/parc/decommissionnes.txt`. Ensuite **générer le rapport** : parcours
`/root/parc/svc*.crt`, et pour chaque service teste s'il est dans la liste
(`grep -qx "$base" /root/parc/decommissionnes.txt`) pour écrire le bon statut.
</details>

<details>
<summary>🧩 Coup de pouce — la cohérence parc ↔ rapport</summary>

1. **Le rapport doit refléter le parc, pas l'inverse.** Un service marqué `migré` mais
   absent de `parc-new/` (ou le contraire) fera échouer le `verify`. Décide d'abord ce qui
   est exclu, applique-le aux **fichiers** *et* au **CSV**.
2. **`grep -qx`** matche la **ligne entière** : `svc6` ne matchera pas `svc60`. C'est
   exactement ce qu'il te faut pour comparer un nom de service à la liste.
3. **L'en-tête compte.** La première ligne du CSV doit être `service,statut` ; les
   suivantes `svcN,migré` ou `svcN,exclu-decommissionne`.
</details>

<details>
<summary>🗝️ Solution de référence</summary>

```
# 1) Retirer les services hors-service de la migration
while read -r svc; do
  [ -z "$svc" ] && continue
  rm -f "/root/parc-new/$svc.crt" "/root/parc-new/$svc.key"
done < /root/parc/decommissionnes.txt

# 2) Rapport de migration
echo "service,statut" > /root/migration-report.csv
for f in /root/parc/svc*.crt; do
  base=$(basename "$f" .crt)
  if grep -qx "$base" /root/parc/decommissionnes.txt; then
    echo "$base,exclu-decommissionne" >> /root/migration-report.csv
  else
    echo "$base,migré" >> /root/migration-report.csv
  fi
done

# Coup d'œil
column -t -s, /root/migration-report.csv | head
```

**Pourquoi exclure plutôt que tout migrer**

Réenrôler un service décommissionné, c'est lui refabriquer une identité valide pour un ou
deux ans. Si la machine a été débranchée mais pas nettoyée, ou si quelqu'un récupère son
ancienne clé, tu viens de rouvrir une porte que l'expiration de l'ancienne AC allait
fermer toute seule. Une migration propre est **réconciliée** avec l'inventaire : on ne
migre que ce qui est encore en service.

**Pourquoi un rapport**

Une rotation d'AC est un évènement qu'on doit pouvoir **prouver**. Le CSV, c'est la trace
que tu présentes : combien de certificats migrés, lesquels volontairement laissés de côté
et pourquoi. Le jour d'un audit — ou d'un incident où un service tombe parce que son
certificat n'a pas suivi — c'est ce fichier qui répond à « qu'est-ce qui a été fait, et
sur quoi ».
</details>
