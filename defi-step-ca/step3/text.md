# Défi 3 — Une politique qui refuse pour de vrai

> ⚠️ **ÉTAPE EN CHANTIER — non validée en live.** Ce défi a d'abord été écrit avec une
> politique au niveau *provisioner*, qui sur un step-ca **auto-hébergé est silencieusement
> ignorée** (les policies par provisioner sont une fonctionnalité hébergée). Corrigé pour
> une politique au niveau **`authority`**, qui elle est appliquée à la signature. À
> reproduire en live (refus effectif d'`app.evil.com`) avant publication.

Une PKI sérieuse ne se contente pas d'émettre : elle **refuse** ce qui sort de son
périmètre. Sur step-ca auto-hébergé, ce verrou se pose au niveau de l'**autorité**
(`authority.policy`) : une liste de noms DNS autorisés, vérifiée **à la signature**.
On veut que la CA n'émette que pour le domaine `lab.local`.

Assure-toi d'abord que la CA tourne *(bloc fourni)* :

```
pgrep -f "step-ca .*ca.json" >/dev/null || nohup step-ca "$(step path)/config/ca.json" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2 && curl -sk https://localhost:4443/health
```{{exec}}

## 🎯 Objectif
1. Contraindre l'**autorité** pour qu'elle n'émette **que** des certificats dont les
   noms DNS sont en `*.lab.local`.
2. Émettre un certificat conforme pour `app.lab.local` dans **`good.crt`**.

## ✅ Critère de réussite
- `good.crt` existe (dossier courant, `/root` ou `/tmp`) et vise `app.lab.local` ;
- la politique **bloque réellement** : le `verify.sh` tentera lui-même d'émettre un
  certificat pour `app.evil.com` — il **doit échouer**. Si la CA l'accepte, le défi
  n'est pas réussi.

Clique sur **Check** quand ta politique est en place et `good.crt` émis.

---

<details>
<summary>🆘 Indice</summary>

La politique vit dans `ca.json` (`$(step path)/config/ca.json`), au niveau de
l'**autorité** (objet `authority`), sous une clé `policy` : `policy.x509.allow.dns`
= liste de motifs DNS autorisés. ⚠️ Une `policy` posée sur une *provisioner* est
ignorée en self-hosted — c'est bien `authority.policy` qu'il faut. Après modification,
**redémarre la CA** pour recharger la config. `jq` est installé.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
CONFIG="$(step path)/config/ca.json"

# Politique X.509 au niveau AUTORITÉ (pas provisioner).
jq '.authority.policy = {"x509":{"allow":{"dns":["*.lab.local"]}}}' \
  "$CONFIG" > /tmp/ca.json && mv /tmp/ca.json "$CONFIG"

# Redémarre la CA pour recharger la config.
pkill -f "step-ca .*ca.json"; sleep 1
nohup step-ca "$CONFIG" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2

# Émet un certificat conforme.
TOKEN=$(step ca token app.lab.local --provisioner admin --password-file /root/.step-password \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt")
step ca certificate app.lab.local good.crt good.key --token "$TOKEN" \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt" --force
```

Pour t'en convaincre, tente toi-même `app.evil.com` : la CA doit refuser de signer
(`step ca certificate` se termine en erreur, aucun fichier produit).

**Pourquoi cette approche.** Une politique transforme une liste blanche de noms en
**règle vérifiée à la signature** : tout nom hors `*.lab.local` est rejeté par la CA
elle-même, sans dépendre de la bonne volonté du demandeur. C'est la différence entre
« je sais que je ne devrais pas » et « je ne peux pas ».

**Sous le capot.** Le token JWK encode bien le nom demandé, mais c'est **la CA, au
moment de signer**, qui confronte chaque nom du certificat à la liste `allow.dns`. Si
un seul nom n'est pas autorisé, elle refuse — d'où l'échec propre côté client.

**Le piège — LE point de ce défi.** Sur un step-ca **auto-hébergé**, une `policy`
posée sur une **provisioner** est **silencieusement ignorée** (c'est une fonctionnalité
de l'offre hébergée). Résultat trompeur : tu crois bloquer, et `app.evil.com` passe
quand même. Le seul niveau réellement appliqué ici est **`authority.policy`** — d'où
la modification de `.authority.policy` et non de la provisioner. Et sans **redémarrage**
de la CA, la nouvelle config n'est pas chargée.
</details>
