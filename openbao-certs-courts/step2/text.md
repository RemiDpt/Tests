# Étape 2 — Monter le moteur PKI et créer la CA

Dans OpenBao, chaque fonctionnalité est un **moteur de secrets** monté sur un chemin.
Monter le moteur PKI, puis lui fixer une durée de vie maximale :

```
bao secrets enable pki
bao secrets tune -max-lease-ttl=24h pki
```{{exec}}

Générer la CA racine. `internal` signifie que la clé privée reste à l'intérieur
d'OpenBao — elle ne sortira jamais :

```
bao write -field=certificate pki/root/generate/internal \
  common_name="OpenBao Lab CA" ttl=24h > /root/ca_openbao.crt
openssl x509 -in /root/ca_openbao.crt -noout -subject -enddate
```{{exec}}

Créer un **rôle** : c'est la politique d'émission — quels noms sont autorisés, pour
quelle durée. Ici : domaine `lab.local`, durée par défaut **2 minutes**, maximum 1 h :

```
bao write pki/roles/serveur-court \
  allowed_domains=lab.local allow_subdomains=true \
  ttl=2m max_ttl=1h
```{{exec}}

> Compare avec le niveau 0 : chez step-ca, la politique d'émission vivait dans la
> *provisioner* ; ici elle vit dans le *rôle*. Même principe dans les deux cas : on
> ne laisse jamais un demandeur choisir librement le contenu de son certificat.

Cliquer sur **Check**.
