# Étape 1 — Générer la PKI

Avant d'émettre le moindre certificat, il faut une **autorité** : quelqu'un dont la
signature fait foi. C'est la toute première brique, et tout le reste en dépend.

`step ca init` crée en une commande la racine, l'intermédiaire et une *provisioner*
(le mécanisme qui autorise l'émission de certificats).

Lancer l'initialisation (version non-interactive, reproductible — c'est celle
qu'on scripte en vrai) :

```
step ca init --deployment-type standalone --name "Demo Lab Root CA" \
  --dns localhost --address ":4443" --provisioner admin \
  --password-file /root/.step-password
```{{exec}}

Ce que fait chaque option :
- `--deployment-type standalone` : CA autonome, sans service cloud Smallstep ;
- `--name` : le nom de ta CA, repris dans le sujet du certificat racine ;
- `--dns localhost` / `--address ":4443"` : où la CA écoutera ;
- `--provisioner admin` : crée la provisioner qui autorisera les émissions ;
- `--password-file` : le mot de passe qui protège les clés privées générées
  (ici le fichier de lab créé à l'installation — trivial, jamais en prod).

> `step ca init` lancé sans options pose les mêmes questions une par une dans un
> assistant interactif. Et pour repartir de zéro à tout moment : `rm -rf /root/.step`.

Observer l'arborescence générée :

```
step path
ls -R $(step path)
```{{exec}}

Deux fichiers sont à retenir : `certs/root_ca.crt` (l'ancre de confiance) et
`certs/intermediate_ca.crt` (le maillon qui signera les certificats émis).
La racine ne signe que l'intermédiaire — jamais directement un certificat feuille.

Cliquer sur **Check** une fois la PKI générée.
