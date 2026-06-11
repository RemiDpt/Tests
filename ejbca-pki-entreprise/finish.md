# Terminé — et fin du parcours

Ce que tu as fait dans ce lab :
- déployé **EJBCA Community**, une PKI d'entreprise complète ;
- créé une **CA racine** en une commande CLI ;
- enrôlé une **entité finale** (profil → entité → keystore PKCS#12) ;
- créé une CA **post-quantique ML-DSA** et constaté de tes yeux où en est
  l'écosystème.

**Le parcours complet, avec le recul :**

| Lab | Modèle d'émission | Leçon crypto-agilité |
|-----|-------------------|----------------------|
| step-ca niveau 0 | manuelle | la chaîne de confiance |
| step-ca niveau 1 | ACME, automatique | renouveler sans humain |
| OpenBao | secret dynamique court | durée courte > révocation |
| OpenXPKI | workflow RA, validation humaine | la séparation des rôles |
| EJBCA | PKI d'entreprise, profils | changer d'algorithme — y compris ML-DSA |

Le fil rouge, formulé en une phrase : **une PKI agile est une PKI qui renouvelle
vite, centralise ses politiques, et peut changer d'algorithme sans tout
reconstruire** — la migration post-quantique n'est que le premier test grandeur
nature de cette agilité.

**Pour aller plus loin :**
- monter une hiérarchie hybride (racine classique + intermédiaire ML-DSA, ou
  chaînes parallèles) dans EJBCA ;
- tester les protocoles d'enrôlement d'EJBCA (SCEP, EST, CMP, ACME) ;
- suivre les publications de l'ANSSI sur la transition post-quantique.

Merci d'avoir suivi le parcours — et bonne route vers le post-quantique.
