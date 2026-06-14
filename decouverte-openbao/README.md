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

## Points fragiles à tester en live
- **setup.sh** : la version épinglée `BAO_VERSION` et l'URL du .deb sur les
  releases GitHub (pattern `bao_<version>_linux_amd64.deb`) ;
- la vitesse de téléchargement des releases GitHub depuis Killercoda ;
- les `export BAO_ADDR/BAO_TOKEN` de l'étape 1 valent pour LE terminal courant :
  si l'apprenant ouvre un autre onglet, les variables manquent (les verify.sh, eux,
  les redéfinissent) ;
- l'endpoint CRL `/v1/pki/crl/pem` (utilisé à l'étape 4).
