# Étape 1 — Activer ACME sur la CA

On crée d'abord la PKI (comme au niveau 0), puis on **ajoute une provisioner ACME** :
c'est elle qui permettra aux clients d'obtenir des certificats automatiquement, sans
mot de passe.

Créer la PKI (version non-interactive) :

```
rm -rf /root/.step
echo "LabPKI-non-securise" > /root/.step-password
step ca init --deployment-type standalone --name "CI/CD Lab CA" \
  --dns localhost --address ":4443" --provisioner admin \
  --password-file /root/.step-password
```{{exec}}

Ajouter la provisioner ACME :

```
step ca provisioner add acme --type ACME
```{{exec}}

Vérifier qu'elle est bien présente dans la configuration :

```
step ca provisioner list 2>/dev/null || grep -i acme $(step path)/config/ca.json
```{{exec}}

> Différence clé avec le niveau 0 : la provisioner `admin` (type JWK) exige un mot de
> passe à chaque émission. La provisioner `acme`, elle, n'exige **aucun secret** — le
> client prouve son identité en répondant à un *challenge* (ici HTTP-01). C'est ce qui
> rend l'automatisation possible.

Cliquer sur **Check**.
