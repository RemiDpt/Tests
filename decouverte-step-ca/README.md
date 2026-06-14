# Scénario Killercoda — [DECOUVERTE] [Step-ca] première autorité

Premier lab d'un parcours de formation PKI pratique et gratuit.

## Structure
```
decouverte-step-ca/
├── index.json        # définition du scénario (intro / steps / finish / backend)
├── setup.sh          # installe step + step-ca (FOREGROUND : install garantie avant l'étape 1)
├── intro.md
├── step1/  text.md + verify.sh   # générer la PKI
├── step2/  text.md + verify.sh   # démarrer la CA
├── step3/  text.md + verify.sh   # émettre un certificat
├── step4/  text.md               # inspecter et comprendre
└── finish.md
```

## Déployer sur Killercoda
1. Créer un compte créateur sur https://killercoda.com (connexion via GitHub).
2. Mettre ces fichiers dans un dépôt GitHub public (ce dossier à la racine ou
   dans un sous-dossier dédié).
3. Dans le profil créateur Killercoda, ajouter le dépôt : les scénarios sont
   détectés automatiquement à chaque push.
4. Tester le scénario, vérifier chaque bouton **Check**, puis publier.

## Backend
`backend.imageid` = `ubuntu` : machine Ubuntu simple, suffisante pour step-ca
(binaire Go léger). Pas besoin de Docker ni de Kubernetes pour cette brique.

## À adapter
- Le mot de passe `LabPKI-non-securise` est volontairement trivial (lab jetable).
- Les `verify.sh` renvoient `exit 0` quand l'étape est réussie, `exit 1` sinon
  avec un message d'aide affiché à l'apprenant.
