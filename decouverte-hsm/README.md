# Scénario Killercoda — Cérémonie de clés avec un HSM (SoftHSM2/PKCS#11)

Lab du parcours PKI. Prérequis : les bases (clé privée, CA, racine).

## Idée
Mettre en scène une cérémonie de clés : la clé de la CA racine est générée DANS un HSM
(SoftHSM2), prouvée non extractible, et utilisée pour signer le certificat racine sans
jamais quitter le module. Le cran de protection des clés de CA, fil rouge « robustesse ».

## Pourquoi PAS step-ca ici
Le binaire step-ca standard (celui des `.deb` des autres labs) ne supporte PAS PKCS#11 :
il faut une compilation CGO ou l'image Docker `smallstep/step-ca:hsm`. Trop fragile pour
le pattern apt du parcours. On démontre donc la cérémonie avec SoftHSM2 + OpenSSL
(engine PKCS#11), 100 % paquets apt. Le message pédagogique (clé née et gardée dans le
HSM) est identique.

## Structure
```
decouverte-hsm/
├── index.json        # setup.sh en FOREGROUND
├── setup.sh          # apt : softhsm2, opensc, libengine-pkcs11-openssl
├── intro.md
├── step1/  text.md + verify.sh   # init du token SoftHSM2
├── step2/  text.md + verify.sh   # génération de la clé DANS le HSM (pkcs11-tool)
├── step3/  text.md + verify.sh   # non-extraction + signature racine via engine OpenSSL
├── step4/  text.md               # cérémonie de clés, ANSSI, récap du parcours
└── finish.md
```

## ⚠️ TOUT est à tester en live (je n'ai rien pu exécuter)
Par ordre de risque décroissant :
1. **step3 — `openssl req -engine pkcs11 -keyform engine`** : LE point fragile.
   L'engine PKCS#11 diffère entre OpenSSL 1.1 (syntaxe `-engine`) et OpenSSL 3
   (engine déprécié → possible `pkcs11-provider` ou config `openssl.cnf`). Peut exiger
   `export PKCS11_MODULE_PATH=$MODULE` ou que SoftHSM2 soit enregistré dans p11-kit
   (`p11-kit list-modules`). Selon la version d'Ubuntu de l'image Killercoda.
2. **Noms de paquets apt** : `softhsm2`, `opensc`, `libengine-pkcs11-openssl` —
   à confirmer sur la version d'Ubuntu cible.
3. **Chemin du module** `libsofthsm2.so` : détecté via `ls /usr/lib/softhsm/... /usr/lib/*/softhsm/...`.
   Si vide, `find / -name libsofthsm2.so`.
4. **step3 Preuve 1** : `pkcs11-tool --read-object --type privkey` DOIT échouer
   (clé sensible/non extractible) — comportement à confirmer.
5. **`--addext`** sur `openssl req` (basicConstraints/keyUsage) : requiert OpenSSL ≥ 1.1.1.
6. Persistance de `$MODULE` entre blocs `{{exec}}` d'une même étape : ré-exporté en tête
   de chaque étape par sécurité.

## Décision de conception
Lab validé par l'utilisateur (option « Cérémonie SoftHSM2 + OpenSSL ») après étude de
faisabilité : la voie step-ca + PKCS#11 a été écartée (build CGO/Docker hsm trop fragile).
