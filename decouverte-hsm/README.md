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
