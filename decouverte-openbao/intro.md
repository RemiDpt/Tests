# OpenBao : des certificats courts, dynamiques, à la demande

Aux niveaux 0 et 1, la CA (step-ca) émettait des certificats sur demande — à la main,
puis automatiquement via un token court. Ici, on change de modèle : avec **OpenBao** (fork open
source de HashiCorp Vault, hébergé par la Linux Foundation), le certificat devient un
**secret dynamique** — généré à la volée, valable quelques minutes, jeté, regénéré.
Pense au badge visiteur qu'on réimprime à chaque passage plutôt qu'à une carte d'accès
permanente : moins pratique à voler, rien à révoquer le soir venu.

Pourquoi c'est important :
- plus de stock de certificats à gérer : chaque service demande le sien au moment où il en a besoin ;
- une durée de vie de quelques minutes rend la **révocation presque inutile** — un certificat compromis meurt tout seul, vite ;
- un parc qui renouvelle en permanence peut **changer d'algorithme très rapidement** : c'est le cœur de la crypto-agilité, et la meilleure préparation à la migration post-quantique.

Au programme :
1. démarrer OpenBao et t'authentifier ;
2. monter le moteur **PKI** et créer une CA interne ;
3. émettre un certificat valable **2 minutes** ;
4. révoquer par numéro de série, lire la CRL — et comprendre pourquoi tu en auras rarement besoin.

> L'environnement (OpenBao + jq) s'installe pendant cette intro. Patiente la fin de
> l'installation avant de passer à l'étape 1.

> OpenBao se pilote en ligne de commande et par API HTTP : tout se passe dans le
> terminal dans ce lab. C'est normal et voulu.

Durée estimée : 25 à 35 minutes. Prérequis : avoir compris le niveau 0 (PKI, CA, certificat).
