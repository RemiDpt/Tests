# OpenXPKI : quand un humain valide la demande

Dans les labs précédents, le demandeur obtenait son certificat **directement** : mot
de passe (niveau 0), token court (niveau 1), token OpenBao. Mais dans beaucoup de
contextes — identités de personnes, certificats à fort enjeu, exigences
réglementaires — une PKI d'entreprise impose une étape de plus : la **validation
humaine** par une **autorité d'enregistrement (RA)**.

C'est exactement ce que tu vas jouer ici, des deux côtés du guichet :
1. découvrir la pile OpenXPKI et son **interface web** (une première dans le parcours) ;
2. côté **demandeur** : générer une clé et soumettre une demande (CSR) ;
3. côté **opérateur RA** : examiner la demande en attente, l'**approuver** — la CA émet ;
4. prendre du recul : pourquoi cette séparation des rôles existe, et ce qu'elle coûte.

**OpenXPKI** est une PKI open source mature (Perl), utilisée en production par des
entreprises et des administrations, pilotée par workflows.

> ⏳ L'installation tourne pendant cette intro et prend **plusieurs minutes**
> (téléchargement des images Docker, démarrage de la base et du serveur, génération
> d'une CA de démonstration). Profites-en pour lire ce qui suit.

> L'interface web utilise un certificat de démonstration **auto-signé** : ton
> navigateur affichera un avertissement de sécurité. C'est attendu dans ce lab —
> accepte l'exception pour continuer.

Durée estimée : 30 à 45 minutes. Prérequis : niveau 0 (PKI, CA, CSR, certificat).
