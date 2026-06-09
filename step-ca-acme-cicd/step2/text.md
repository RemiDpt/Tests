# Étape 2 — Démarrer la CA

Démarrer le serveur de CA en arrière-plan (il sert maintenant aussi l'API ACME) :

```
step-ca $(step path)/config/ca.json --password-file /root/.step-password &
```{{exec}}

Attendre 2-3 secondes, puis vérifier la santé :

```
curl -sk https://localhost:4443/health
```{{exec}}

Réponse attendue : `{"status":"ok"}`.

Vérifier que l'**endpoint ACME** répond bien (c'est le "directory" que les clients
interrogent, exactement comme celui de Let's Encrypt) :

```
curl -sk https://localhost:4443/acme/acme/directory
```{{exec}}

Tu dois voir un JSON listant les URL `newNonce`, `newAccount`, `newOrder`, etc.
C'est la preuve que ta CA parle ACME.

> Astuce : la CA affiche ses logs dans le terminal. Appuie sur **Entrée** pour
> récupérer une invite propre — la CA continue de tourner en arrière-plan.

Cliquer sur **Check**.
