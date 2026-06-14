# labPKI — Plateforme de formation PKI interactive

## Projet
Parcours de labs Killercoda gratuits et communautaires pour apprendre les PKI en pratique, avec un fil rouge crypto-agilité / post-quantique. Public : ingénieurs cyber/DevOps francophones. Contenu 100% générique et open source.

## Structure du repo
Chaque scénario est un dossier au TOP LEVEL du repo, contenant un index.json. Patron type (voir decouverte-step-ca/ et decouverte-step-ca-token/) :
- index.json (intro avec setup.sh en foreground, steps avec verify, finish, backend imageid ubuntu)
- setup.sh : installe les outils via .deb/apt, crée /root/.step-password, touch /root/.setup-done
- intro.md, finish.md
- step1..stepN/ : chacun un text.md (avec blocs ```{{exec}}```) et un verify.sh (exit 0 = réussi)

## Deux familles de labs
- **Labs "découverte"** (préfixe `decouverte-`) : guidés, pédagogiques, commandes fournies dans des blocs `{{exec}}`. C'est la voie d'apprentissage de référence — NE PAS les modifier sur le fond.
- **Labs "défi"** (préfixe `defi-`) : mêmes outils, mais l'apprenant doit RÉSOUDRE par lui-même. Au moins une étape non guidée (objectif posé, pas de solution donnée). Le verify.sh doit contrôler le RÉSULTAT réel (certificat conforme créé, demande non conforme rejetée…), pas qu'une commande a été tapée. Chaque étape de défi fournit un indice repliable + une solution de référence en fin d'étape.
- Migration des dossiers existants vers le préfixe `decouverte-` : à faire avec précaution (renommer un dossier change l'URL Killercoda et casse les liens déjà partagés) — à valider avant d'appliquer.

## Conventions
- Tout le contenu pédagogique en français ; tutoiement de l'apprenant, ton direct et engageant.
- Mot de passe de lab trivial assumé (jamais en prod).
- Référencer ANSSI plutôt que NIST quand pertinent.
- Tout accès à une UI/service web depuis le navigateur doit utiliser `{{TRAFFIC_HOSTx_PORT}}`, jamais `localhost` (qui pointe vers la machine de l'apprenant, pas la VM). Le port doit être exposé vers l'hôte (mapping docker-compose). Le proxy Killercoda ne parle qu'en HTTP au backend : si le service n'est servi qu'en HTTPS, intercaler un pont HTTP→HTTPS (`socat TCP-LISTEN:PORT,fork,reuseaddr OPENSSL-CONNECT:127.0.0.1:PORT_TLS,verify=0`) et pointer le lien sur le port HTTP du pont. NB : `localhost`/`127.0.0.1` reste correct pour un CLI qui parle à un service local sur la VM (ex. `step --ca-url`, `bao` BAO_ADDR).

## Garde-fous STRICTS
- Ne JAMAIS toucher aux accès, tokens, clés, ou réglages git/GitHub.
- Ne JAMAIS faire de git push. Tu peux préparer des commits, mais c'est MOI qui valide et pousse.
- Ne JAMAIS ajouter de mention "Co-authored-by" ni "Generated with Claude Code" dans les commits.
- Zéro contexte interne entreprise/client dans les fichiers (projet public).
- Toujours me montrer ce que tu vas créer/modifier avant de le faire.

## Roadmap des labs
Faits (famille découverte) : step-ca niveau 0 (PKI de base), niveau 1 (token court CI/CD), OpenBao (certs courts).
Ajouts découverte VALIDÉS EN LIVE (juin 2026, comblent les 2 plus gros écarts cours/défi) : decouverte-step-ca étape 4 « Émettre un certificat SSH » (init niveau 0 passé en `--ssh`, étape ancienne « Inspecter » devenue step5) ; decouverte-openbao étape 4 « policy + AppRole » (étape ancienne « Révoquer » devenue step5). Les deux testés sur VM Ubuntu vierge : SSH → `step ca init --ssh` non-interactif OK + provisioner JWK `admin` émet un user cert (Key ID + Principals = `deploy`), verify PASS ; AppRole → émission OUI / création de rôle refusée 403 / verify PASS. Bannières « À TESTER » retirées.
decouverte-step-ca-token étape 4 « ACME : le renouvellement qui se déclenche tout seul » (provisioner ACME + acme.sh HTTP-01 standalone, /etc/hosts acme.lab.local→127.0.0.1, CURL_CA_BUNDLE=root_ca.crt ; étape ancienne « Automatiser » devenue step5) : VALIDÉ EN LIVE (juin 2026, VM vierge) — `step ca provisioner add acme` + restart OK, URL `/acme/acme/directory` OK, acme.sh standalone :80 via socat OK, confiance TLS par CURL_CA_BUNDLE sans `--insecure`, renouvellement forcé OK, verify PASS (cert dans `acme.lab.local_ecc/`). Bannière retirée.
Niveau 2 (decouverte-hsm) : cérémonie de clés avec SoftHSM2/PKCS#11 + OpenSSL — généré, À TESTER EN LIVE (engine PKCS#11 OpenSSL 1.1 vs 3 = point fragile). N'utilise PAS step-ca (binaire standard sans PKCS#11) : voie SoftHSM2 + OpenSSL retenue.
Faits (famille défi) : defi-step-ca (hiérarchie hors-ligne, certificat SSH, politique d'autorité qui refuse, template imposé) et defi-openbao (rôle contraint, révocation+CRL, AppRole, intermédiaire signée par racine externe). Générés, À TESTER EN LIVE (cf. points fragiles ci-dessous).
defi-step-ca = EN CHANTIER (titre + bannières) tant que le refus du défi 3 n'est pas reproduit en live.
LEÇON step-ca (confirmée doc officielle) : sur step-ca AUTO-HÉBERGÉ, les policies ne s'appliquent qu'au niveau `authority.policy` ; une `policy` posée sur une provisioner est une fonctionnalité hébergée (Certificate Manager) et est SILENCIEUSEMENT IGNORÉE en self-hosted → ne jamais s'y fier. Refus réel = `authority.policy.x509.allow.dns` (rejet à la signature). Réfs : smallstep.com/docs/step-ca/policies et /configuration.
LEÇON SSH (doc officielle) : `step ssh certificate` distingue `--provisioner-password-file` (auth provisioner) de `--password-file` (chiffrement de la clé générée) ; `--password-file` et `--no-password` sont incompatibles.
Points fragiles défi À TESTER : `step ca init --ssh` + émission `step ssh certificate` (combinaison des deux flags de mot de passe) ; `authority.policy.x509.allow.dns` + restart CA (refus effectif) ; `options.x509.templateFile` + syntaxe template + restart ; côté OpenBao : `pki_int/intermediate/set-signed`, `openssl x509 -req` avec process-substitution, persistance du serveur dev/env entre étapes.
OpenXPKI abandonné : serveur "unhealthy" sur Killercoda et UI HTTPS inexploitable derrière le proxy (même classe de blocage que l'accès UI Killercoda).
EJBCA abandonné : son Admin UI à authentification par certificat client est incompatible avec le proxy Killercoda.
