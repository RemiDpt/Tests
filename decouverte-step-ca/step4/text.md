# Étape 4 — Émettre un certificat SSH

Une CA step-ca ne fait pas que du X.509. Comme tu l'as initialisée avec `--ssh`, elle
est **aussi une autorité SSH**. L'intérêt : au lieu de recopier des clés publiques dans
les `authorized_keys` de chaque serveur, tu fais confiance à **une** autorité — et tout
certificat qu'elle signe (avec le bon *principal*) est accepté.

Émettre un certificat SSH **utilisateur** pour le principal `deploy`. La commande génère
la paire de clés **et** demande le certificat à la CA, en une fois :

```
cd /root
step ssh certificate deploy id_deploy \
  --provisioner admin \
  --provisioner-password-file /root/.step-password \
  --no-password --insecure \
  --ca-url https://localhost:4443 \
  --root $(step path)/certs/root_ca.crt
```{{exec}}

Deux fichiers apparaissent : `id_deploy` (la clé privée) et `id_deploy-cert.pub` (le
**certificat** SSH, déjà signé par la CA). Le `-cert.pub` est ce que le serveur vérifie.

Lire le contenu du certificat :

```
ssh-keygen -L -f /root/id_deploy-cert.pub
```{{exec}}

Points à repérer dans la sortie :
- **Type** : `... user certificate` — c'est un certificat **utilisateur**, pas hôte ;
- **Principals** : `deploy` — l'équivalent SSH du nom d'utilisateur autorisé. Le serveur
  n'accepte la connexion que si le principal correspond ;
- **Valid** : la fenêtre de validité, courte par défaut — même logique que pour le X.509.

> `--no-password --insecure` génère une clé privée **non chiffrée** (pratique en lab et
> en CI). Ces deux options vont ensemble ; à l'inverse, `--password-file` chiffrerait la
> clé — les deux sont incompatibles, ne les combine pas.

Cliquer sur **Check** une fois le certificat SSH émis.
