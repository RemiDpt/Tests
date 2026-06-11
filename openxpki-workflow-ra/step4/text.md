# Étape 4 — Comprendre la séparation des rôles

Reprends le fil de ce qui vient de se passer :

| Rôle | Qui | Ce qu'il peut faire | Ce qu'il ne peut PAS faire |
|------|-----|--------------------|-----------------------------|
| Demandeur | `bob` | générer sa clé, soumettre une CSR | approuver, émettre |
| Opérateur RA | `raop` | examiner, approuver ou rejeter | demander pour lui-même* |
| CA | le serveur | signer ce que la RA a approuvé | décider seul |

*\*dans une PKI bien configurée : un même humain ne doit pas cumuler demande et
approbation — c'est le principe des « quatre yeux ».*

**Pourquoi ce modèle subsiste**, alors que les labs précédents montraient tout
l'inverse (automatisation maximale) :
- pour des **identités de personnes** (badge, signature, chiffrement), un contrôle
  d'identité humain ou organisationnel reste souvent exigé ;
- pour des certificats **à fort enjeu** ou réglementés, la traçabilité de la
  décision (qui a approuvé, quand, sur quelle base) fait partie des exigences —
  c'est le sens des référentiels d'exigences type RGS de l'ANSSI ;
- le workflow OpenXPKI **journalise chaque transition** : la base de données est
  aussi un registre d'audit.

**Ce que ça coûte** : du délai et des humains. D'où la règle pratique — workflow RA
pour les identités fortes et les cas à enjeu, automatisation (ACME, secrets
dynamiques) pour les machines en volume. Les deux modèles coexistent dans une même
organisation.

**La révocation aussi est un workflow** : dans l'interface, un certificat émis
propose une action de demande de révocation (CRR — *Certificate Revocation
Request*), qui suit le même chemin demande → approbation → publication de CRL.
Si tu as le temps, lance-en une sur ton certificat et observe le parcours.

Prochaine étape du parcours : **EJBCA**, où ces concepts (profils, rôles,
enrôlement) passent à l'échelle d'une PKI d'entreprise complète — avec l'ouverture
post-quantique en ligne de mire.
