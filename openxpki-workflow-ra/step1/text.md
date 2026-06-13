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

Tous doivent être `Up` (ou `healthy`). Vérifier que l'interface répond en interne :

```
curl -sk -o /dev/null -w "%{http_code}\n" https://localhost:8443/webui/index/
```{{exec}}

Réponse attendue : `200`. Le service répond — mais **uniquement en HTTPS**.

Petit obstacle : le proxy d'accès de Killercoda ne sait parler qu'en **HTTP** au
service, alors qu'OpenXPKI n'expose son UI qu'en **HTTPS**. On intercale donc un pont :
`socat` accepte du HTTP sur le port `8888` et le relaie, chiffré, vers le `8443`
d'OpenXPKI. Le démarrer (il reste en tâche de fond) :

```
nohup socat TCP-LISTEN:8888,fork,reuseaddr OPENSSL-CONNECT:127.0.0.1:8443,verify=0 >/tmp/socat-openxpki.log 2>&1 &
```{{exec}}

Vérifier que le pont répond :

```
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8888/webui/index/
```{{exec}}

`200` attendu (le pont fait le HTTP↔HTTPS pour toi).

Maintenant, ouvrir l'interface :

👉 [Ouvrir l'interface OpenXPKI]({{TRAFFIC_HOST1_8888}}/webui/index/)

> ⏳ L'UI est lourde : elle met parfois **30 à 60 secondes** à répondre après le
> démarrage. Page blanche ou erreur au premier essai = recharge dans une minute.
> 🔗 L'accès se fait **uniquement** par l'onglet ouvert par ce lien Killercoda,
> **jamais** par `localhost` (qui pointerait vers ta propre machine, pas la VM).
> Si la page ne charge pas du tout, re-lance le bloc `socat` ci-dessus.

Se connecter en tant que **demandeur** :
- Username : `bob`
- Password : `openxpki`

Tu arrives sur le tableau de bord du *realm* de démonstration. Prends 30 secondes
pour explorer les menus — c'est une vraie PKI d'entreprise, pas une maquette.

Cliquer sur **Check**.
