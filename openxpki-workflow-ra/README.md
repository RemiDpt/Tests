# Scénario Killercoda — OpenXPKI (workflow RA avec interface web)

Quatrième lab du parcours PKI. Prérequis pédagogique : niveau 0 (step-ca-lab).

## Idée
La séparation des rôles : le demandeur soumet une CSR, un opérateur RA l'approuve
dans l'interface web, la CA émet. L'apprenant joue les deux rôles (`bob` puis
`raop`, mot de passe `openxpki` — comptes de la config de démo).

## Structure
```
openxpki-workflow-ra/
├── index.json        # setup.sh en FOREGROUND (install longue : annoncée dans l'intro)
├── setup.sh          # docker-compose officiel openxpki-docker + config communautaire
├── intro.md
├── step1/  text.md + verify.sh   # pile docker + pont socat HTTP->HTTPS + UI (TRAFFIC_HOST1_8888)
├── step2/  text.md + verify.sh   # CSR openssl + soumission dans l'UI (verify léger)
├── step3/  text.md + verify.sh   # approbation RA + rapatriement du PEM (verify léger)
├── step4/  text.md               # séparation des rôles, quatre yeux, CRR
└── finish.md
```

## Choix de design
- **Verify volontairement légers** (option validée) : les actions décisives se
  passent dans l'UI, les verify contrôlent ce qui est observable côté terminal
  (CSR valide, PEM rapatrié émis par la CA de démo).
- Le PEM émis est recopié à la main dans le terminal : assumé, ça force l'apprenant
  à manipuler le certificat.

## Points fragiles à tester en live (nombreux sur ce lab)
- **Docker + docker-compose (binaire à tiret, pas le plugin v2) présents** sur
  l'image ubuntu de Killercoda — confirmé en live : c'est `docker-compose` qui
  fonctionne, garde-fou apt dans setup.sh ;
- **durée du setup en foreground** : pull des images + healthchecks en cascade +
  sampleconfig.sh — si trop long pour Killercoda, envisager un découpage ;
- ressources de la VM (MariaDB + serveur Perl + Apache) ;
- l'injection scriptée de `cli.yaml` (clé publique indentée) et du secret
  `##SVAULTKEY##` dans `crypto.yaml` (sed sur le placeholder de la branche
  community) ;
- **accès à l'UI = LE point sensible.** L'UI OpenXPKI n'est servie qu'en **HTTPS**
  (port conteneur 443 → hôte 8443 ; le port 80/8080 fait un 301 vers HTTPS, donc
  inutilisable). Or le proxy Killercoda ne parle qu'en **HTTP** au backend
  (cf. doc officielle « Services need to be accessible via HTTP and not HTTPS »).
  Solution retenue : un **pont socat** sur le port `8888` (HTTP en entrée →
  `OPENSSL-CONNECT` vers `127.0.0.1:8443`), lancé en tâche de fond à l'étape 1, et
  le lien pointe vers `{{TRAFFIC_HOST1_8888}}/webui/index/`. À VALIDER EN LIVE :
  que Killercoda route bien un port arbitraire (8888) et que le pont tient la
  navigation de l'UI (XHR/JSON, cookies). Alternative si le pont échoue :
  réécrire le vhost Apache pour servir `/webui/` en clair sur le port 80
  (plus invasif, cookies « secure » à neutraliser) ;
- les **libellés exacts des menus** de l'UI aux étapes 2 et 3 (« Request new
  certificate », choix du profil, paste PKCS#10, bouton d'approbation) — rédigés
  d'après la doc, à confronter à l'UI réelle ;
- le profil TLS Server de la config de démo accepte bien une CSR avec
  `CN=serveur.lab.local`.
