# Terminé

Ce que tu as construit :
- une CA interne qui parle **ACME** (le protocole de Let's Encrypt) ;
- un **job de pipeline simulé** qui obtient son certificat tout seul, sans secret ni humain ;
- un **renouvellement automatique** prêt à être planifié.

Tu es passé de « j'émets un certificat à la main » à « une machine gère son certificat
de bout en bout ». C'est le saut conceptuel du niveau 0 au niveau 1.

**Pour aller plus loin :**
- intégrer ces commandes dans un vrai `.gitlab-ci.yml` ou workflow GitHub Actions ;
- explorer le challenge `tls-alpn-01` (validation sans port 80) ;
- comparer avec une provisioner par **token court / OIDC** (identité de charge de travail) ;
- enchaîner sur **OpenBao** ou **EJBCA** pour des modèles d'émission différents.
