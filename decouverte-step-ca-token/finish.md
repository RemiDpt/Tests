# Terminé

Ce que tu as construit :
- une CA interne prête à émettre pour des charges automatisées ;
- un **token court** frappé par un orchestrateur de confiance ;
- un **job de pipeline** qui obtient son certificat avec ce seul token — sans jamais
  détenir de secret durable ;
- le réflexe de **rejouer le cycle** à chaque exécution : le renouvellement, sans personne.

Tu es passé de « j'émets un certificat à la main » à « une charge prouve son identité
et obtient son certificat toute seule ». C'est le saut conceptuel du niveau 0 au niveau 1.

> Au passage, tu as vu pourquoi le challenge réseau à la Let's Encrypt (ACME HTTP-01)
> n'est pas toujours la bonne réponse en interne : il suppose que la CA puisse
> recontacter le demandeur. Le token court, lui, ne demande aucune reconnexion — plus
> simple et plus robuste pour du CI/CD interne.

**Pour aller plus loin :**
- brancher ces commandes dans un vrai `.gitlab-ci.yml` ou workflow GitHub Actions ;
- remplacer le mot de passe de provisioner par une provisioner **OIDC** (identité du job) ;
- explorer `step ca renew` pour le renouvellement par mTLS, sans token ;
- enchaîner sur **OpenBao** pour un autre modèle d'émission (certificats dynamiques courts).
