# Défi réenrôlement — relevé

> 🔴 **PARCOURS DÉFI**

Tu viens de faire, en script, ce qui crispe beaucoup d'équipes : **migrer tout un parc
d'une AC à une autre**, sans rien perdre en route.

1. tu as **réenrôlé** une cinquantaine de certificats sous une nouvelle racine **ECDSA**,
   en **régénérant une clé** par service et en **préservant l'identité** (CN + tous les
   SAN) ;
2. tu as **réconcilié** la migration avec l'état réel du parc — les services hors-service
   **exclus**, et un **rapport** pour prouver qui a été migré et qui ne l'a pas été.

C'est exactement la compétence attendue le jour d'une **rotation d'AC** : ce n'est pas une
commande, c'est une **boucle qui itère sur la flotte**, lit l'identité de l'existant, et
la ré-émet sous la nouvelle autorité.

**Le vrai sujet derrière, c'est la crypto-agilité.** Aujourd'hui RSA → ECDSA ; demain, ce
sera ECDSA → **algorithmes post-quantiques**. La mécanique que tu viens d'écrire est
identique : seul l'algorithme de la nouvelle racine change. Une PKI dont on sait réenrôler
le parc en un script est une PKI **agile** — celle qui survivra au prochain changement
d'algorithme imposé.

**Pour aller plus loin :**
- gérer le **rollback** : garder l'ancien certificat tant que le nouveau n'est pas déployé
  et validé sur le service ;
- réenrôler en continu via un **serveur ACME** plutôt qu'en signant hors-ligne (cf. le lab
  découverte step-ca avec ACME) ;
- projeter le temps de migration mesuré ici sur un parc de plusieurs **milliers** de
  certificats : c'est là que le script devient non négociable.
