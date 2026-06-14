# Étape 5 — Automatiser sans secret long-terme

Un certificat step-ca dure **24 h par défaut** : court, volontairement. La vraie
question en CI/CD n'est donc pas « comment l'obtenir » mais « comment le **renouveler
sans personne**, et sans laisser traîner de secret ».

Tu as maintenant vu les deux réponses : le **token** pour un job qui démarre, se sert et
disparaît (étape 3) ; **ACME** pour un service durable qui se renouvelle tout seul
(étape 4). Restons sur le modèle token, le plus courant en CI/CD : **chaque exécution de
pipeline recommence le geste de l'étape 3**. Un nouveau token court, un nouveau
certificat. Pas de stock, pas de secret durable côté job. Rejoue le cycle pour t'en
convaincre :

```
cd /root
TOKEN=$(step ca token ci-runner.lab.local \
  --provisioner admin --password-file /root/.step-password \
  --ca-url https://localhost:4443 --root $(step path)/certs/root_ca.crt)
step ca certificate ci-runner.lab.local cert.pem key.pem --token $TOKEN \
  --ca-url https://localhost:4443 --root $(step path)/certs/root_ca.crt --force
step certificate inspect cert.pem --short
```{{exec}}

Un certificat tout frais, sans toucher à rien d'autre.

**Et en production, où va le mot de passe de la provisioner ?** Justement, nulle part
dans le job. Deux modèles dominent :
- la plateforme CI (GitLab, GitHub Actions…) prouve l'identité du job par **OIDC** ;
  step-ca a une provisioner OIDC qui frappe le token à la volée — aucun mot de passe,
  même côté orchestrateur ;
- une charge déjà détentrice d'un certificat le **renouvelle elle-même** par mTLS avec
  `step ca renew` : c'est son certificat actuel qui l'authentifie, toujours sans secret.

> Le fil conducteur : le secret durable disparaît, remplacé par une **identité
> prouvée à chaque fois**. C'est le principe de l'identité de charge de travail.

---

**Pourquoi certificats courts + renouvellement continu, c'est la bonne base.** Plus la
durée de vie est courte, moins la révocation compte — un certificat compromis expire
vite de lui-même. Et surtout, un parc qui se renouvelle déjà tout seul peut **changer
d'algorithme** à la même cadence. C'est exactement le levier de la **crypto-agilité** :
le jour où tu migres vers des algorithmes post-quantiques, un parc qui renouvelle
toutes les quelques heures bascule en quelques jours — pas en quelques années. Une
exigence que l'ANSSI met en avant dans ses travaux sur la transition post-quantique.

Tu viens de monter la brique qui rend cette agilité possible.
