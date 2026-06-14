# Défi 2 — Révoquer et le prouver dans la CRL

Un certificat compromis avant son expiration doit pouvoir être **révoqué**. OpenBao
révoque par **numéro de série** et publie une **CRL** (liste de révocation) signée par
la CA. À toi de faire le tour complet.

Bloc fourni — réexporte l'accès *(OpenBao tourne déjà depuis le Défi 1)* :

```
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root
bao status >/dev/null 2>&1 && echo "OpenBao OK" || echo "Relance le bloc fourni du Défi 1."
```{{exec}}

## 🎯 Objectif
1. Émettre un certificat via le rôle `prod` (créé au Défi 1).
2. Le **révoquer** par son numéro de série.
3. Écrire ce numéro de série dans **`/root/revoked_serial.txt`**.

## ✅ Critère de réussite
Le `verify.sh` télécharge la CRL de la CA et vérifie qu'elle contient bien une entrée
révoquée correspondant au numéro de série de `/root/revoked_serial.txt`.

Clique sur **Check** une fois la révocation faite.

---

<details>
<summary>🆘 Indice</summary>

Le numéro de série est renvoyé à l'émission (`.data.serial_number` en JSON). La
révocation se fait avec `bao write pki/revoke serial_number=…`. La CRL au format PEM
se récupère sur l'API : `GET $BAO_ADDR/v1/pki/crl/pem`, et se lit avec
`openssl crl -noout -text`.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
bao write -format=json pki/issue/prod common_name=revoke-me.lab.local ttl=30m > /root/r.json
SERIAL=$(jq -r .data.serial_number /root/r.json)
echo "$SERIAL" > /root/revoked_serial.txt
echo "Série : $SERIAL"

bao write pki/revoke serial_number=$SERIAL

curl -s $BAO_ADDR/v1/pki/crl/pem | openssl crl -noout -text | head -25
```

**Pourquoi révoquer**

Révoquer, c'est déclarer un certificat invalide **avant** sa date d'expiration. Le cas
typique : la clé privée d'un service a fuité — un dépôt Git poussé par erreur, un
laptop volé — et tu dois empêcher que ce certificat serve encore. OpenBao identifie
chaque certificat par son numéro de série : c'est la clé qu'on lui donne pour révoquer,
et celle qu'on retrouve ensuite dans la liste de révocation.

**Ce que produit la révocation**

En révoquant, OpenBao régénère sa CRL — un document signé par la CA qui énumère les
numéros de série bannis. Les clients qui la téléchargent savent dès lors refuser ce
certificat. `openssl crl -text` te la rend lisible.

**Le piège**

Tu dois capturer le **bon** numéro de série — celui renvoyé à l'émission, au format
hexadécimal à deux-points — d'où le passage par `jq .data.serial_number`. Et n'oublie
pas le fil rouge du parcours : une CRL ne sert que si elle est distribuée et
re-téléchargée par les clients, ce qui prend du temps. C'est tout le drame de la
révocation en conditions réelles — entre le moment où tu révoques et celui où le dernier
client l'apprend, il peut s'écouler des heures. Sur des certificats de quelques minutes,
ils expirent souvent avant même que la CRL ait fait le tour : c'est exactement pour ça
qu'on préfère les durées courtes à la révocation.
</details>
