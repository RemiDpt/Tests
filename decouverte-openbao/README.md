# Scénario Killercoda — OpenBao (certificats courts/dynamiques)

Lab du parcours PKI. Prérequis pédagogique : les bases (decouverte-step-ca).

## Idée
Le certificat devient un **secret dynamique** : généré à la demande par le moteur
PKI d'OpenBao, valable quelques minutes, rarement révoqué (durées courtes plutôt
que révocation). Angle crypto-agilité du parcours.

## Structure
```
decouverte-openbao/
├── index.json        # setup.sh en FOREGROUND (install garantie avant l'étape 1)
├── setup.sh          # OpenBao (.deb GitHub releases, version épinglée) + jq
├── intro.md
├── step1/  text.md + verify.sh   # démarrer OpenBao en mode dev
├── step2/  text.md + verify.sh   # monter le moteur PKI, CA racine, rôle
├── step3/  text.md + verify.sh   # émettre un certificat de 2 minutes
├── step4/  text.md               # révocation par serial, CRL, crypto-agilité
└── finish.md
```

## Déploiement
Mettre ce dossier au top level du repo Killercoda, committer, pousser.
