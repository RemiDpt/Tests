# Étape 1 — Démarrer OpenBao

Le mode **dev** démarre un serveur OpenBao complet en une commande : déjà initialisé,
déjà déverrouillé, token racine connu. Parfait pour un lab, **interdit en production**
(stockage en mémoire, aucun scellement).

```
bao server -dev -dev-root-token-id=root >/var/log/bao.log 2>&1 &
```{{exec}}

Indiquer au client `bao` où parler, et avec quel token :

```
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root
```{{exec}}

Vérifier que le serveur répond (le `sleep` lui laisse le temps de démarrer) :

```
sleep 2
bao status
```{{exec}}

Points à repérer dans la sortie :
- `Initialized: true` et `Sealed: false` — en production, l'initialisation et le
  descellement sont des opérations sensibles ; le mode dev les court-circuite ;
- `Storage Type: inmem` — tout disparaît à l'arrêt du serveur. Lab jetable.

> Le token `root` est l'équivalent du mot de passe trivial des labs précédents :
> assumé ici, impensable en production.

Cliquer sur **Check**.
