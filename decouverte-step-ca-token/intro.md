# Niveau 1 : un certificat automatique en CI/CD

> 🟢 **PARCOURS DÉCOUVERTE** — lab guidé, les commandes te sont fournies.

Au niveau 0, tu as émis un certificat **à la main**, en tapant un mot de passe. Très
bien pour apprendre — intenable au quotidien. Une pipeline CI/CD déploie dix fois par
jour : personne ne va taper un mot de passe à chaque fois, et surtout, **on ne veut
aucun secret durable stocké dans le runner**. Un secret qui traîne dans une pipeline,
c'est un secret qui fuit un jour.

La bonne réponse porte un nom : l'**identité de charge de travail** (*workload identity*,
le terme que tu croiseras chez les fournisseurs cloud). Plutôt que de
donner au job un mot de passe permanent, on lui remet un **token éphémère** — un
laissez-passer valable quelques minutes, juste le temps de réclamer son certificat.
Le token expire, et même volé après coup, il ne sert plus à rien.

> 💡 L'analogie : un mot de passe de provisioner, c'est ta carte bancaire. Un token
> court, c'est un ticket de parking — valable une fois, quelques minutes, sans valeur
> le lendemain. Tu confies bien plus volontiers le ticket que la carte.

Au programme :
1. créer la PKI — exactement la même qu'au niveau 0 ; ce qui change vient ensuite, dans
   la façon de lui réclamer un certificat ;
2. démarrer la CA ;
3. **simuler un job de pipeline** : un orchestrateur de confiance émet un token court,
   le job s'en sert — et lui seul — pour obtenir son certificat ;
4. brancher **ACME** pour qu'un service durable obtienne et **renouvelle** son certificat
   tout seul, sans token ni mot de passe ;
5. en faire un réflexe **automatisable**, sans jamais stocker de secret long-terme.

> L'environnement (step CLI + step-ca) s'installe pendant cette intro. Patiente la
> fin de l'installation avant de passer à l'étape 1.

Durée estimée : 25 à 40 minutes. Prérequis : avoir compris le niveau 0 (PKI, CA, certificat).
