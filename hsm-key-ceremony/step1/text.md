# Étape 1 — Préparer le HSM

Un HSM ne stocke pas les clés en vrac : il les range dans des **tokens**, des
compartiments isolés, chacun protégé par son propre code PIN. Première étape de toute
cérémonie : créer le token qui accueillera la clé de la CA.

D'abord, repérer le module PKCS#11 de SoftHSM2 (son chemin varie selon la distribution)
et le garder sous la main :

```
export MODULE=$(ls /usr/lib/softhsm/libsofthsm2.so /usr/lib/*/softhsm/libsofthsm2.so 2>/dev/null | head -1)
echo "Module : $MODULE"
```{{exec}}

> ⚠️ **À TESTER EN LIVE** — si `Module :` s'affiche vide, le `.so` est ailleurs.
> Cherche-le : `find / -name 'libsofthsm2.so' 2>/dev/null` et exporte le bon chemin.

Initialiser le token. Les codes PIN sont triviaux ici (lab jetable) — en production,
ils sont longs et détenus séparément par plusieurs personnes :

```
softhsm2-util --init-token --free \
  --label "CA-Root-HSM" --pin 1234 --so-pin 123456
```{{exec}}

> `--free` choisit automatiquement un emplacement (*slot*) libre. Retiens un piège
> classique de SoftHSM2 : après initialisation, le numéro de slot change. On désignera
> donc toujours le token par son **label** (`CA-Root-HSM`), jamais par son numéro.

Vérifier que le token existe :

```
softhsm2-util --show-slots
```{{exec}}

Tu dois voir une ligne `Label: CA-Root-HSM`.

Cliquer sur **Check**.
