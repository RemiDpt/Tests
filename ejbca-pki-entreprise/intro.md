# EJBCA : la PKI d'entreprise, jusqu'au post-quantique

Dernière étape du parcours. **EJBCA** (Keyfactor, open source) est une PKI
d'entreprise complète : multi-CA, profils de certificats, gestion des entités
finales, protocoles d'enrôlement (SCEP, EST, CMP, ACME), interfaces web
d'administration et d'enrôlement. C'est l'outil qu'on retrouve chez des opérateurs,
des industriels et des administrations.

Et c'est ici que le fil rouge du parcours aboutit : depuis sa version 9.1, EJBCA
Community sait créer des CA signées en **ML-DSA** — l'algorithme de signature
**post-quantique standardisé par le NIST**. Tu vas en créer une.

Au programme :
1. explorer la pile et l'**Admin UI** ;
2. créer une **CA racine** classique en ligne de commande ;
3. **enrôler une entité finale** : le cycle profil → entité → certificat ;
4. franchir le **cap post-quantique** : une CA ML-DSA, et ce que ça implique.

> ⏳ EJBCA est une application Java lourde : le démarrage prend **2 à 5 minutes**
> pendant cette intro. Profites-en pour lire ce qui suit.

> Le lab utilise le mode `TLS_SETUP_ENABLED=simple` : l'Admin UI est accessible
> **sans certificat client**. La doc officielle le réserve aux tests jetables — en
> production, l'accès admin d'EJBCA exige un certificat client (émis par la PKI
> elle-même). Même esprit que nos mots de passe triviaux : assumé ici, jamais en prod.

> Comme pour OpenXPKI : certificat serveur auto-signé, ton navigateur affichera un
> avertissement. Accepte l'exception.

Durée estimée : 30 à 45 minutes. Prérequis : niveau 0 ; OpenXPKI recommandé (profils, rôles).
