# Scénario Killercoda — [DECOUVERTE] [Step-ca] token court en CI/CD

Lab du parcours PKI. Prérequis pédagogique : les bases (decouverte-step-ca).

## Idée
Un job de pipeline obtient (et renouvelle) son certificat automatiquement grâce à un
**token court** émis par un orchestrateur de confiance — le modèle de l'identité de
charge de travail, sans secret long-terme stocké dans le runner.

> Ce lab a remplacé une version ACME : dans Killercoda, step-ca ne peut pas se
> reconnecter au demandeur pour valider un challenge (http-01 comme tls-alpn-01
> échouent sur « could not connect to validation target »). Le modèle token court ne
> demande aucune reconnexion réseau — il fonctionne, et colle mieux au CI/CD interne.

## Structure
```
decouverte-step-ca-token/
├── index.json        # setup.sh en FOREGROUND (install garantie avant l'étape 1)
├── setup.sh          # step + step-ca (plus de certbot, plus de /etc/hosts)
├── intro.md
├── step1/  text.md + verify.sh   # créer la PKI (provisioner JWK admin)
├── step2/  text.md + verify.sh   # démarrer la CA, health check
├── step3/  text.md + verify.sh   # token court + émission via --token
├── step4/  text.md               # rejouer le cycle, OIDC/renew, crypto-agilité
└── finish.md
```

## Déploiement
Mettre ce dossier au top level du repo Killercoda (à côté de decouverte-step-ca/),
committer, pousser. Le webhook synchronise.

## Mécanique centrale (validée en live)
```
TOKEN=$(step ca token <nom> --provisioner admin --password-file /root/.step-password \
  --ca-url https://localhost:4443 --root $(step path)/certs/root_ca.crt)
step ca certificate <nom> cert.pem key.pem --token $TOKEN \
  --ca-url https://localhost:4443 --root $(step path)/certs/root_ca.crt
```
Token et émission doivent être lancés dans le MÊME terminal (variable `$TOKEN`).

## Points à confirmer en live
- step4 : le `--force` ajouté à `step ca certificate` pour écraser cert.pem/key.pem
  lors du rejeu (à vérifier : nom exact du flag d'écrasement sur cette version) ;
- step4 : la mention `step ca renew` (mTLS) n'est pas exécutée dans le lab, juste
  citée — à valider si un jour on en fait une étape ;
- `pgrep -x step-ca` disponible (utilisé par step2/verify.sh, normalement oui).
