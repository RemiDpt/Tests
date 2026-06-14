# Défi 1 — Hiérarchie à trois niveaux (hors-ligne)

Pas besoin du serveur CA ici : l'outil `step certificate` sait créer et signer des
certificats directement, sur le disque. Idéal pour bien voir la mécanique d'une chaîne.

## 🎯 Objectif
Construire une **chaîne à trois niveaux** (les trois certificats dans un **même
dossier** ; le vérificateur les cherche dans ton dossier courant, `/root` ou `/tmp`) :

| Fichier | Rôle | Contrainte |
|---|---|---|
| `root.crt` / `root.key` | racine auto-signée | doit être une **CA** |
| `intermediate.crt` / `intermediate.key` | intermédiaire | **CA**, signée par la racine |
| `leaf.crt` / `leaf.key` | feuille | **pas** une CA, pour `www.lab.local` |

## ✅ Critère de réussite
- `openssl verify -CAfile root.crt -untrusted intermediate.crt leaf.crt` réussit ;
- `intermediate.crt` porte `CA:TRUE`, `leaf.crt` non ;
- `leaf.crt` concerne bien `www.lab.local`.

Quand tes trois fichiers sont là, clique sur **Check**.

---

<details>
<summary>🆘 Indice</summary>

`step certificate create` accepte un **profil** : `--profile root-ca`,
`--profile intermediate-ca`, `--profile leaf`. Pour signer un certificat par un
autre, on lui passe l'émetteur avec `--ca` et `--ca-key`. Pour un lab sans
passphrase sur les clés : `--no-password --insecure`.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
step certificate create "Defi Root" root.crt root.key \
  --profile root-ca --no-password --insecure

step certificate create "Defi Intermediate" intermediate.crt intermediate.key \
  --profile intermediate-ca --ca root.crt --ca-key root.key \
  --no-password --insecure

step certificate create www.lab.local leaf.crt leaf.key \
  --profile leaf --ca intermediate.crt --ca-key intermediate.key \
  --no-password --insecure

openssl verify -CAfile root.crt -untrusted intermediate.crt leaf.crt
```

**Pourquoi on monte la chaîne à la main**

Tout se joue dans le `--profile`. Plutôt que d'aller écrire à la main des extensions
X.509 obscures, tu choisis un rôle et `step` pose les bonnes contraintes pour toi :
`root-ca` sort un certificat auto-signé marqué `CA:TRUE`, `intermediate-ca` reste une
CA mais signée par un parent, et `leaf` n'est surtout pas une CA — elle reçoit les
usages d'un certificat serveur classique. C'est la hiérarchie qu'on retrouve dans
n'importe quelle boîte : une racine maison, puis une intermédiaire **par usage** — une
pour les serveurs web, une pour le VPN, une pour la signature de code — et des milliers
de feuilles en bout de chaîne.

**Qui signe qui**

`--ca` et `--ca-key`, c'est juste « avec quelle autorité je signe ce certificat ». La
racine signe l'intermédiaire, l'intermédiaire signe la feuille. À la vérification,
`-untrusted` tend à OpenSSL le maillon du milieu pour qu'il rebâtisse le chemin
feuille → intermédiaire → racine ; la seule vraie ancre de confiance, c'est la racine
passée à `-CAfile`. Ton navigateur fait exactement ce raisonnement à chaque connexion
HTTPS.

**Le piège à éviter**

Ne signe jamais une feuille directement avec la racine. Dans une vraie PKI, la racine
ne signe que des intermédiaires, et le reste du temps elle dort hors-ligne, parfois
dans un coffre. Une racine compromise, c'est toute la PKI à reconstruire et à
redistribuer sur chaque poste du parc — le genre d'incident qui occupe une équipe
sécurité pendant des semaines. Respecte aussi l'ordre : racine, puis intermédiaire,
puis feuille — chaque niveau a besoin de celui du dessus pour être signé.
</details>
