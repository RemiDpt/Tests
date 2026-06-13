# Terminé

Ce que tu as fait, des deux côtés du guichet :
- déployé une pile **OpenXPKI** complète (base, serveur, client, interface web) ;
- côté **demandeur** : généré ta clé, soumis une **CSR**, attendu — sans pouvoir décider ;
- côté **opérateur RA** : examiné la demande et **approuvé** l'émission ;
- vérifié le certificat émis et compris le principe des **quatre yeux**.

Quatre modèles d'émission vus dans le parcours :
1. **niveau 0** : émission manuelle (step-ca) ;
2. **niveau 1** : émission automatique par token court (identité de charge de travail) ;
3. **OpenBao** : secret dynamique à durée courte ;
4. **ici** : validation humaine par une autorité d'enregistrement.

**Pour aller plus loin :**
- lancer une demande de **révocation** (CRR) et suivre son workflow ;
- explorer les autres workflows de l'interface opérateur (recherche de certificats, CRL) ;
- regarder la configuration des **profils** de certificats dans `openxpki-config`.
