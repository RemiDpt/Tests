# Défi 4 — Intermédiaire signée par une racine externe

En vrai, OpenBao est rarement la racine : il héberge une **intermédiaire** signée par
une racine d'entreprise gardée hors-ligne. Le mécanisme : OpenBao génère une **CSR**,
une autorité externe la **signe**, puis on réimporte le certificat signé. À toi de
reconstituer cette chaîne, avec une racine OpenSSL dans le rôle de l'autorité externe.

Bloc fourni — réexporte l'accès *(OpenBao tourne déjà)* :

```
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root
bao status >/dev/null 2>&1 && echo "OpenBao OK" || echo "Relance le bloc fourni du Défi 1."
```{{exec}}

## 🎯 Objectif
1. Créer une **racine externe** (OpenSSL) dans `/root/ext_root.crt` (+ sa clé).
2. Monter un moteur PKI **intermédiaire** sur le chemin **`pki_int`**, lui faire
   générer une **CSR**, la **signer** avec la racine externe, puis **réimporter** le
   certificat signé (`set-signed`).
3. Créer un rôle **`leaf`** sur `pki_int` (domaine `lab.local`) capable d'émettre.

## ✅ Critère de réussite
Le `verify.sh` vérifie que :
- le certificat de CA de `pki_int` est **signé par** `/root/ext_root.crt` ;
- un certificat émis par `pki_int/issue/leaf` **se vérifie** jusqu'à la racine externe.

Clique sur **Check** quand la chaîne est complète.

---

<details>
<summary>🆘 Indice</summary>

Côté OpenBao : `bao secrets enable -path=pki_int pki`, puis
`pki_int/intermediate/generate/internal` renvoie une CSR (`-field=csr`). Après
signature externe, `pki_int/intermediate/set-signed` réimporte le certificat
(`certificate=@fichier`) — passe-lui l'intermédiaire **et** la racine concaténés.
Côté OpenSSL : signe la CSR avec `openssl x509 -req -CA ext_root.crt -CAkey
ext_root.key` en ajoutant `basicConstraints=critical,CA:TRUE`.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
# 1) Racine externe (hors OpenBao)
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout /root/ext_root.key -out /root/ext_root.crt \
  -subj "/CN=Externe Root CA" -days 3650 \
  -addext "basicConstraints=critical,CA:TRUE"

# 2) Moteur intermédiaire + CSR
bao secrets enable -path=pki_int pki
bao secrets tune -max-lease-ttl=8h pki_int
bao write -field=csr pki_int/intermediate/generate/internal \
  common_name="OpenBao Intermediate" > /root/int.csr

# 3) Signer la CSR avec la racine externe
openssl x509 -req -in /root/int.csr \
  -CA /root/ext_root.crt -CAkey /root/ext_root.key -CAcreateserial \
  -days 365 -out /root/int_signed.crt \
  -extfile <(printf "basicConstraints=critical,CA:TRUE\nkeyUsage=critical,keyCertSign,cRLSign\n")

# 4) Réimporter intermédiaire + racine
cat /root/int_signed.crt /root/ext_root.crt > /root/int_chain.crt
bao write pki_int/intermediate/set-signed certificate=@/root/int_chain.crt

# 5) Rôle + émission de test
bao write pki_int/roles/leaf allowed_domains=lab.local allow_subdomains=true max_ttl=1h
bao write -format=json pki_int/issue/leaf common_name=svc.lab.local ttl=10m | jq -r .data.certificate
```

**Pourquoi cette approche.** En production, on ne laisse pas un serveur applicatif être
sa propre racine de confiance. La **racine** reste hors-ligne (ici, OpenSSL en joue le
rôle) et ne signe que de rares **intermédiaires** ; OpenBao n'héberge qu'une
intermédiaire, qui émet les feuilles au quotidien. Si OpenBao est compromis, on révoque
l'intermédiaire sans rejouer toute la PKI.

**Sous le capot.** OpenBao ne te donne **jamais** la clé privée de l'intermédiaire :
`generate/internal` la crée et la garde en interne, ne sortant qu'une **CSR**. La racine
externe signe cette CSR (en lui accordant `CA:TRUE` + `keyCertSign`), puis `set-signed`
réinjecte le certificat obtenu — OpenBao le marie alors à la clé qu'il avait gardée. La
chaîne de confiance est reconstituée sans que le secret ne quitte jamais le coffre.

**Le piège.** Deux écueils classiques. D'abord, `set-signed` attend la **chaîne
complète** : on concatène l'intermédiaire **et** la racine (`int_chain.crt`) — sinon les
clients ne sauront pas remonter jusqu'à la racine. Ensuite, l'`-extfile <(...)` utilise
une **substitution de processus** propre à bash : la signature doit porter
`basicConstraints=critical,CA:TRUE`, faute de quoi l'intermédiaire ne sera pas reconnue
comme une CA et n'émettra rien.
</details>
