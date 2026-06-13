# PKI niveau 0 : ta première autorité de certification

Une PKI répond à une question toute simple mais vitale sur un réseau : « à qui je
parle, et puis-je lui faire confiance ? » Derrière chaque cadenas de navigateur, il y
a une autorité de certification qui a répondu à cette question. Tu vas en monter une,
entière, de la racine au premier certificat — et voir qu'il n'y a aucune magie dedans.

Objectif : monter une PKI fonctionnelle de bout en bout — racine, intermédiaire,
serveur de CA en ligne, émission d'un certificat — **sans rien installer en local**.

L'outil utilisé est **step-ca** (Smallstep) : une CA open source, écrite en Go,
qui démarre instantanément. C'est le point d'entrée idéal avant d'attaquer des PKI
plus lourdes comme OpenXPKI.

À la fin de ce lab :
- une hiérarchie à deux niveaux (root + intermediate) générée par tes soins ;
- un serveur de CA en ligne qui répond aux requêtes ;
- un premier certificat émis et vérifié contre ta propre racine.

> L'environnement (step CLI + step-ca) s'installe pendant cette intro. Patiente la
> fin de l'installation avant de passer à l'étape 1.

> step-ca n'a **pas d'interface graphique** : tout se passe dans le terminal.
> C'est normal et voulu — c'est aussi ce qui rend la CA scriptable et automatisable.

Durée estimée : 20 à 30 minutes.
