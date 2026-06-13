# Étape 1 — Découvrir la pile et ouvrir l'interface

OpenXPKI n'est pas un binaire unique comme step-ca : c'est une **pile** de services.
Regarder ce qui tourne :

```
cd /root/openxpki-docker
docker-compose ps
```{{exec}}

Cinq services, chacun son rôle :
- `db` : MariaDB — l'état de la PKI (workflows, certificats) vit en base ;
- `server` : le cœur OpenXPKI — la logique de workflows et les opérations crypto ;
- `client` : le démon qui fait le lien entre l'interface web et le serveur ;
- `web` / `web-nginx` : le frontal HTTP(S) de l'interface.

Tous doivent être `Up` (ou `healthy`). Vérifier que l'interface répond :

```
curl -sk -o /dev/null -w "%{http_code}\n" https://localhost:8443/webui/index/
```{{exec}}

Réponse attendue : `200`.

Maintenant, ouvrir l'interface dans ton navigateur :

👉 [Ouvrir l'interface OpenXPKI]({{TRAFFIC_HOST1_8443}}/webui/index/)

> Avertissement de sécurité du navigateur = normal ici (certificat de démo
> auto-signé). Accepte l'exception.

Se connecter en tant que **demandeur** :
- Username : `bob`
- Password : `openxpki`

Tu arrives sur le tableau de bord du *realm* de démonstration. Prends 30 secondes
pour explorer les menus — c'est une vraie PKI d'entreprise, pas une maquette.

Cliquer sur **Check**.
