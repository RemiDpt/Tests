# Étape 3 — Émettre un certificat

Le moment de vérité. Tout ce qui précède — racine, intermédiaire, CA en ligne —
n'avait qu'un but : pouvoir délivrer **ce** certificat.

Demander un certificat feuille pour `test.lab.local`, signé par la provisioner
`admin`. Les fichiers sont créés dans le répertoire courant (`/root`).

```
cd /root
step ca certificate "test.lab.local" test.crt test.key \
  --provisioner admin \
  --provisioner-password-file /root/.step-password \
  --ca-url https://localhost:4443 \
  --root /root/.step/certs/root_ca.crt
```{{exec}}

Ce que disent les options :
- `--ca-url` : l'adresse de ta CA en ligne ;
- `--root` : la racine utilisée pour vérifier la connexion TLS vers la CA ;
- `--provisioner` / `--provisioner-password-file` : qui autorise l'émission, et avec quel secret.

Deux fichiers apparaissent : `test.crt` (le certificat) et `test.key` (la clé
privée associée). Le certificat est signé par l'intermédiaire, lui-même signé par
la racine : c'est la chaîne de confiance que vérifiera tout client.

Cliquer sur **Check** une fois le certificat émis.
