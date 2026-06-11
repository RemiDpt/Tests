# Étape 3 — Enrôler une entité finale

Dans EJBCA, on n'émet pas un certificat « directement » : on déclare d'abord une
**entité finale** (end entity) — l'identité à certifier — puis on l'enrôle. Déclarer
un serveur, rattaché à ta CA :

```
docker exec ejbca /opt/keyfactor/bin/ejbca.sh ra addendentity \
  --username serveur1 --dn "CN=serveur1.lab.local" \
  --caname LabRootCA --type 1 --token P12 \
  --password LabPKI-non-securise
docker exec ejbca /opt/keyfactor/bin/ejbca.sh ra setclearpwd \
  serveur1 LabPKI-non-securise
```{{exec}}

`--token P12` : EJBCA générera la clé ET le certificat, livrés ensemble dans un
keystore PKCS#12. Le mode batch traite toutes les entités en attente :

```
docker exec ejbca /opt/keyfactor/bin/ejbca.sh batch
```{{exec}}

Récupérer le keystore hors du conteneur et l'inspecter :

```
docker cp ejbca:/opt/keyfactor/p12/serveur1.p12 /root/serveur1.p12
openssl pkcs12 -in /root/serveur1.p12 -passin pass:LabPKI-non-securise -nokeys \
  | openssl x509 -noout -subject -issuer -dates
```{{exec}}

Sujet : `serveur1.lab.local` ; émetteur : ta `Lab Root CA`.

> Ici la PKI a généré la clé privée à la place du demandeur (mode *server-side key
> generation*) — l'inverse du modèle CSR vu avec OpenXPKI. Pratique pour livrer des
> keystores clé en main, mais la clé a existé hors des mains de son propriétaire :
> un compromis à connaître.

> En production, ce flux serait rarement manuel : EJBCA expose **SCEP, EST, CMP et
> ACME** — les protocoles d'enrôlement que parlent les équipements réseau, les MDM
> et les serveurs. Le niveau 1 du parcours (ACME) t'a déjà montré le principe.

Cliquer sur **Check**.
