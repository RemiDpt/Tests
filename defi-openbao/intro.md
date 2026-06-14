# Défi OpenBao — à toi de jouer

> 🔴 **PARCOURS DÉFI** — aucune solution donnée, à toi de jouer.

Même esprit que le défi step-ca : **pas de commandes toutes faites** pour le cœur de
chaque étape. Un objectif, un critère vérifié par script, et à toi de trouver le
chemin (`bao <commande> -help` est ton ami).

Quatre défis :

1. **Rôle PKI contraint** qui refuse réellement un domaine hors périmètre ;
2. **Révocation + CRL** : révoquer un certificat et le prouver ;
3. **AppRole** : un token pour un runner CI, capable d'émettre mais rien d'autre ;
4. **Intermédiaire** OpenBao signée par une **racine externe** (OpenSSL).

**Règles du jeu :**
- **🆘 Indice** et **✅ Solution de référence** repliables en fin d'étape — à n'ouvrir
  qu'en dernier recours.
- Le `verify.sh` contrôle le **résultat réel** : il émet, révoque ou tente une action
  interdite lui-même, et juge sur le comportement effectif d'OpenBao.
- Les étapes sont **séquentielles** : le Défi 1 crée le rôle `prod` réutilisé ensuite.
- Le serveur tourne en **mode dev** (token `root`, stockage en mémoire) : trivial
  assumé, jamais en production.

Quand le terminal est prêt, attaque le **Défi 1** (il démarre OpenBao et monte la PKI
de base via un bloc fourni, avant de te laisser créer le rôle).
