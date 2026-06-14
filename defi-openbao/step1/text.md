# Défi 1 — Un rôle qui refuse hors de son périmètre

Dans OpenBao, la politique d'émission vit dans le **rôle** PKI : quels domaines, quelle
durée maximale. Un bon rôle ne fait pas qu'autoriser — il **refuse** tout le reste.

Bloc fourni — démarre OpenBao et monte la PKI de base *(ce n'est pas le défi)* :

```
pgrep -x bao >/dev/null || (bao server -dev -dev-root-token-id=root >/var/log/bao.log 2>&1 &)
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root
sleep 2
bao secrets list | grep -q '^pki/' || bao secrets enable pki
bao secrets tune -max-lease-ttl=24h pki
bao read pki/cert/ca >/dev/null 2>&1 || bao write -field=certificate pki/root/generate/internal common_name="OpenBao Defi CA" ttl=24h > /root/ca_openbao.crt
echo "PKI prête."
```{{exec}}

## 🎯 Objectif
Créer un rôle PKI nommé **`prod`** qui :
- n'autorise que le domaine **`lab.local`** (et ses sous-domaines) ;
- plafonne la durée de vie à **1 heure maximum**.

## ✅ Critère de réussite
Le `verify.sh` teste le comportement réel du rôle :
- `app.lab.local` **s'émet** ;
- `app.evil.com` est **refusé** ;
- une demande à `24h` est **plafonnée** à ≤ 1 h (ou refusée).

Clique sur **Check** quand le rôle `prod` est en place.

---

<details>
<summary>🆘 Indice</summary>

Un rôle se crée avec `bao write pki/roles/<nom> …`. Les paramètres qui t'intéressent :
`allowed_domains`, `allow_subdomains`, `max_ttl` (et `ttl` pour la valeur par défaut).
</details>

<details>
<summary>✅ Solution de référence</summary>

```
bao write pki/roles/prod \
  allowed_domains=lab.local allow_subdomains=true \
  ttl=15m max_ttl=1h
```

Vérifie toi-même :

```
bao write -format=json pki/issue/prod common_name=app.lab.local ttl=10m | jq -r .data.serial_number
bao write pki/issue/prod common_name=app.evil.com ttl=10m   # doit échouer
```

**Pourquoi la règle vit dans le rôle**

Chez OpenBao, la politique d'émission n'est pas dans la CA mais dans le **rôle** : c'est
lui qui tranche quels noms et quelles durées sont permis. Un même moteur PKI peut donc
exposer plusieurs rôles aux contraintes très différentes — un rôle `serveurs-internes`
plafonné à `lab.local`, un rôle `clients-vpn` pour les certificats utilisateurs, un rôle
`ci` ultra-court. Chaque équipe tape sur son rôle, et personne ne déborde sur le
périmètre des autres.

**Un plafond, pas une suggestion**

`allowed_domains` + `allow_subdomains` fixent les noms acceptés ; `max_ttl` est un
plafond appliqué côté serveur. Demander `ttl=24h` ne déclenche pas forcément d'erreur :
OpenBao **rabote** simplement la durée à `max_ttl`. La contrainte est donc bien vérifiée
à l'émission, ce n'est pas qu'un vœu pieux dans la doc.

**Le piège**

Sans `allow_subdomains=true`, `lab.local` autoriserait le domaine nu mais pas
`app.lab.local` — et tu passerais dix minutes à te demander pourquoi ça refuse. Pire
dans l'autre sens : un rôle qui oublie `allowed_domains` (ou qui pose
`allow_any_name=true`) signe **n'importe quoi**. C'est l'erreur de config qui ouvre la
PKI en grand, et le genre de ligne qu'on retrouve, penaud, en post-mortem.
</details>
