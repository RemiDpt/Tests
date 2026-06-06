# Étape 1 — Générer la PKI

`step ca init` crée en une commande la racine, l'intermédiaire et une *provisioner*
(le mécanisme qui autorise l'émission de certificats).

Lancer l'initialisation guidée :

```
step ca init
```{{exec}}

Répondre :
- **Deployment type** : `Standalone`
- **Name** : `Demo Lab Root CA`
- **DNS names / IPs** : `localhost`
- **Address** : `:4443`
- **Provisioner** : `admin`
- **Password** : `LabPKI-non-securise`

> Alternative non-interactive (équivalente) :
> ```
> step ca init --deployment-type standalone --name "Demo Lab Root CA" \
>   --dns localhost --address ":4443" --provisioner admin \
>   --password-file /root/.step-password
> ```{{exec}}

Observer l'arborescence générée :

```
step path
ls -R $(step path)
```{{exec}}

Deux fichiers sont à retenir : `certs/root_ca.crt` (l'ancre de confiance) et
`certs/intermediate_ca.crt` (le maillon qui signera les certificats émis).
La racine ne signe que l'intermédiaire — jamais directement un certificat feuille.

Cliquer sur **Check** une fois la PKI générée.
