# Défi OpenBao — relevé

> 🔴 **PARCOURS DÉFI**

Sans commandes toutes faites, tu as :

1. créé un **rôle PKI contraint** qui refuse réellement ce qui sort de son domaine et
   plafonne la durée de vie ;
2. **révoqué** un certificat et prouvé sa présence dans la **CRL** ;
3. monté une auth **AppRole** délivrant un token **au pouvoir strictement limité** à
   l'émission — le bon modèle pour un runner CI ;
4. fait signer une **intermédiaire** OpenBao par une **racine externe**, et vérifié la
   chaîne complète.

C'est la mécanique d'une PKI d'entreprise pilotée par API : périmètre serré, identités
de machine, révocation, et insertion dans une hiérarchie existante. Le tout en
quelques minutes, scriptable, donc **agile** — le fil rouge du parcours.

**Pour aller plus loin :**
- réduire `token_ttl` de l'AppRole et observer l'expiration forcer le renouvellement ;
- restreindre le `secret-id` (CIDR, nombre d'usages) pour durcir l'auth machine ;
- comparer la philosophie « durées courtes » d'OpenBao avec la révocation/CRL : quand
  l'une dispense-t-elle de l'autre ?
