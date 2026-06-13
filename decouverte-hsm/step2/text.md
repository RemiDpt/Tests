# Étape 2 — Générer la clé de CA dans le HSM

Voici le geste central de la cérémonie. On ne génère **pas** la clé sur le disque pour
l'importer ensuite : on demande au HSM de la **fabriquer lui-même, à l'intérieur**.
Dès cet instant, la clé privée existe quelque part où personne ne pourra la lire.

Si tu as changé de terminal depuis l'étape 1, ré-exporte le module :

```
export MODULE=$(ls /usr/lib/softhsm/libsofthsm2.so /usr/lib/*/softhsm/libsofthsm2.so 2>/dev/null | head -1)
```{{exec}}

Générer la paire de clés RSA 3072 directement dans le token :

```
pkcs11-tool --module $MODULE --token-label "CA-Root-HSM" --login --pin 1234 \
  --keypairgen --key-type rsa:3072 \
  --label "ca-root-key" --id 01
```{{exec}}

> ⚠️ **À TESTER EN LIVE** — `pkcs11-tool` vient du paquet `opensc`. La désignation du
> token par `--token-label` évite le piège du numéro de slot. Si la génération échoue,
> vérifie le PIN (`1234`) et le label du token (`CA-Root-HSM`).

Lister les objets du token : tu dois voir une clé **privée** et une clé **publique**,
toutes deux étiquetées `ca-root-key` :

```
pkcs11-tool --module $MODULE --token-label "CA-Root-HSM" --login --pin 1234 \
  --list-objects
```{{exec}}

La clé privée est là, référencée — mais déjà, tu ne peux en voir que les *métadonnées*
(type, label, identifiant), jamais la valeur. On va le prouver à l'étape suivante.

Cliquer sur **Check**.
