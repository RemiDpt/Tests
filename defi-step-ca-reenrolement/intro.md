# Défi — Réenrôler un parc avant l'expiration de l'AC

> 🔴 **PARCOURS DÉFI** — aucune solution donnée, à toi de jouer.

Le scénario : ton entreprise a une PKI en place depuis des années. L'**autorité de
certification racine arrive en fin de vie** et, accessoirement, elle est en **RSA** là où
la nouvelle politique impose de l'**ECDSA**. Verdict : il faut **réenrôler tout le parc**
— une cinquantaine de certificats de service déjà émis — sous une **nouvelle racine**,
avant que l'ancienne n'expire et ne fasse tomber la moitié des services un lundi matin.

Personne ne fait ça à la main pour 50 certificats (et encore moins pour 5 000). Ton
boulot : **écrire le script** qui migre le parc proprement.

Le setup t'a déjà préparé le terrain :
- `/root/old_root.crt` : l'**ancienne racine RSA** (celle qui expire) ;
- `/root/new_root.crt` + `/root/new_root.key` : la **nouvelle racine ECDSA**, la cible ;
- `/root/parc/` : une cinquantaine de certificats `svcN.lab.local` (clés comprises),
  signés par l'ancienne racine — **certains portent plusieurs SAN** ;
- `/root/parc/decommissionnes.txt` : des services hors-service (pour le Défi 2).

> PKI volontairement **plate** ici (la racine signe directement les certificats de
> service) : on se concentre sur la **mécanique de migration**, pas sur la hiérarchie.

**Règles du jeu :**
- Chaque étape a un **🧩 Indice**, un **🧩 Coup de pouce** et une **🗝️ Solution de
  référence** repliables — à n'ouvrir qu'en cas de blocage. L'intérêt du défi est de
  chercher d'abord.
- Le `verify.sh` contrôle le **résultat réel** (les bons certificats existent, sous la
  bonne racine, avec la bonne identité), pas qu'une commande a été tapée.

Quand le terminal est prêt, attaque le **Défi 1**.
