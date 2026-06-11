# Étape 2 — Démarrer la CA

Une PKI générée ne sert à rien tant que la CA n'est pas *en ligne* pour répondre
aux demandes. Démarrer le serveur en arrière-plan :

```
step-ca $(step path)/config/ca.json --password-file /root/.step-password &
```{{exec}}

Interroger l'endpoint de santé (le `sleep` laisse au serveur le temps de démarrer) :

```
sleep 3
curl -sk https://localhost:4443/health
```{{exec}}

La réponse attendue est `{"status":"ok"}`.

> `-k` désactive la vérification TLS côté `curl` : normal ici, car la racine de
> cette CA n'est pas (encore) dans le magasin de confiance du système. Distribuer
> et faire confiance à la racine est précisément le rôle d'une PKI en production.

> Astuce : la CA affiche ses logs dans le terminal. Appuie sur **Entrée** pour
> récupérer une invite propre — la CA continue de tourner en arrière-plan.

Cliquer sur **Check** quand la CA répond `ok`.
