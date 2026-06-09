# Scénario Killercoda — step-ca niveau 1 (ACME en CI/CD)

Deuxième lab du parcours PKI. Prérequis pédagogique : niveau 0 (step-ca-lab).

## Idée
Un job de pipeline obtient et renouvelle un certificat automatiquement via ACME
contre une CA step-ca interne — le modèle Let's Encrypt, sans secret ni humain.

## Structure
```
step-ca-acme-cicd/
├── index.json        # setup.sh en FOREGROUND (install garantie avant l'étape 1)
├── setup.sh          # step + step-ca + certbot + /etc/hosts
├── intro.md
├── step1/  text.md + verify.sh   # activer la provisioner ACME
├── step2/  text.md + verify.sh   # démarrer la CA, vérifier l'endpoint ACME
├── step3/  text.md + verify.sh   # le job CI obtient son cert via certbot
├── step4/  text.md               # renouvellement automatique + crypto-agilité
└── finish.md
```

## Déploiement
Mettre ce dossier au top level du repo Killercoda (à côté de step-ca-lab/),
committer, pousser. Le webhook synchronise.

## Point fragile à tester en live
Le challenge HTTP-01 suppose que step-ca peut joindre `ci-runner.lab.local:80`
(résolu via /etc/hosts vers 127.0.0.1). Si certbot échoue à la validation, c'est
quasi toujours : la CA pas démarrée, le port 80 occupé, ou l'entrée /etc/hosts absente.
