# Étape 3 — Le job de pipeline obtient son certificat

On simule maintenant un **runner CI/CD**. Dans la vraie vie, ces commandes seraient
dans un `.gitlab-ci.yml` ou un workflow GitHub Actions. Le principe : le job demande
son certificat **tout seul**, sans qu'un humain tape quoi que ce soit, et **sans
secret stocké** dans la pipeline.

Le runner doit d'abord faire confiance à la racine de ta CA (sinon il refusera de
parler à un serveur ACME inconnu) — c'est le rôle de `REQUESTS_CA_BUNDLE` :

```
export REQUESTS_CA_BUNDLE=$(step path)/certs/root_ca.crt
```{{exec}}

Le job demande son certificat via `certbot`, en mode automatique (`-n`) :

```
certbot certonly -n --standalone \
  -d ci-runner.lab.local \
  --server https://localhost:4443/acme/acme/directory \
  --agree-tos -m ci@lab.local
```{{exec}}

Les options qui rendent ça automatisable :
- `-n` : non-interactif, aucune question posée — condition de survie en pipeline ;
- `--standalone` : certbot ouvre lui-même un mini serveur web sur le port 80 pour répondre au challenge ;
- `--agree-tos` / `-m` : accepte les conditions et déclare l'email de contact du compte ACME, sans prompt.

Ce qui se passe, sans aucune intervention :
1. `certbot` crée un compte ACME et commande un certificat pour `ci-runner.lab.local` ;
2. la CA lui pose un **challenge HTTP-01** ; `certbot` (mode `--standalone`) ouvre un
   serveur temporaire sur le port 80 pour y répondre ;
3. la CA vérifie le challenge, puis signe le certificat.

Le certificat atterrit dans `/etc/letsencrypt/live/ci-runner.lab.local/`. Vérifier :

```
ls -l /etc/letsencrypt/live/ci-runner.lab.local/
step certificate inspect /etc/letsencrypt/live/ci-runner.lab.local/cert.pem --short
```{{exec}}

> Compare avec le niveau 0 : là tu fournissais `--provisioner-password-file`. Ici,
> **zéro secret** — c'est toute la différence du modèle ACME, et la raison pour
> laquelle il est fait pour les machines et les pipelines.

Cliquer sur **Check**.
