# Défi réenrôlement — relevé

> 🔴 **PARCOURS DÉFI**

Tu viens de faire, en script, ce qui crispe beaucoup d'équipes : **migrer tout un parc
d'une AC à une autre**, sans rien perdre en route.

1. tu as **réenrôlé** une cinquantaine de certificats sous une nouvelle racine **ECDSA**,
   en **régénérant une clé** par service et en **préservant l'identité** (CN + tous les
   SAN) ;
2. tu as **réconcilié** la migration avec l'état réel du parc — les services hors-service
   **exclus**, et un **rapport** pour prouver qui a été migré et qui ne l'a pas été.

C'est exactement la compétence attendue le jour d'une **rotation d'AC** : pas une commande
magique, mais un **script qui passe tout le parc en revue**, lit l'identité de chaque
certificat existant et la ré-émet sous la nouvelle autorité.

**Le vrai sujet derrière, c'est la crypto-agilité — et la bascule qui se profile : la
cryptographie post-quantique.** Le jour où il faudra migrer tout un parc vers des
algorithmes résistants au quantique, ce n'est pas l'outil qui fera la différence, c'est
d'avoir déjà le réflexe et le script. La mécanique sera identique à celle que tu viens
d'écrire ; seul l'algorithme de la nouvelle racine change. Une PKI qu'on sait réenrôler en
un script est une PKI **agile** : celle qui absorbera la transition post-quantique sans
réécrire ses fondations dans l'urgence.

**Pour aller plus loin :**
- gérer le **rollback** : garder l'ancien certificat tant que le nouveau n'est pas déployé
  et validé sur le service ;
- réenrôler en continu via un **serveur ACME** plutôt qu'en signant hors-ligne (cf. le lab
  découverte step-ca avec ACME) ;
- projeter le temps de migration mesuré ici sur un parc de plusieurs **milliers** de
  certificats : c'est là que le script devient non négociable.
