# Défi step-ca — à toi de jouer

Tu as déjà fait les labs « découverte » ? Ici, **on retire les commandes**. Chaque
étape pose un **objectif** et un **critère de réussite** vérifié par un script — mais
ne te donne pas la solution. À toi de mobiliser ce que tu sais (et `step --help`,
ton meilleur allié).

Quatre défis, indépendants ou presque, de difficulté croissante :

1. **Hiérarchie à trois niveaux**, entièrement hors-ligne (échauffement) ;
2. **Certificat SSH** utilisateur émis par la CA ;
3. **Politique de provisioner** qui refuse réellement un nom interdit ;
4. **Template** qui impose un contenu au certificat, sans que le demandeur le choisisse.

**Règles du jeu :**
- Chaque étape a un **🆘 Indice** et une **✅ Solution de référence** repliables, à
  n'ouvrir qu'en cas de blocage — l'intérêt du défi est de chercher d'abord.
- Le `verify.sh` ne contrôle pas que tu as tapé une commande : il vérifie le
  **résultat réel** (le bon certificat existe, la mauvaise demande est bien rejetée).
- Le mot de passe de la CA est dans `/root/.step-password` (trivial, jamais en prod).

Pendant l'intro, la CA s'installe, s'initialise (avec le support SSH) et démarre.
Quand le terminal est prêt, attaque le **Défi 1**.
