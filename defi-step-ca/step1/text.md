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

**Pourquoi cette approche.** Tout se joue dans le `--profile` : il encode les
contraintes que tu n'as pas à écrire à la main. `root-ca` produit un certificat
**auto-signé** marqué `CA:TRUE` ; `intermediate-ca` est aussi une CA, mais signée par
un parent ; `leaf` n'est **pas** une CA et reçoit les usages d'un certificat serveur.

**Sous le capot.** `--ca`/`--ca-key` désignent le **signataire** : l'intermédiaire est
signé par la racine, la feuille par l'intermédiaire. Côté vérification, `-untrusted`
fournit à OpenSSL le maillon intermédiaire pour qu'il **reconstruise la chaîne**
feuille → intermédiaire → racine ; seule la racine est une ancre de confiance (`-CAfile`).

**Le piège.** Ne signe **jamais la feuille directement par la racine** : dans une vraie
PKI la racine ne signe que des intermédiaires et reste hors-ligne. Et respecte l'ordre
de création (racine, puis intermédiaire, puis feuille) — chaque niveau a besoin du
précédent pour être signé.
</details>
