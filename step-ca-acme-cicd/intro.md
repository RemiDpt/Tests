# Niveau 1 : un certificat automatique dans une pipeline CI/CD

Au niveau 0, tu émettais un certificat **à la main**, en tapant un mot de passe de
provisioner. Ça ne passe pas à l'échelle : une pipeline CI/CD a besoin de certificats
**sans intervention humaine** et **sans stocker de secret long-terme** dans le runner.

La réponse, c'est **ACME** — le protocole que Let's Encrypt a popularisé pour le web.
Ici, on l'applique à ta CA interne : un job de pipeline obtient son certificat tout
seul, comme un serveur web obtient son certificat Let's Encrypt.

Au programme :
1. activer une provisioner **ACME** sur ta CA ;
2. la démarrer ;
3. **simuler un job de pipeline** qui obtient son certificat automatiquement via `certbot` ;
4. mettre en place le **renouvellement automatique** — le vrai sujet en CI/CD.

> L'environnement (step-ca + certbot) s'installe pendant cette intro. Patiente la
> fin de l'installation avant de passer à l'étape 1.

Durée estimée : 25 à 40 minutes. Prérequis : avoir compris le niveau 0 (PKI, CA, certificat).
