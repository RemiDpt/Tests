# Défi step-ca — relevé

Tu as résolu, sans commandes toutes faites :

1. une **hiérarchie à trois niveaux** vérifiable de la feuille à la racine ;
2. l'émission d'un **certificat SSH** utilisateur signé par la CA ;
3. une **politique** de provisioner qui **refuse réellement** un nom hors périmètre ;
4. un **template** qui **impose** le contenu d'un certificat, demandeur ou pas.

Ce sont exactement les leviers d'une PKI maîtrisée : *qui* peut demander, *quoi*
peut être émis, et *comment* on protège l'autorité. Dans une vraie boîte, ces trois
leviers font la différence entre une PKI qu'on présente sereinement à un auditeur et
une autre qu'on espère qu'il ne regardera pas de trop près. La différence avec les labs
découverte n'est pas l'outil — c'est que tu n'avais plus de carte.

**Pour aller plus loin :**
- combiner politique **et** template sur une même provisioner et observer l'ordre
  d'application ;
- ajouter une provisioner dédiée par usage (web, SSH, CI) avec des contraintes
  distinctes ;
- enchaîner avec le **défi OpenBao** : mêmes idées (rôles contraints, identités de
  machine), autre moteur.
