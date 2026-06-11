# Scénario Killercoda — EJBCA (PKI d'entreprise + post-quantique)

Cinquième et dernier lab du parcours PKI. Prérequis : niveau 0 ; OpenXPKI recommandé.

## Idée
La PKI d'entreprise complète : CA racine en CLI, enrôlement d'entité finale
(keystore P12), puis création d'une **CA ML-DSA** (post-quantique, EJBCA CE ≥ 9.1)
— l'aboutissement du fil rouge crypto-agilité.

## Structure
```
ejbca-pki-entreprise/
├── index.json        # setup.sh en FOREGROUND (démarrage EJBCA 2-5 min, annoncé)
├── setup.sh          # docker run keyfactor/ejbca-ce, TLS_SETUP_ENABLED=simple
├── intro.md
├── step1/  text.md + verify.sh   # healthcheck ALLOK + tour de l'Admin UI
├── step2/  text.md + verify.sh   # ca init LabRootCA (CLI), listcas
├── step3/  text.md + verify.sh   # addendentity + batch + P12 inspecté
├── step4/  text.md               # CA ML-DSA via l'UI, inspection openssl, hybridation
└── finish.md
```

## Points fragiles à tester en live
- **RAM de la VM Killercoda** : EJBCA demande ≥ 1 Go pour lui seul (doc officielle :
  2 cœurs / 1 Go minimum) — c'est LE risque principal de ce lab ;
- durée du démarrage en foreground (boucle d'attente sur le healthcheck, 90×5 s max) ;
- l'URL du healthcheck `/ejbca/publicweb/healthcheck/ejbcahealth` et la réponse `ALLOK` ;
- le chemin CLI dans le conteneur `/opt/keyfactor/bin/ejbca.sh` ;
- la syntaxe exacte de `ca init` (vérifiée sur la doc, mais l'ordre des arguments
  positionnels et `--policy 2.5.29.32.0` sont à confronter à la version de l'image) ;
- les options de `ra addendentity` (`--type 1`, `--token P12`) et la nécessité
  réelle de `ra setclearpwd` avant `batch` ;
- le répertoire de sortie du batch `/opt/keyfactor/p12/` ;
- la syntaxe de `ca getcacert --caname ... -f ...` (step4) ;
- les libellés de l'Admin UI pour créer la CA ML-DSA (step4) et la présence
  effective de ML-DSA-65 dans l'image `keyfactor/ejbca-ce` (nécessite CE ≥ 9.1) ;
- le lien `{{TRAFFIC_HOST1_443}}/ejbca/adminweb/` derrière le proxy Killercoda.
