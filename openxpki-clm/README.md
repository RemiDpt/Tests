# OpenXPKI — gérer le **cycle de vie** des certificats, avec une vraie interface

> 🟢 **PARCOURS DÉCOUVERTE** — guidé, pas à pas.
>
> ⚠️ Ce lab ne tourne **pas** sur Killercoda : il a une interface web, et on la veut
> sans bidouille de proxy. Tu le lances **en local sur ta machine**, avec Docker, et tu
> ouvres la console dans ton navigateur. Compte une dizaine de minutes de mise en route.
>
> Deux façons de le lancer : **à la main avec Docker** (étapes ci-dessous) ou
> **tout-en-un avec Vagrant** (section [Variante : VM clé en main](#variante--vm-clé-en-main-vagrant)).

## Pourquoi ce lab

Jusqu'ici, le parcours t'a fait manipuler des **autorités de certification** : step-ca,
OpenBao. Une AC, ça **émet**. Mais dans une vraie boîte, le sujet quotidien n'est pas
« comment je signe un certificat », c'est « j'en ai des **milliers**, qui expirent à des
dates différentes, demandés par des gens différents — comment je **garde le contrôle** ».

Ça, c'est le métier d'un **CLM** (*Certificate Lifecycle Management*) : une couche de
**gestion** par-dessus l'AC. Demande, **approbation par une autorité d'enregistrement
(RA)**, émission, inventaire, surveillance de l'expiration, révocation. OpenXPKI est un
**trustcenter open source** qui fait tout ça avec une console web — exactement le chaînon
que le reste du parcours n'a pas encore montré.

Le fil rouge, toujours : un CLM, c'est aussi ce qui rend une **migration d'algorithme à
l'échelle du parc** pilotable (le jour où il faut tout réémettre sous une nouvelle AC,
par exemple vers des algorithmes **post-quantiques**). Le défi *réenrôlement* du parcours,
tu l'as fait en script ; ici, tu vois la console qui orchestrerait la même chose.

## Prérequis

- **Docker** + **Docker Compose v2** (`docker compose version`) ;
- `git` et `openssl` ;
- les ports **8080** et **8443** libres sur ta machine ;
- ~2 Go de RAM dispo pour les conteneurs.

Tout se passe dans ce dossier (`openxpki-clm/`). Les éléments téléchargés/générés à
l'étape 1 (`openxpki-config/`, `config/`) sont volontairement **ignorés par git** : ils
contiennent une clé et de la config locale, ils n'ont rien à faire dans le dépôt.

---

## 1. Récupérer la configuration et les clés

OpenXPKI se configure par fichiers. On part de la configuration de référence du projet
(branche `community`) et on génère deux secrets de lab.

```bash
cd openxpki-clm

# Configuration de référence d'OpenXPKI
git clone https://github.com/openxpki/openxpki-config.git \
  --single-branch --branch=community

# Clé du client en ligne de commande
mkdir -p config
openssl ecparam -name prime256v1 -genkey -noout -out config/client.key
chmod 644 config/client.key

# Clé de chiffrement du coffre interne (svault)
KEY=$(openssl rand -hex 32)
sed -i "s|.*##SVAULTKEY##.*|        value: $KEY|" \
  openxpki-config/config.d/system/crypto.yaml
echo "svault = $KEY"
```

La configuration `community` laisse un emplacement `##SVAULTKEY##` dans
`openxpki-config/config.d/system/crypto.yaml` (groupe `svault`) : la commande ci-dessus le
remplace par une vraie clé hexadécimale de 64 caractères.

> **Garde une copie de cette clé** (celle affichée par `echo svault = …`). C'est elle qui
> chiffre les données sensibles d'OpenXPKI : si tu la perds, tu perds l'accès à ce qui a
> été chiffré. En lab c'est sans conséquence ; le réflexe, lui, est à prendre dès
> maintenant.

## 2. Démarrer la stack

```bash
docker compose up -d web
```

Cette commande lance, dans l'ordre et en attendant que chacun soit « healthy » : la base
**MariaDB**, le **serveur** OpenXPKI, le **client**, puis le **serveur web** (Apache).
Suis l'avancement :

```bash
docker compose ps
docker compose logs -f server   # Ctrl-C pour sortir
```

## 3. Initialiser la PKI de démonstration

Le dépôt fournit un script qui génère une hiérarchie d'AC d'exemple et le realm `democa` :

```bash
docker compose exec -u pkiadm server /bin/bash /etc/openxpki/contrib/sampleconfig.sh
```

## 4. Ouvrir la console

Va sur **`https://localhost:8443/webui/index/`**.

Le certificat TLS de la console est **auto-signé** (c'est une démo) : ton navigateur va
râler, accepte l'exception. C'est, au passage, une bonne illustration de ce que vit un
poste sans la bonne racine dans son magasin de confiance.

**Comptes de démonstration** (mot de passe `openxpki` pour tous) :

| Identifiant | Rôle | Sert à |
|---|---|---|
| `alice`, `bob` | Utilisateur | demander des certificats |
| `raop`, `rob`, `rose` | Opérateur **RA** | approuver, révoquer |
| `caop` | Opérateur **CA** | administration de l'autorité |

Mots de passe triviaux **assumés** : c'est un lab, jamais une prod.

---

## Le parcours

L'idée n'est pas de cliquer au hasard, mais de suivre **un certificat sur tout son cycle
de vie** : demandé par l'un, approuvé par l'autre, inventorié, puis révoqué.

### A. Demander un certificat (en tant qu'`alice`)

1. Connecte-toi en **`alice`** / `openxpki`.
2. Menu **Request → Request new certificate** (Demander un nouveau certificat).
3. Choisis un profil **serveur TLS**, puis renseigne un nom, par exemple
   `CN = test.lab.local`. Laisse OpenXPKI générer la clé.
4. Valide jusqu'à voir l'état **PENDING** (en attente).

> Note ce qui vient de se passer : `alice` **ne s'est rien délivré**. Elle a déposé une
> **demande**. Dans une PKI sérieuse, demandeur et émetteur ne sont jamais la même
> personne — c'est la séparation des rôles, et c'est tout l'intérêt d'une RA.

### B. Approuver (en tant qu'opérateur RA `raop`)

1. **Déconnecte-toi**, reconnecte-toi en **`raop`** / `openxpki`.
2. Va dans **Home / My tasks** (ou la recherche de workflows) : la demande de `alice`
   t'attend.
3. Ouvre-la, lis ce qui est demandé, puis clique sur **Approve**.
4. Quelques secondes plus tard, le certificat est **émis**.

C'est **le** geste qui distingue un CLM d'une simple AC : entre la demande et l'émission,
il y a un **point de contrôle humain (ou automatisable par politique)**. C'est là qu'on
refuse un nom interdit, qu'on vérifie un périmètre, qu'on trace qui a validé quoi.

### C. Inventorier et surveiller l'expiration

1. Toujours en opérateur, ouvre la **recherche de certificats** (Search → Certificates).
2. Retrouve `test.lab.local`, ouvre sa fiche : sujet, émetteur, **dates de validité**,
   statut, historique du workflow.

C'est la vue « **gestion de parc** » : sur des milliers de certificats, c'est ce tableau
qui te dit *lequel expire la semaine prochaine*. L'expiration surprise d'un certificat,
c'est la panne classique qui fait tomber un service un dimanche soir — un CLM existe
d'abord pour que ça **n'arrive pas**.

### D. Révoquer (fin de vie)

1. Sur la fiche du certificat, déclenche une **révocation** (Revoke), choisis un motif
   (par ex. *keyCompromise*), confirme.
2. OpenXPKI place le certificat en révocation et l'intègre à la **CRL** (liste de
   révocation) publiée par l'AC.

Émettre, c'est la moitié du travail. **Pouvoir retirer la confiance** accordée à un
certificat compromis — et le **prouver** via la CRL/OCSP — c'est l'autre moitié, celle
qu'on oublie jusqu'au jour de l'incident.

### E. Pour aller plus loin

- **Les interfaces d'enrôlement automatisé** d'OpenXPKI : **SCEP**, **EST**, **ACME**.
  C'est le même cycle de vie, mais déclenché par les machines elles-mêmes, sans clic — à
  rapprocher du lab ACME de `decouverte-step-ca-token`.
- **La crypto-agilité** : imagine que la politique impose demain un nouvel algorithme
  (vers le **post-quantique**). Depuis cette console, tu **vois** le parc, tu **filtres**
  ce qui doit être réémis, tu **réenrôles** sous la nouvelle AC. C'est exactement le défi
  `defi-step-ca-reenrolement`, mais piloté depuis une interface plutôt qu'en script.

---

## Variante : VM clé en main (Vagrant)

Si tu veux **éviter toute installation manuelle** — ou préparer un `.ova` à distribuer en
atelier — un `Vagrantfile` est fourni dans ce dossier. Il construit une VM Ubuntu,
installe Docker, déroule **les étapes 1 à 3 tout seul**, et tu n'as plus qu'à ouvrir la
console.

Prérequis sur ton poste : **Vagrant + VirtualBox**. Puis, depuis `openxpki-clm/` :

```bash
vagrant up          # construit la VM et déploie OpenXPKI (quelques minutes)
# ... puis ouvre https://localhost:8443/webui/index/
```

Le `Vagrantfile` est la **recette** (texte, versionnée), pas l'image binaire. Pour
produire un `.ova` distribuable à partir de la VM (poste sans Vagrant, juste VirtualBox) :

```bash
vagrant halt
VBoxManage export openxpki-clm -o openxpki-clm.ova
```

> L'`.ova` fige la clé `svault` et les comptes de démo : **démonstration uniquement**, et
> ne le versionne pas dans git (il pèse plusieurs Go — `*.ova` est déjà dans le
> `.gitignore`). Héberge-le hors du dépôt (release / lien externe).

Pour tout arrêter : `vagrant halt` (éteindre) ou `vagrant destroy` (supprimer la VM).

## Dépannage

- **`docker compose ps` montre `server` ou `web` en `unhealthy`** : regarde
  `docker compose logs server`. Cause fréquente en lab : le **`svault`** de
  `crypto.yaml` (étape 1) non renseigné ou mal collé.
- **Port déjà utilisé** (`8443`/`8080`) : change le mapping de gauche dans
  `docker-compose.yml` (par ex. `9443:443`) et utilise la nouvelle URL.
- **Avertissement TLS du navigateur** : normal (certificat auto-signé), accepte
  l'exception.
- **Le montage `/etc/timezone` échoue** (selon l'OS hôte, typiquement certains
  environnements) : commente les deux lignes `timezone`/`localtime` du service `server`
  dans `docker-compose.yml`.
- **Repartir de zéro** :
  ```bash
  docker compose down -v
  docker compose up -d web
  docker compose exec -u pkiadm server /bin/bash /etc/openxpki/contrib/sampleconfig.sh
  ```

## Arrêt et nettoyage

```bash
docker compose down -v          # arrête tout et supprime les volumes (données)
rm -rf openxpki-config config   # supprime la config et les clés locales
```

---

*Stack vendorisée depuis le projet officiel `openxpki/openxpki-docker`, images épinglées
à `whiterabbitsecurity/openxpki3:3.32.16`. Tout ici est prévu pour la **démonstration** :
mots de passe triviaux, secrets de base, TLS auto-signé — **jamais en production**.*
