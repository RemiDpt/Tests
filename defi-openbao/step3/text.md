# Défi 3 — AppRole : un token CI au pouvoir limité

Un runner CI ne doit pas se promener avec le token `root`. Le bon modèle :
une **policy** minimale (juste émettre), une méthode d'auth **AppRole** (role-id +
secret-id, comme un identifiant/mot de passe de machine), et un **token** qui n'a le
droit de rien faire d'autre.

Bloc fourni — réexporte l'accès *(OpenBao tourne déjà)* :

```
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root
bao status >/dev/null 2>&1 && echo "OpenBao OK" || echo "Relance le bloc fourni du Défi 1."
```{{exec}}

## 🎯 Objectif
1. Mettre en place l'auth **AppRole** et une policy qui autorise **uniquement**
   l'émission via `pki/issue/prod`.
2. Créer un rôle AppRole, récupérer ses identifiants, **te connecter** pour obtenir un
   token, et l'écrire dans **`/root/ci_token.txt`**.

## ✅ Critère de réussite
Le `verify.sh` utilise **ton** token (pas root) et vérifie :
- qu'il **peut** émettre via `pki/issue/prod` ;
- qu'il **ne peut pas** créer un nouveau rôle (`pki/roles/…`) ni agir hors de sa policy.

Clique sur **Check** quand le token est en place.

---

<details>
<summary>🆘 Indice</summary>

Active la méthode : `bao auth enable approle`. Une policy est un fichier HCL avec des
blocs `path "…" { capabilities = [...] }` — ici un seul chemin, `pki/issue/prod`, en
`create`/`update`. Le rôle AppRole se crée avec `bao write auth/approle/role/<nom>
token_policies=<policy>`. Tu récupères ensuite `role-id` et `secret-id`, puis tu fais
`bao write auth/approle/login role_id=… secret_id=…` pour obtenir un token.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
bao auth enable approle

cat > /tmp/ci.hcl <<'EOF'
path "pki/issue/prod" {
  capabilities = ["create", "update"]
}
EOF
bao policy write ci /tmp/ci.hcl

bao write auth/approle/role/runner token_policies=ci token_ttl=20m

ROLE_ID=$(bao read -field=role_id auth/approle/role/runner/role-id)
SECRET_ID=$(bao write -f -field=secret_id auth/approle/role/runner/secret-id)
TOKEN=$(bao write -field=token auth/approle/login role_id="$ROLE_ID" secret_id="$SECRET_ID")
echo "$TOKEN" > /root/ci_token.txt
echo "Token AppRole enregistré."
```

**Pourquoi cette approche.** Un runner CI ne doit jamais détenir le token `root`. Le
bon modèle : une **policy** minimale (juste émettre), une identité de **machine**
(AppRole = `role_id` public + `secret_id` secret, comme login/mot de passe), et un
**token** dérivé qui n'a que les droits de la policy.

**Sous le capot.** Dans OpenBao, **tout est refusé par défaut** : la policy `ci`
n'ouvre QUE `pki/issue/prod`. Le `role_id`/`secret_id` servent à se **connecter**
(`approle/login`), ce qui renvoie un token court porteur de cette seule policy. C'est
ce token-là que le runner utilise — révocable et limité dans le temps (`token_ttl`).

**Le piège.** Ne confonds pas les identifiants : `role_id` est l'identifiant stable du
rôle, `secret_id` est le secret jetable. Et la policy n'autorise que `create`/`update`
sur **un seul chemin** : si tu y ajoutes `pki/roles/*` ou `sys/*`, tu redonnes au runner
le pouvoir que tout ce dispositif cherche justement à lui retirer.
</details>
