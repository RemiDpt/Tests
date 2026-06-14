# Étape 4 — Limiter les pouvoirs : policy + AppRole

Jusqu'ici, tout passait par le token `root` — pratique en lab, impensable ailleurs. En
vrai, un consommateur (un job CI, un service) reçoit une **identité réduite** : le droit
d'émettre, et **rien d'autre**. Deux briques pour ça : une **policy** (la liste des
permissions) et une **méthode d'auth** (ici **AppRole**, l'identifiant/secret d'une
machine).

D'abord, une policy qui n'autorise **que** l'émission via le rôle `serveur-court` créé à
l'étape 2 :

```
cat > /tmp/issuer.hcl <<'EOF'
path "pki/issue/serveur-court" {
  capabilities = ["create", "update"]
}
EOF
bao policy write issuer /tmp/issuer.hcl
```{{exec}}

Activer AppRole et créer un rôle `runner` porteur de cette seule policy :

```
bao auth enable approle
bao write auth/approle/role/runner token_policies=issuer token_ttl=20m
```{{exec}}

Récupérer les identifiants de la machine (`role_id` stable + `secret_id` jetable), puis
**se connecter** pour obtenir un token réduit :

```
ROLE_ID=$(bao read -field=role_id auth/approle/role/runner/role-id)
SECRET_ID=$(bao write -f -field=secret_id auth/approle/role/runner/secret-id)
CI_TOKEN=$(bao write -field=token auth/approle/login role_id="$ROLE_ID" secret_id="$SECRET_ID")
echo "Token CI obtenu : ${CI_TOKEN:0:12}..."
```{{exec}}

Vérifier le périmètre de ce token : il **peut** émettre, mais **ne peut pas** créer un
nouveau rôle (la 2ᵉ commande doit afficher `permission denied`) :

```
BAO_TOKEN=$CI_TOKEN bao write -format=json pki/issue/serveur-court \
  common_name=ci.lab.local ttl=2m | jq -r .data.serial_number
BAO_TOKEN=$CI_TOKEN bao write pki/roles/pirate allowed_domains=evil.com
```{{exec}}

> C'est tout l'intérêt : dans OpenBao **tout est refusé par défaut**. La policy `issuer`
> n'ouvre qu'un seul chemin ; le token qui en hérite ne sait rien faire d'autre. Compromis
> demain, il n'émet que des certificats `lab.local` courts — et expire en 20 minutes.

Cliquer sur **Check** une fois l'AppRole en place.
