# Terminé

Ce que tu as construit :
- un serveur **OpenBao** en mode dev, avec le moteur **PKI** monté ;
- une CA interne dont la clé privée ne sort jamais d'OpenBao ;
- un **rôle** qui borne la politique d'émission (noms, durées) ;
- des certificats **dynamiques de 2 minutes**, générés à la demande ;
- une **révocation par numéro de série** et sa CRL — en sachant pourquoi les durées
  courtes la rendent rarement nécessaire.

Trois modèles d'émission vus jusqu'ici :
1. **niveau 0** : émission manuelle (step-ca) ;
2. **niveau 1** : émission automatique par challenge (ACME) ;
3. **ici** : secret dynamique à durée courte (OpenBao).

**Pour aller plus loin :**
- monter une **intermédiaire** dans OpenBao signée par une racine externe (hiérarchie réaliste) ;
- brancher un service qui consomme `pki/issue/...` à chaque démarrage ;
- comparer avec l'agent OpenBao/Vault qui renouvelle automatiquement les certificats.

**Suite du parcours :**
- **OpenXPKI** — le workflow d'autorité d'enregistrement : demande → validation humaine → émission ;
- **EJBCA** — la PKI d'entreprise complète : profils, protocoles d'enrôlement, ouverture post-quantique.
