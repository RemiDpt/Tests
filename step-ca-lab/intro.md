# PKI niveau 0 : ta première autorité de certification

Objectif : monter une PKI fonctionnelle de bout en bout — racine, intermédiaire,
serveur de CA en ligne, émission d'un certificat — **sans rien installer en local**.

L'outil utilisé est **step-ca** (Smallstep) : une CA open source, écrite en Go,
qui démarre instantanément. C'est le point d'entrée idéal avant d'attaquer des PKI
plus lourdes (OpenXPKI, EJBCA).

À la fin de ce lab :
- une hiérarchie à deux niveaux (root + intermediate) générée par tes soins ;
- un serveur de CA en ligne qui répond aux requêtes ;
- un premier certificat émis et vérifié contre ta propre racine.

> L'environnement s'installe en arrière-plan pendant la lecture de cette page.
> Patiente quelques secondes après être passé à l'étape 1 si une commande `step`
> n'est pas encore reconnue.

Durée estimée : 20 à 30 minutes.
