# Étape 5 — Inspecter et comprendre

Un certificat n'est pas une boîte noire : c'est un document lisible, signé, qui
raconte qui il identifie, qui l'a émis et jusqu'à quand il vaut. Ouvrons-le pour de bon.

Lire le contenu réel du certificat émis :

```
step certificate inspect /root/test.crt
```{{exec}}

Points à repérer dans la sortie :
- **Subject / SAN** : `test.lab.local` — l'identité portée par le certificat.
- **Issuer** : l'intermédiaire, pas la racine.
- **Validity** : la période de validité (par défaut 24 h avec step-ca).
- **Public Key Algorithm** : l'algorithme de la clé (ECDSA P-256 par défaut, mais ça
  pourrait tout aussi bien être du RSA — ce n'est pas forcément une courbe elliptique).

Vérifier la chaîne complète contre la racine :

```
step certificate verify /root/test.crt --roots /root/.step/certs/root_ca.crt
```{{exec}}

Aucune sortie = vérification réussie.

---

**Pour aller plus loin** (facultatif) — la validité de 24 h n'est pas un hasard :
step-ca pousse aux certificats à durée de vie courte, qui réduisent la dépendance
à la révocation. C'est exactement l'angle *crypto-agilité* utile pour préparer une
migration post-quantique : plus les certificats sont courts, plus le renouvellement
d'algorithme est rapide à propager.

Émettre un certificat encore plus court :

```
step ca certificate "court.lab.local" court.crt court.key \
  --provisioner admin --provisioner-password-file /root/.step-password \
  --ca-url https://localhost:4443 --root /root/.step/certs/root_ca.crt \
  --not-after 5m
```{{exec}}
