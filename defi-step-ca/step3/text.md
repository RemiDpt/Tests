# Défi 3 — Une politique qui refuse pour de vrai

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

**Pourquoi une politique, et pas juste de la discipline**

Une politique transforme ta liste blanche de noms en règle vérifiée au moment de la
signature. Tout nom en dehors de `*.lab.local` est refusé par la CA elle-même, peu
importe ce que demande le client. C'est toute la différence entre « je sais que je ne
devrais pas émettre ça » et « je ne peux pas ». En entreprise, c'est ce qui empêche une
CA interne de signer un jour, par erreur ou par malveillance, un certificat pour
`paypal.com` ou pour le domaine d'un concurrent — un certificat techniquement valide
qui ferait des dégâts. C'est d'ailleurs pour ça que les autorités publiques imposent
des *name constraints* aux sous-CA qu'elles délèguent à des entreprises.

**Ce qui se passe à la signature**

Le token JWK encode bien le nom demandé, mais c'est la CA, au moment de signer, qui
confronte chaque nom du certificat à la liste `allow.dns`. Un seul nom non autorisé, et
elle refuse en bloc — d'où l'échec propre côté client.

**Le piège, et c'est tout le sujet du défi**

Sur un step-ca auto-hébergé, une `policy` posée sur une **provisioner** est
silencieusement ignorée : c'est une fonctionnalité réservée à l'offre hébergée payante.
Le résultat est sournois — tu crois avoir verrouillé, et `app.evil.com` passe quand
même, sans le moindre avertissement. Le seul niveau réellement appliqué ici, c'est
`authority.policy` : d'où la modif de `.authority.policy` et pas de la provisioner. Et
tant que tu n'as pas redémarré la CA, la nouvelle config n'est pas chargée. C'est
typiquement le genre de fausse sécurité qui passe une revue d'archi et ressort six mois
plus tard, en plein audit.
</details>
