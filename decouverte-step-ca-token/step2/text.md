# Étape 2 — Démarrer la CA

Une PKI sur disque ne sert à rien tant que personne ne répond aux demandes. Mettre la
CA en ligne, en arrière-plan :

```
step-ca $(step path)/config/ca.json --password-file /root/.step-password &
```{{exec}}

Vérifier qu'elle est bien vivante (le `sleep` lui laisse le temps de démarrer) :

```
sleep 3
curl -sk https://localhost:4443/health
```{{exec}}

Réponse attendue : `{"status":"ok"}`. Ta CA écoute, prête à émettre.

> `-k` désactive la vérification TLS côté `curl` : normal ici, la racine de cette CA
> n'est pas dans le magasin de confiance du système. Distribuer la racine est
> justement un des rôles d'une PKI en production.

> Astuce : la CA affiche ses logs dans le terminal. Appuie sur **Entrée** pour
> récupérer une invite propre — la CA continue de tourner en arrière-plan.

Cliquer sur **Check** quand la CA répond `ok`.
