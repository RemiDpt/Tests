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
</details>
