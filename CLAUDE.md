# labPKI — Plateforme de formation PKI interactive

## Projet
Parcours de labs Killercoda gratuits et communautaires pour apprendre les PKI en pratique, avec un fil rouge crypto-agilité / post-quantique. Public : ingénieurs cyber/DevOps francophones. Contenu 100% générique et open source.

## Structure du repo
Chaque scénario est un dossier au TOP LEVEL du repo, contenant un index.json. Patron type (voir step-ca-lab/ et step-ca-acme-cicd/) :
- index.json (intro avec setup.sh en foreground, steps avec verify, finish, backend imageid ubuntu)
- setup.sh : installe les outils via .deb/apt, crée /root/.step-password, touch /root/.setup-done
- intro.md, finish.md
- step1..stepN/ : chacun un text.md (avec blocs ```{{exec}}```) et un verify.sh (exit 0 = réussi)

## Conventions
- Tout le contenu pédagogique en français ; tutoiement de l'apprenant, ton direct et engageant.
- Mot de passe de lab trivial assumé (jamais en prod).
- Référencer ANSSI plutôt que NIST quand pertinent.

## Garde-fous STRICTS
- Ne JAMAIS toucher aux accès, tokens, clés, ou réglages git/GitHub.
- Ne JAMAIS faire de git push. Tu peux préparer des commits, mais c'est MOI qui valide et pousse.
- Ne JAMAIS ajouter de mention "Co-authored-by" ni "Generated with Claude Code" dans les commits.
- Zéro contexte interne entreprise/client dans les fichiers (projet public).
- Toujours me montrer ce que tu vas créer/modifier avant de le faire.

## Roadmap des labs
Faits : step-ca niveau 0 (PKI de base), niveau 1 (ACME en CI/CD).
À venir : OpenBao (certs courts), OpenXPKI (workflow RA avec UI), EJBCA (PKI entreprise + PQC).
