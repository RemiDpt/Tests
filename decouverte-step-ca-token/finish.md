# Terminé

> 🟢 **PARCOURS DÉCOUVERTE**

Ce que tu as construit :
- une CA interne prête à émettre pour des charges automatisées ;
- un **token court** frappé par un orchestrateur de confiance ;
- un **job de pipeline** qui obtient son certificat avec ce seul token — sans jamais
  détenir de secret durable ;
- une émission **ACME** auto-renouvelée pour un service durable, sans token ni mot de passe ;
- le réflexe de **rejouer le cycle** à chaque exécution : le renouvellement, sans personne.

Tu es passé de « j'émets un certificat à la main » à « une charge prouve son identité
et obtient son certificat toute seule ». C'est le saut conceptuel du niveau 0 au niveau 1.

> Tu as manipulé les deux modèles : **ACME** (HTTP-01), où la CA recontacte le demandeur
> pour vérifier qu'il contrôle bien le nom — parfait pour un service durable qui se
> renouvelle seul ; et le **token court**, qui ne demande aucune reconnexion — plus
> simple pour un job CI éphémère. Aucun n'est « meilleur » dans l'absolu : ils répondent
> à deux situations différentes.

**Pour aller plus loin :**
- brancher ces commandes dans un vrai `.gitlab-ci.yml` ou workflow GitHub Actions ;
- remplacer le mot de passe de provisioner par une provisioner **OIDC** (identité du job) ;
- explorer `step ca renew` pour le renouvellement par mTLS, sans token ;
- enchaîner sur **OpenBao** pour un autre modèle d'émission (certificats dynamiques courts).
