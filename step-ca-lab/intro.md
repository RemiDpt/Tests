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

> L'environnement (step CLI + step-ca) s'installe pendant cette intro. Patiente la
> fin de l'installation avant de passer à l'étape 1.

> step-ca n'a **pas d'interface graphique** : tout se passe dans le terminal.
> C'est normal et voulu — c'est aussi ce qui rend la CA scriptable et automatisable.

Durée estimée : 20 à 30 minutes.
