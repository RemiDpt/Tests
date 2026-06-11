# Étape 3 — Émettre un certificat de 2 minutes

Demander un certificat au rôle `serveur-court`. Tout est dynamique : OpenBao génère
la clé privée, signe le certificat et renvoie l'ensemble en JSON :

```
bao write -format=json pki/issue/serveur-court \
  common_name=app.lab.local > /root/cert.json
jq -r .data.certificate   /root/cert.json > /root/app.crt
jq -r .data.private_key   /root/cert.json > /root/app.key
jq -r .data.serial_number /root/cert.json
```{{exec}}

Regarder la validité — 2 minutes, comme défini dans le rôle :

```
openssl x509 -in /root/app.crt -noout -subject -startdate -enddate
```{{exec}}

> Deux minutes, c'est volontairement provocateur. L'idée : le certificat vit le
> temps d'un déploiement ou d'une connexion, puis meurt. Le demandeur (un service,
> un job CI) le redemande à chaque besoin — c'est le modèle « secret dynamique ».
> Compare avec le niveau 0, où le certificat de 24 h passait déjà pour court.

Attends 2 minutes et relance la commande `openssl` ci-dessus : le certificat est
expiré. Personne ne l'a révoqué — il est mort de sa belle mort. Retiens ce point
pour l'étape 4.

Cliquer sur **Check**.
