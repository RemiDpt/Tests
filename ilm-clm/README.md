# [DECOUVERTE] ★★★★ [ILM] Découverte, inventaire multi-AC et CBOM avec ILM (ex-CZERTAINLY)

**Ce que tu montes :** une vraie plateforme de *Certificate Lifecycle Management* (CLM) — ILM, l'ex-CZERTAINLY — déployée en local sur Kubernetes (k3s) avec Helm. Tu vas l'utiliser pour **découvrir** des certificats sur le réseau, les **inventorier** indépendamment de l'AC qui les a émis, et produire un **CBOM** (inventaire cryptographique) — la brique qui rend une migration post-quantique *pilotable à l'échelle d'un parc*.

---

> ⚠️ **Ce lab tourne EN LOCAL, pas sur Killercoda.** Il monte une interface web *et* un cluster Kubernetes léger sur ta machine. Killercoda ne convient pas (UI HTTPS derrière proxy + ressources). Compte **45 à 75 min** de mise en route la première fois (téléchargement des images compris), puis ~10 min pour le parcours.

> ⚠️ **Lab gourmand.** ILM n'est pas un `docker compose up`. Le chart parapluie tire ~24 sous-composants (cœur, UI, Keycloak, RabbitMQ, Kong, PostgreSQL, connecteurs de découverte…). Prévois **8–12 Go de RAM libres, 4 cœurs, 25 Go de disque**. C'est plus léger que l'ancienne appliance (12–16 Go) mais ça reste lourd comparé au lab OpenXPKI. Si ta machine est juste, fais d'abord le lab OpenXPKI pour la mécanique CLM, puis reviens ici.

---

## Pourquoi ce lab

Tu as déjà rencontré deux étages de la PKI dans le parcours :

- **L'autorité de certification** (step-ca, OpenBao) : ça *signe*. C'est la racine de confiance.
- **Le trust center** (OpenXPKI) : ça *émet à l'échelle* — autorité d'enregistrement (RA), profils, console d'opérateur.

ILM ajoute l'étage du dessus : la **couche CLM-produit** posée *au-dessus d'un parc multi-AC*. Son métier n'est pas d'émettre (le lab OpenXPKI l'a déjà montré), mais de **voir et piloter tout ce qui existe déjà**, quelle que soit l'AC :

- **Découverte** : retrouver les certificats là où ils vivent vraiment (un scan réseau, des journaux de transparence…), pas seulement ceux qu'on a soi-même émis.
- **Inventaire agnostique de l'émetteur** : un seul tableau qui mélange les certificats step-ca, EJBCA, Let's Encrypt, auto-signés… avec leur expiration, leur algorithme, leur émetteur.
- **CBOM** (*Cryptographic Bill of Materials*) : la liste de matériaux cryptographiques de ton parc, au format CycloneDX.

**Le fil rouge post-quantique.** Tu ne peux migrer vers la cryptographie post-quantique (PQC) que ce que tu *vois*. « Quels certificats de mon parc reposent sur RSA ou ECDSA, donc cassables par un calculateur quantique ? » — c'est exactement une requête CBOM. La découverte + l'inventaire + le CBOM, c'est ce qui transforme « migrer en PQC » d'un vœu pieux en un chantier mesurable. C'est le pont vers le défi [defi-step-ca-reenrolement](../defi-step-ca-reenrolement) (réenrôlement de masse / rotation d'AC).

Dans ce lab tu **ne réémets ni ne refais la RA** : on reste sur **découverte → inventaire → CBOM**.

---

## Prérequis

**Outils sur ta machine :**

| Outil | Rôle | Vérifier |
|---|---|---|
| `k3s` (ou minikube/kind) | cluster Kubernetes mono-nœud | `k3s --version` |
| `kubectl` | piloter le cluster | `kubectl version --client` |
| `helm` ≥ 3.8.0 | installer le chart ILM | `helm version` |
| `git` | cloner le dépôt de charts | `git --version` |
| `openssl`, `curl` | endpoint TLS de test + appels API | déjà présents en général |
| step-ca (du parcours) | l'AC qui a émis les certificats à découvrir | `step version` |

**Ressources :** 8–12 Go RAM libres, 4 cœurs, 25 Go disque (voir encart plus haut).

**Ports libres sur l'hôte :** `6443` (API k3s), et `8443` (qu'on utilisera en `port-forward` vers la console ILM). On **n'a pas besoin d'accès admin** ni de modifier `/etc/hosts` : on passe par `kubectl port-forward`, pas par un Ingress avec nom d'hôte.

**Versions épinglées dans ce lab :** chart ILM **2.18.0** (release de juin 2026 ; la branche `main` est en `2.18.1-develop`, à ne pas utiliser pour un lab reproductible). Images cœur depuis Docker Hub public `czertainly/*`.

---

## Étape 1 — Installer k3s (cluster mono-nœud)

k3s est la distribution Kubernetes la plus légère pour un lab. Un seul binaire, démarre en quelques secondes.

> **Lab only — sans serveur d'équilibrage ni Traefik externe** : on garde l'Ingress interne de k3s, on n'expose rien publiquement.

```bash
curl -sfL https://get.k3s.io | sh -
```

Récupère le kubeconfig pour que `kubectl`/`helm` parlent au cluster :

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$(id -u):$(id -g)" ~/.kube/config
export KUBECONFIG=~/.kube/config
```

Vérifie que le nœud est prêt :

```bash
kubectl get nodes
```

Tu dois voir une ligne `Ready`.

> **Alternatives à k3s :** `minikube start --memory=10240 --cpus=4` ou `kind create cluster`. Le reste du lab (Helm, values, parcours) est identique. k3s reste le plus économe en RAM.

---

## Étape 2 — Installer Helm

Helm est le gestionnaire de paquets de Kubernetes : il déploie ILM et ses ~24 sous-composants en une commande.

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

---

## Étape 3 — Récupérer le chart ILM (voie communautaire open source)

Le chart parapluie `ilm` vit dans le dépôt open source `CZERTAINLY/CZERTAINLY-Helm-Charts`. Ses sous-charts sont référencés en `file://` (chemins locaux) : on **clone le dépôt** puis on construit les dépendances localement.

```bash
git clone --branch Helm-Charts-2.18.0 --depth 1 \
  https://github.com/CZERTAINLY/CZERTAINLY-Helm-Charts.git
cd CZERTAINLY-Helm-Charts/charts/ilm
```

> **Tag de release.** Ce lab s'appuie sur le tag `Helm-Charts-2.18.0` (voir la page <https://github.com/CZERTAINLY/CZERTAINLY-Helm-Charts/releases>). Si le clone par tag échoue, clone `main` puis `git checkout` le tag voulu.

Construis les dépendances locales (résout les sous-charts `file://`) :

```bash
helm dependency build
```

Le chart parapluie `ilm` embarque déjà ce dont ce lab a besoin :

- `fe-administrator` (la console web), `keycloak-internal` (authentification), `api-gateway-kong` (passerelle), `pg-bouncer` (accès base) ;
- côté **découverte** : `network-discovery-provider`, `ct-logs-discovery-provider`, `cryptosense-discovery-provider` ;
- côté **conformité** : `x509-compliance-provider` ;
- des connecteurs d'AC (`ejbca-ng-connector`, `hashicorp-vault-connector`, `external-authority-provider`) — qu'on n'utilisera pas ici (pas d'émission).

---

## Étape 4 — Préparer une base PostgreSQL (dépendance externe)

ILM a besoin d'un **PostgreSQL 12+**. Le chart ne le fournit pas : on déploie une instance *de lab* dans le cluster.

> **Lab only — mot de passe trivial, pas de persistance durcie.** Jamais en prod.

```bash
helm install ilm-postgres oci://registry-1.docker.io/bitnamicharts/postgresql \
  --namespace ilm --create-namespace \
  --set auth.username=ilm \
  --set auth.password=ilm-lab-pwd \
  --set auth.database=ilm
```

> **Registre Bitnami.** Depuis fin 2025, Bitnami a déplacé une partie de ses images/charts (registre « bitnamilegacy » / `bitnamisecure`). Si le `helm install` ci-dessus échoue au *pull*, déploie un PostgreSQL minimal par un manifeste `kubectl` (image `postgres:16` officielle Docker Hub), ou consulte <https://github.com/bitnami/charts> pour le chemin courant. L'essentiel : un service PostgreSQL joignable dans le namespace `ilm`, avec un utilisateur/mot de passe/base connus.

Note l'adresse interne du service (typiquement `ilm-postgres-postgresql.ilm.svc.cluster.local:5432`) :

```bash
kubectl get svc -n ilm
```

---

## Étape 5 — Préparer `ilm-values.yaml`

Helm s'installe avec un fichier de valeurs qui dit *comment* configurer la plateforme. On part des valeurs par défaut du chart et on n'ajuste que l'essentiel.

```bash
helm show values . > ilm-values.yaml
```

Ouvre `ilm-values.yaml` et règle ces points (les **noms de clés exacts varient selon la version du chart** — repère-les dans le fichier généré et dans la doc « Configurable parameters ») :

- **Base de données** : hôte/port/utilisateur/mot de passe/base = ceux de l'étape 4.
- **Certificats de confiance** : la chaîne (racine + intermédiaire) de **ton step-ca**, pour qu'ILM fasse confiance aux certificats qu'il va découvrir. On la passera en `--set-file` (voir étape 6).
- **Accès web / super-administrateur** : le compte qui ouvrira la console.
- **Ingress** : on le **laisse désactivé** (on accède par `port-forward`, pas besoin de nom d'hôte ni d'accès admin).

Explication en langage simple de chaque bloc :

| Bloc de valeurs | À quoi ça sert | Réglage lab |
|---|---|---|
| `global.database.*` | où ILM stocke son inventaire | service PostgreSQL de l'étape 4 |
| `global.trusted.certificates` | quelles AC ILM considère comme de confiance | chaîne step-ca (en `--set-file`) |
| super-admin | le 1er compte humain | identifiant + secret de lab |
| `*.ingress.enabled` | exposer la console via un nom d'hôte | **false** (on fait du port-forward) |

> **Noms de clés DB / super-admin.** Ils varient selon la version du chart : repère les clés réelles dans le `ilm-values.yaml` généré par `helm show values` et dans <https://github.com/CZERTAINLY/CZERTAINLY-Helm-Charts/tree/main/charts/ilm/docs> (pages « Configurable parameters »). Ne devine pas : ce que le chart te montre fait foi.

Prépare la chaîne de confiance step-ca dans un fichier PEM (concatène racine + intermédiaire de ton step-ca) :

```bash
cat ~/.step/certs/root_ca.crt ~/.step/certs/intermediate_ca.crt > trusted-certificates.pem
```

---

## Étape 6 — Installer ILM et attendre les pods « healthy »

```bash
helm install ilm . \
  --namespace ilm \
  -f ilm-values.yaml \
  --set-file global.trusted.certificates=trusted-certificates.pem
```

> Le `--set-file global.trusted.certificates=...` injecte ta chaîne step-ca comme certificats de confiance : c'est confirmé par la doc d'installation Helm officielle.

Surveille la montée en charge (la première fois, le *pull* des images prend plusieurs minutes) :

```bash
kubectl get pods -n ilm -w
```

Attends que **tous** les pods soient `Running` et `READY` (colonne `1/1`, `2/2`…). `Ctrl-C` pour sortir du suivi. Un récapitulatif :

```bash
kubectl get pods -n ilm
```

> **Images privées / `imagePullSecrets`.** Le cœur (`czertainly/czertainly-core`) et le connecteur de découverte (`czertainly/czertainly-ip-discovery-provider`) sont sur **Docker Hub public**. Mais le README du chart prévient que *certains* sous-charts peuvent référencer des images de **dépôts privés**. Si un pod reste en `ImagePullBackOff`, liste les images réellement tirées et repère le registre fautif :
>
> ```bash
> helm template . -f ilm-values.yaml | grep -E '^\s*image:' | sort -u
> ```
>
> Pour chaque image suspecte, teste `docker pull <image>`. Si elle exige une authentification, c'est qu'elle n'est pas dans le périmètre librement tirable → crée un `imagePullSecret` avec tes identifiants, **ou** désactive ce sous-composant dans `ilm-values.yaml` s'il n'est pas indispensable au lab (pour notre parcours, seuls la console, le cœur, Keycloak, la base et le `network-discovery-provider` sont requis).

---

## Étape 7 — Ouvrir la console et créer le Super Administrateur

On expose la console sur `https://localhost:8443` via `port-forward` (aucun droit admin, aucun `/etc/hosts`).

Repère le service de la passerelle / console :

```bash
kubectl get svc -n ilm
```

Puis redirige-le (adapte le nom de service réel — souvent la passerelle Kong ou `fe-administrator`) :

```bash
kubectl port-forward -n ilm svc/<service-passerelle> 8443:443
```

Laisse ce terminal ouvert, et ouvre dans ton navigateur :

```
https://localhost:8443/administrator/
```

> ⚠️ **Certificat TLS auto-signé** (comme OpenXPKI) : ton navigateur affichera un avertissement de sécurité. Accepte l'exception — c'est attendu pour un lab.

**Création du Super Administrateur :** au premier accès, ILM te fait créer (ou importer) l'identité du super-administrateur.

> **Bootstrap du super-admin (voie communautaire).** Le mécanisme exact varie selon la version : authentification via **Keycloak** (embarqué par le sous-chart `keycloak-internal`) et/ou **certificat client super-admin** généré au premier démarrage. La procédure de référence est dans la doc « Quick start » (<https://docs.otilm.com/docs>) correspondant à la version 2.18.x ; suis les libellés affichés à l'écran.

---

## Le parcours — découverte, inventaire, CBOM

C'est le vrai bénéfice d'ILM, et ce qu'OpenXPKI ne montre pas. Chaque bloc suit le même rythme : **fais**, puis **observe**.

### A. Donner quelque chose à découvrir (réutiliser step-ca)

ILM n'a **pas de connecteur d'autorité natif pour step-ca** : on ne va donc pas le « brancher » comme AC. À la place, on **publie un certificat émis par step-ca sur un endpoint TLS**, et on laisse ILM le *découvrir* — c'est exactement le métier « inventaire agnostique de l'émetteur ».

**Fais :** émets un certificat de service avec ton step-ca (du parcours), puis sers-le sur un port TLS de lab.

```bash
step ca certificate "svc.lab.local" svc.crt svc.key \
  --provisioner admin --not-after 720h
```

Sers-le avec un serveur TLS minimal (lab only) :

```bash
openssl s_server -accept 8444 -cert svc.crt -key svc.key -www
```

> **Variante step-ca direct :** tu peux aussi pointer la découverte vers le port TLS de ton step-ca lui-même (son API est servie en HTTPS avec un certificat de sa propre chaîne). L'important est d'avoir **un endpoint TLS dont le certificat vient de step-ca**, joignable depuis le cluster.

> ⚠️ **Joignabilité depuis k3s :** le connecteur de découverte tourne *dans* le cluster. Il doit pouvoir atteindre ton endpoint. Avec k3s sur la même machine, l'IP de l'hôte (ex. l'adresse de `cni0`/`10.x`, ou l'IP LAN) est joignable depuis les pods ; `localhost` côté pod ne l'est pas. Récupère une IP atteignable avec `hostname -I` et utilise-la dans la découverte.

### B. Enregistrer le connecteur de découverte

**Fais :** dans la console, menu **Connectors** (à gauche) → **Add new connector**. Renseigne :

- **Connector name** : `Network Discovery Provider`
- **URL** : `https://network-discovery-provider-service:8080`
- **Authentication Type** : `No Auth`

Clique **Connect**, puis **Create**.

**Observe :** le connecteur apparaît avec ses fonctions (Function Group « Discovery Provider »). C'est lui qui sait scanner un endpoint et en extraire le certificat.

### C. Lancer une découverte sur la source step-ca

**Fais :** menu **Discovery** → **Add New Discovery**. Renseigne :

- **Discovery Name** : `Decouverte step-ca lab`
- **Discovery Provider** : `Network Discovery Provider`
- **Type** : `IP-Hostname`
- **IP/Hostname** : l'IP atteignable de ton endpoint (étape A)
- **Port** : `8444` (ou le port de ton endpoint step-ca)
- **All Ports?** : `No`

Clique **Create** pour lancer le scan.

**Observe :** la découverte passe en exécution puis se termine ; elle rapporte le(s) certificat(s) capté(s) sur l'endpoint.

### D. Parcourir l'inventaire

**Fais :** ouvre le menu des certificats (inventaire).

> Le libellé du menu inventaire varie selon la version (« Certificates » ou « Inventory »).

**Observe** — et c'est tout l'intérêt :

- le certificat `svc.lab.local` apparaît avec son **émetteur = ta chaîne step-ca**, sa **date d'expiration**, son **algorithme de clé** (RSA ou ECDSA selon ce que step-ca a émis) ;
- l'inventaire est **agnostique de l'émetteur** : relance une découverte sur un autre endpoint (un site public en `:443`, un certificat auto-signé…) et tu verras step-ca, une AC publique et un auto-signé **dans le même tableau**, triables par expiration et par algorithme. C'est la vue multi-AC qu'aucune AC seule ne te donne.

### E. CBOM — relier l'inventaire à la crypto-agilité PQC

Un **CBOM** est l'inventaire *cryptographique* de ton parc au format CycloneDX : il liste chaque algorithme et chaque certificat avec son niveau de résistance quantique. C'est la requête « qu'est-ce qui casse face à un quantique ? » rendue exploitable.

> **Génération auto du CBOM depuis l'inventaire.** Le composant officiel **CBOM-Repository** (`github.com/CZERTAINLY/CBOM-Repository`) sait *stocker, rechercher et versionner* des CBOM ; en revanche la génération automatique d'un CBOM depuis l'inventaire découvert n'est pas garantie dans l'UI cœur, et le CBOM-Repository est un **composant additionnel** (pas dans le parapluie par défaut). Vérifie sa présence/déploiement avant de t'appuyer dessus — d'où l'approche « CBOM buildable à la main » ci-dessous.

Voie buildable aujourd'hui : construire un CBOM correspondant aux certificats découverts, puis l'exploiter. Voici un **CBOM CycloneDX 1.6 minimal et valide** (testé : il parse, et un filtre `nistQuantumSecurityLevel == 0` isole bien RSA-2048, la cible de migration) :

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "serialNumber": "urn:uuid:9b2c1f7a-3e4d-4a6b-8c11-7f0e2a5d9c44",
  "version": 1,
  "metadata": {
    "timestamp": "2026-06-19T08:00:00Z",
    "component": { "type": "application", "name": "lab-parc-pki", "version": "1.0" }
  },
  "components": [
    {
      "type": "cryptographic-asset",
      "name": "svc.lab.local",
      "bom-ref": "crypto/certificate/svc.lab.local",
      "cryptoProperties": {
        "assetType": "certificate",
        "certificateProperties": {
          "subjectName": "CN = svc.lab.local",
          "issuerName": "CN = Lab Intermediate CA (step-ca)",
          "notValidBefore": "2026-06-19T08:00:00Z",
          "notValidAfter": "2026-07-19T08:00:00Z",
          "signatureAlgorithmRef": "crypto/algorithm/sha256-rsa",
          "subjectPublicKeyRef": "crypto/algorithm/rsa-2048",
          "certificateFormat": "X.509"
        }
      }
    },
    {
      "type": "cryptographic-asset",
      "name": "RSA-2048",
      "bom-ref": "crypto/algorithm/rsa-2048",
      "cryptoProperties": {
        "assetType": "algorithm",
        "algorithmProperties": {
          "algorithmFamily": "RSA",
          "primitive": "pke",
          "parameterSetIdentifier": "2048",
          "classicalSecurityLevel": 112,
          "nistQuantumSecurityLevel": 0
        },
        "oid": "1.2.840.113549.1.1.1"
      }
    },
    {
      "type": "cryptographic-asset",
      "name": "ML-DSA-65",
      "bom-ref": "crypto/algorithm/ml-dsa-65",
      "cryptoProperties": {
        "assetType": "algorithm",
        "algorithmProperties": {
          "algorithmFamily": "ML-DSA",
          "primitive": "signature",
          "nistQuantumSecurityLevel": 3
        },
        "oid": "2.16.840.1.101.3.4.3.18"
      }
    }
  ]
}
```

**Lecture du fil rouge PQC** — le champ qui décide de tout est `nistQuantumSecurityLevel` :

- `0` = **vulnérable au quantique** (RSA, ECDSA classique) → **à migrer** ;
- `3` = ML-DSA-65 (signature post-quantique, retenue par l'ANSSI parmi les schémas de référence) ;
- `5` = ML-KEM-1024 (encapsulation de clé post-quantique).

**Fais :** enregistre le bloc JSON ci-dessus dans un fichier `sample-cbom.json`, puis filtre sur les assets `nistQuantumSecurityLevel == 0` — tu obtiens la **liste de migration** de ton parc. Exemple local avec `jq` :

```bash
jq '[.components[] | select(.cryptoProperties.algorithmProperties.nistQuantumSecurityLevel == 0) | .name]' sample-cbom.json
```

**Observe :** seul `RSA-2048` ressort. À l'échelle d'un vrai parc, cette même requête te donne *tout ce qui doit passer en PQC* — c'est précisément ce que prépare le défi [defi-step-ca-reenrolement](../defi-step-ca-reenrolement).

> **Les limites, pour être clair.** ILM (et le CBOM) apportent la **visibilité** et l'**orchestration** de la migration. L'**émission native** de certificats PQC (ML-DSA…) dépend de l'AC/connecteur en aval, pas d'ILM. La valeur ici, c'est *voir et trier le parc*, pas *signer en PQC*.

---

## Pour aller plus loin

- **Protocoles d'enrôlement** : ILM expose ACME, SCEP, EST, CMP côté connecteurs — pour automatiser l'émission sur un parc (hors périmètre de ce lab, déjà touché côté ACME dans le lab step-ca token).
- **Profils de conformité** : le sous-chart `x509-compliance-provider` permet d'encoder une politique (tailles de clés interdites, algorithmes obsolètes) et de **marquer non-conformes** les certificats de l'inventaire. Prolongement direct du CBOM : « conformité » = « PQC-ready ? ».
- **Autres sources de découverte** : `ct-logs-discovery-provider` (journaux de transparence) et `cryptosense-discovery-provider`, déjà dans le chart.
- **Labs liés** : [defi-step-ca-reenrolement](../defi-step-ca-reenrolement) (réenrôlement/rotation d'AC) et les labs du fil rouge PQC.

---

## Dépannage

| Symptôme | Piste |
|---|---|
| Un pod reste `Pending` | Ressources insuffisantes : `kubectl describe pod -n ilm <pod>` (souvent CPU/RAM/PV). Ferme des applis, ou baisse les composants non requis dans `ilm-values.yaml`. |
| `ImagePullBackOff` | Image dans un dépôt privé : voir l'encart de l'étape 6 (`helm template … | grep image:`, `docker pull`, `imagePullSecret`). |
| `CrashLoopBackOff` du cœur | Souvent la **base** : vérifie l'hôte/login PostgreSQL dans `ilm-values.yaml` et que le service PostgreSQL est `Running`. `kubectl logs -n ilm <pod>`. |
| Console inaccessible sur `:8443` | Le `kubectl port-forward` doit rester ouvert ; vérifie le **nom de service** réel (`kubectl get svc -n ilm`). |
| Avertissement TLS dans le navigateur | Normal (auto-signé) : accepte l'exception. |
| Découverte ne trouve rien | L'endpoint n'est pas joignable *depuis le pod* : utilise une **IP de l'hôte** atteignable (pas `localhost`), vérifie le port, et que `openssl s_server` tourne. |
| Pods qui ne démarrent pas du tout | Ressources globales : `kubectl top nodes` / `kubectl get events -n ilm --sort-by=.lastTimestamp`. |

---

## Nettoyage

```bash
helm uninstall ilm -n ilm
helm uninstall ilm-postgres -n ilm
kubectl delete namespace ilm
```

Démonter k3s entièrement :

```bash
/usr/local/bin/k3s-uninstall.sh
```

(minikube : `minikube delete` ; kind : `kind delete cluster`.)

Arrête aussi le terminal `openssl s_server` (Ctrl-C) et `kubectl port-forward`.

---

## Pied de page

- **Versions épinglées :** chart ILM **2.18.0** (dépôt `CZERTAINLY/CZERTAINLY-Helm-Charts`) ; cœur `czertainly/czertainly-core` et `czertainly/czertainly-ip-discovery-provider` sur **Docker Hub public** ; `appVersion` 2.18.x.
- **Démo uniquement :** mots de passe triviaux, TLS auto-signé, PostgreSQL non durci, aucune persistance fiable. **Jamais en production.**
- **MIT vs abonnement :** le **cœur CZERTAINLY/ILM est open source (MIT)** et ses images cœur sont librement tirables. Le modèle est « commercial open source » : **certains connecteurs/composants** peuvent relever d'une licence séparée ou d'un **registre privé** (`hub.omnitrustregistry.com`) — d'où les avertissements sur les images privées plus haut. Pour ce lab, on s'en tient au périmètre librement tirable.
- **Rebranding :** CZERTAINLY a été renommé **ILM** (OmniTrust / Integrity Security Services) début 2026. Doc : <https://docs.otilm.com> (les liens `docs.czertainly.com` redirigent en 301). Org GitHub historique toujours active : `github.com/CZERTAINLY`.

---

### En option — un défi compagnon

**`defi-ilm-decouverte-parc` (★★★★)** — On te fournit un cluster ILM déjà monté et **plusieurs endpoints TLS** mêlant des certificats de plusieurs AC (step-ca, auto-signés, une AC publique), dont **certains expirent sous 30 jours** et plusieurs reposent encore sur **RSA-2048**. Objectif posé, pas de solution donnée : lancer les découvertes, **trier l'inventaire** pour produire deux listes — (1) « expire bientôt » et (2) « vulnérable au quantique » (`nistQuantumSecurityLevel == 0`) — et livrer un **CBOM** + un court rapport de priorisation de migration. Le `verify.sh` contrôle le **résultat** (les deux listes correctes + CBOM valide), pas les commandes tapées.
