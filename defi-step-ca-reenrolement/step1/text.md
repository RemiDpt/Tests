# Défi 1 — Réenrôler le parc sur la nouvelle AC

L'ancienne racine RSA va expirer. Tous les certificats de `/root/parc/` doivent
**renaître** sous la nouvelle racine ECDSA `/root/new_root.crt` — sans perdre leur
identité. Comme l'algorithme change (RSA → ECDSA), on ne réutilise pas les clés : on en
**régénère une** par service.

## 🚩 Objectif
Produire, pour **chaque** certificat de `/root/parc/`, un certificat équivalent dans
**`/root/parc-new/`** (même nom de fichier : `svcN.crt` / `svcN.key`) qui :
- est **signé par la nouvelle racine** (`/root/new_root.crt` + `/root/new_root.key`) ;
- porte une **nouvelle clé ECDSA** (P-256) ;
- **conserve l'identité d'origine** : même CN **et** exactement les mêmes SAN.

Aucun service ne doit être oublié.

## 🔎 Critère de réussite
Le `verify.sh` vérifie, pour chacun des ~50 services, que le certificat de `parc-new/` :
- se vérifie contre `new_root.crt`, et **ne se vérifie plus** contre `old_root.crt` ;
- porte une clé **EC** ;
- a le **même CN** et le **même ensemble de SAN** que l'original.

Quand `/root/parc-new/` est complet, clique sur **Check**.

---

<details>
<summary>🧩 Indice</summary>

Tu dois lire l'identité de chaque ancien certificat avant de la réécrire :
- `openssl x509 -in svcN.crt -noout -subject` donne le sujet (donc le CN) ;
- `openssl x509 -in svcN.crt -noout -ext subjectAltName` liste les SAN (`DNS:...`) ;
- ou, plus net, `step certificate inspect svcN.crt --format json | jq` te sort tout en
  structuré.

Pour ré-émettre sous la nouvelle racine avec une clé EC :
`step certificate create "<CN>" out.crt out.key --ca new_root.crt --ca-key new_root.key
--kty EC --curve P-256 --san <nom> --no-password --insecure`. Une boucle `for` sur
`/root/parc/svc*.crt` fait le reste.
</details>

<details>
<summary>🧩 Coup de pouce — les pièges du réenrôlement</summary>

1. **Les SAN, pas seulement le CN.** Un `step certificate create "<CN>" ...` sans `--san`
   ne met que le CN. Les services à **plusieurs SAN** (il y en a) perdront leurs autres
   noms, et le `verify` te le dira. Recopie **tous** les `DNS:` d'origine, un `--san`
   chacun.
2. **Une clé par service.** L'algorithme change : tu ne peux pas réutiliser la clé RSA.
   `step certificate create` t'en génère une neuve tant que tu ne lui passes pas de clé
   existante — laisse-le faire, avec `--kty EC`.
3. **Lis l'identité dans le certificat, pas dans le nom de fichier.** `svc12.crt` n'est
   qu'un nom de fichier ; le CN et les SAN sont **dans** le certificat. En vrai, les deux
   divergent souvent — fie-toi au contenu.
</details>

<details>
<summary>🗝️ Solution de référence</summary>

```
mkdir -p /root/parc-new
cd /root/parc
for f in svc*.crt; do
  base="${f%.crt}"
  cn=$(openssl x509 -in "$f" -noout -subject -nameopt RFC2253 \
       | sed -n 's/.*CN=\([^,]*\).*/\1/p')
  sanargs=""
  for s in $(openssl x509 -in "$f" -noout -ext subjectAltName 2>/dev/null \
             | grep -oP 'DNS:\K[^,[:space:]]+'); do
    sanargs="$sanargs --san $s"
  done
  step certificate create "$cn" "/root/parc-new/${base}.crt" "/root/parc-new/${base}.key" \
    --ca /root/new_root.crt --ca-key /root/new_root.key \
    --profile leaf --kty EC --curve P-256 $sanargs \
    --not-after 8760h --no-password --insecure
done
```

**Pourquoi on relit l'identité dans le certificat**

Le réflexe naïf, c'est de fabriquer le nouveau certificat à partir du nom de fichier
(`svc12.crt` → CN `svc12.lab.local`). Ça marche tant que rien ne dépasse, et ça casse le
jour où un certificat porte un CN différent de son nom de fichier ou — surtout —
plusieurs SAN. La seule source de vérité, c'est le **contenu** de l'ancien certificat : on
lit son CN et ses SAN, on les recopie. C'est ce qui sépare un script qui migre 50
certificats de démo d'un script qui migre un vrai parc.

**Pourquoi une nouvelle clé**

Une migration d'algorithme (RSA → ECDSA) **impose** de nouvelles clés : une clé RSA ne
devient pas ECDSA. Et même quand l'algorithme ne change pas, un réenrôlement est l'occasion
idéale de **renouveler les clés** : si l'ancienne racine est compromise, on ne veut surtout
pas traîner les mêmes secrets dans le nouveau parc. `step` génère la paire à la volée — on
ne réimporte jamais l'ancienne clé.
</details>
