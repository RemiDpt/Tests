# Étape 4 — ACME : le renouvellement qui se déclenche tout seul

Le modèle token de l'étape 3 est parfait pour un **job** qui démarre, réclame son
certificat, puis meurt. Mais un **serveur qui tourne en continu** — une API, un nginx —
ne « rejoue » aucun pipeline : il a juste besoin que son certificat se renouvelle tout
seul, sans que personne n'y pense.

C'est exactement ce que fait **ACME**, le protocole derrière Let's Encrypt — et step-ca
le parle nativement. Un client ACME demande le certificat **et le renouvelle
automatiquement**, sans token ni mot de passe : la CA vérifie elle-même que tu contrôles
bien le nom demandé.

D'abord, activer une **provisioner ACME** sur la CA, puis la redémarrer pour charger la
nouvelle config :

```
step ca provisioner add acme --type ACME
pkill -f "step-ca .*ca.json"; sleep 1
step-ca $(step path)/config/ca.json --password-file /root/.step-password &
sleep 3 && curl -sk https://localhost:4443/health
```{{exec}}

Faire pointer un nom de test vers la VM, et installer le client **acme.sh** (et `socat`,
dont il se sert pour répondre au défi) :

```
grep -q acme.lab.local /etc/hosts || echo "127.0.0.1 acme.lab.local" >> /etc/hosts
apt-get install -y -qq socat >/dev/null
curl -s https://get.acme.sh | sh -s email=admin@lab.local >/dev/null
echo "acme.sh installé."
```{{exec}}

Pour qu'acme.sh fasse confiance à l'endpoint HTTPS de ta CA, on installe sa **racine dans
le magasin de confiance du système**. Le détail qui compte : le renouvellement
automatique tournera via `cron`, dans un environnement vierge où aucune variable de ton
shell n'existe — il faut donc une confiance **permanente**, pas une astuce de session.
C'est exactement le geste qu'on fait en entreprise pour une CA interne :

```
cp $(step path)/certs/root_ca.crt /usr/local/share/ca-certificates/lab-root-ca.crt
update-ca-certificates
```{{exec}}

Demander le certificat en mode **standalone** (acme.sh ouvre lui-même le port 80 le temps
du défi) :

```
~/.acme.sh/acme.sh --issue --standalone -d acme.lab.local \
  --server https://localhost:4443/acme/acme/directory
```{{exec}}

Ce qui vient de se passer : acme.sh a ouvert le port 80, la CA l'a **recontacté** sur
`http://acme.lab.local/.well-known/acme-challenge/...` pour vérifier qu'il contrôlait
bien ce nom (le **défi HTTP-01**), puis elle a signé. Aucun token, aucun secret n'a
circulé.

Et le renouvellement « tout seul » ? À l'installation, acme.sh a posé une tâche **cron**
qui vérifie chaque jour l'échéance et renouvelle quand il le faut. Et comme ta CA est
maintenant de confiance au niveau système, ce cron fonctionne dans son environnement
vierge — sans aucune variable à lui transmettre. Regarde la tâche, puis force un
renouvellement pour voir le cycle complet :

```
crontab -l | grep acme.sh
~/.acme.sh/acme.sh --renew -d acme.lab.local --force \
  --server https://localhost:4443/acme/acme/directory
```{{exec}}

> La différence avec l'étape 3, en une phrase : le **token** convient à un job éphémère
> qui demande son certificat puis disparaît ; **ACME** convient à un service durable, qui
> doit pouvoir être recontacté par la CA mais n'a alors plus jamais à s'occuper de son
> renouvellement. En production, un reverse-proxy comme Caddy ou Traefik fait tout ça
> sans même un script — branché sur l'endpoint ACME de ta CA, il obtient et renouvelle
> seul.

Cliquer sur **Check** une fois le certificat ACME obtenu.
