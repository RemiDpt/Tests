# Étape 5 — Révoquer, lire la CRL… et comprendre pourquoi c'est rare

Émettre d'abord un certificat un peu plus durable (1 h), pour avoir quelque chose à
révoquer :

```
bao write -format=json pki/issue/serveur-court \
  common_name=revoque-moi.lab.local ttl=1h > /root/cert2.json
SERIAL=$(jq -r .data.serial_number /root/cert2.json)
echo "Serial : $SERIAL"
```{{exec}}

Révoquer par numéro de série :

```
bao write pki/revoke serial_number=$SERIAL
```{{exec}}

La CRL (liste de révocation) signée par la CA contient maintenant une entrée :

```
curl -s $BAO_ADDR/v1/pki/crl/pem | openssl crl -noout -text | head -25
```{{exec}}

Repère le bloc `Revoked Certificates` avec le numéro de série du certificat.

---

**Pourquoi tu en auras rarement besoin.** Dans OpenBao (comme dans les versions
modernes de Vault), les certificats émis par le moteur PKI ne sont **pas suivis par
un bail (lease)** : la révocation est une action explicite, par numéro de série,
comme tu viens de le faire. Et la philosophie assumée est : **des durées de vie
courtes valent mieux que la révocation**. Une CRL doit être générée, distribuée,
téléchargée et vérifiée par les clients — un certificat de 2 minutes expire souvent
avant même que la CRL soit propagée.

C'est le même fil rouge depuis le début : durée courte + renouvellement
automatique = moins de dépendance à la révocation, et la capacité de changer
d'algorithme — demain post-quantique — à la vitesse du renouvellement.
