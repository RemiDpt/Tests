# Étape 2 — Créer une CA racine

EJBCA s'administre par l'UI **et** par une CLI complète — indispensable pour
industrialiser. La CLI vit dans le conteneur : `ejbca.sh`.

Créer une CA racine classique (RSA 3072, validité 10 ans) :

```
docker exec ejbca /opt/keyfactor/bin/ejbca.sh ca init \
  LabRootCA "CN=Lab Root CA,O=labPKI" \
  soft LabPKI-non-securise 3072 RSA 3650 \
  --policy 2.5.29.32.0 SHA256WithRSA
```{{exec}}

Les arguments, dans l'ordre : nom interne de la CA, **DN** (l'identité de la
racine), type de token (`soft` = clés logicielles ; en production, ce serait un
**HSM**), mot de passe du token, taille de clé, algorithme, validité en jours,
politique de certification (ici `anyPolicy`), algorithme de signature.

Lister les CA pour vérifier :

```
docker exec ejbca /opt/keyfactor/bin/ejbca.sh ca listcas
```{{exec}}

`LabRootCA` apparaît à côté de `ManagementCA`. Retourne aussi voir
**Certification Authorities** dans l'Admin UI : ta CA y est, avec son certificat
racine consultable.

> Une seule commande pour une CA de production potentielle — compare avec
> `step ca init` du niveau 0 : le geste est le même, l'outillage autour (profils,
> rôles d'administration, audit, HSM) fait la différence d'échelle.

Cliquer sur **Check**.
