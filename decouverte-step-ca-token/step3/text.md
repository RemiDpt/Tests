# Étape 3 — Le job de pipeline obtient son certificat

Voici la scène, en deux rôles que tu vas jouer l'un après l'autre :

- **l'orchestrateur de confiance** (le serveur CI, ou la plateforme qui connaît
  l'identité du job) détient le secret de la provisioner. Il émet un **token court** ;
- **le job de pipeline**, lui, ne connaît aucun secret. Il reçoit seulement ce token,
  et s'en sert pour réclamer son certificat.

Le flux, en une image :

```text
  Orchestrateur de confiance ──(1) step ca token──► TOKEN court
   (détient le secret)                                  │
                                                        │ remis au job
                                                        ▼
  Job de pipeline ──(2) step ca certificate --token──► CA step-ca
   (aucun secret durable)                               │ (3) signe
                                                        ▼
                                              cert.pem (~24 h)
```

D'abord, l'orchestrateur frappe le token (c'est ici, et **seulement ici**, qu'on
utilise le mot de passe de la provisioner) :

```
cd /root
TOKEN=$(step ca token ci-runner.lab.local \
  --provisioner admin \
  --password-file /root/.step-password \
  --ca-url https://localhost:4443 \
  --root $(step path)/certs/root_ca.crt)
echo "Token émis (valable quelques minutes) :"
echo "$TOKEN" | cut -c1-60 ; echo "..."
```{{exec}}

Maintenant, le job de pipeline obtient son certificat avec **le token pour seule
preuve** — aucun mot de passe ne traverse cette commande :

```
step ca certificate ci-runner.lab.local cert.pem key.pem \
  --token $TOKEN \
  --ca-url https://localhost:4443 \
  --root $(step path)/certs/root_ca.crt
```{{exec}}

Regarde ce que tu as obtenu :

```
step certificate inspect cert.pem --short
```{{exec}}

C'est toute la différence avec le niveau 0. Là-bas, `--provisioner-password-file`
accompagnait chaque émission : le secret vivait avec le demandeur. Ici, le job ne
porte qu'un **token jetable**. Compromis demain, il aura déjà expiré.

> Pourquoi le token doit correspondre au nom demandé : le token *encode* l'identité
> autorisée (`ci-runner.lab.local`). La CA refuse d'émettre pour un autre nom — le
> laissez-passer n'ouvre qu'une seule porte.

Cliquer sur **Check**.
