# Étape 4 — Comprendre la cérémonie de clés

Reprends ce que tu viens de faire, dans l'ordre — c'est, en miniature, le squelette
d'une vraie **cérémonie de clés** de CA racine :

1. préparer un compartiment protégé (le token, ses PIN détenus séparément) ;
2. **générer la clé à l'intérieur** du module — jamais à l'extérieur ;
3. constater qu'elle est **non extractible**, puis l'utiliser pour signer la racine.

En production, ce déroulé est **scénarisé, filmé, et accompagné de témoins**. Pourquoi
tant de cérémonie pour quelques commandes ? Parce que la clé d'une CA racine est le
point de confiance ultime : tout le reste (intermédiaires, certificats feuilles) en
découle. Si elle fuit, c'est toute la PKI qui s'effondre — et une racine vit dix,
vingt ans. On ne peut pas se permettre le moindre doute sur le fait qu'aucune copie
n'a jamais existé.

**Ce que le HSM change, concrètement :**
- la clé n'est jamais sur un disque, jamais dans une sauvegarde, jamais dans un dump mémoire ;
- l'usage de la clé est tracé et soumis à authentification (le PIN, voire plusieurs) ;
- même un administrateur pleinement compromis ne peut pas *exfiltrer* la clé — au pire
  l'utiliser tant qu'il a le PIN, ce qui se révoque et se journalise.

> C'est pourquoi l'**ANSSI** recommande, pour les clés de CA, une protection par module
> matériel et une génération en cérémonie maîtrisée : la robustesse d'une PKI ne tient
> pas qu'à la taille des clés, mais à la rigueur avec laquelle elles sont protégées tout
> au long de leur vie.

**Et le lien avec le reste du parcours ?** Tu as vu successivement *comment* émettre
(niveau 0), *automatiser sans secret* (niveau 1), *raccourcir et rendre dynamique*
(OpenBao), *encadrer par un humain* (OpenXPKI). Ici, tu t'es occupé du socle :
**protéger la clé qui fait foi**. Une PKI agile, courte, automatisée, validée — mais
dont la racine est inviolable. C'est le cran qui manquait.

> Pour aller vers le réel : un vrai HSM (réseau ou carte), ou step-ca compilé avec le
> support PKCS#11 pour consommer une clé de HSM exactement comme tu viens de le faire
> à la main.
