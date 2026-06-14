# Niveau 2 : la cérémonie de clés

> 🟢 **PARCOURS DÉCOUVERTE** — lab guidé, les commandes te sont fournies.

Depuis le niveau 0, une question est restée sous le tapis : **où vit la clé privée de
ta CA ?** Jusqu'ici, dans un fichier sur le disque, protégé par un mot de passe. Pour
un lab, parfait. Pour une CA racine en production, c'est le pire des cauchemars : qui
copie ce fichier copie ton autorité tout entière, et peut signer en ton nom pour
toujours.

La réponse de l'industrie tient en trois lettres : **HSM** (Hardware Security Module).
Un boîtier où la clé est **générée à l'intérieur** et **ne sort jamais** — même
l'administrateur ne peut pas la lire. On ne manipule que des *références* à la clé ; le
HSM signe pour toi, sans jamais te montrer le secret.

> 💡 L'analogie : un HSM, c'est un coffre-fort qui signe les documents pour toi par une
> fente. Tu glisses le document, il ressort signé. Mais tu ne tiens jamais le tampon
> dans ta main — il reste enfermé.

On n'a pas de vrai boîtier ici, alors on utilise **SoftHSM2** : une implémentation
logicielle de la norme **PKCS#11** (l'interface standard des HSM), parfaite pour
apprendre les gestes exacts d'une **cérémonie de clés** — la procédure, souvent
filmée et accompagnée de témoins, par laquelle naît la clé d'une CA racine.

Au programme :
1. préparer le HSM (créer un *token*, le compartiment qui contiendra la clé) ;
2. **générer la clé de la CA racine directement dans le HSM** ;
3. **prouver** qu'elle ne peut pas en sortir, puis signer le certificat racine *via* le HSM ;
4. prendre du recul sur la cérémonie de clés et la protection des clés de CA.

> L'environnement (SoftHSM2 + OpenSC + engine OpenSSL) s'installe pendant cette intro.
> Patiente la fin de l'installation avant de passer à l'étape 1.

Durée estimée : 30 à 45 minutes. Prérequis : niveau 0 (PKI, CA, clé privée, certificat racine).
