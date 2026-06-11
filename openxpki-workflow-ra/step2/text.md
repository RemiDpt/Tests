# Étape 2 — Côté demandeur : soumettre une demande

Le demandeur ne reçoit jamais sa clé privée de la PKI : il la **génère lui-même** et
n'envoie que la **CSR** (Certificate Signing Request) — la partie publique + l'identité
demandée. Générer les deux dans le terminal :

```
cd /root
openssl req -new -newkey rsa:2048 -nodes \
  -keyout demandeur.key -out demandeur.csr \
  -subj "/CN=serveur.lab.local"
openssl req -in demandeur.csr -noout -subject
```{{exec}}

Afficher la CSR pour la copier (sélectionne tout le bloc, de `-----BEGIN` à `-----END` inclus) :

```
cat /root/demandeur.csr
```{{exec}}

Maintenant, dans l'interface web (connecté en `bob`) :
1. ouvrir le menu de **demande de certificat** (« Request new certificate ») ;
2. choisir un profil de type **serveur TLS** ;
3. au choix du mode de saisie, **coller la CSR** copiée depuis le terminal
   (option « upload/paste PKCS#10 ») ;
4. valider la demande.

La demande part dans la file d'attente : son statut est **en attente d'approbation**
(`PENDING`). Côté demandeur, c'est terminé — tu ne peux rien faire de plus. C'est
exactement le but : **celui qui demande n'est pas celui qui décide**.

> Note l'identifiant du workflow affiché par l'interface : tu vas le retrouver de
> l'autre côté du guichet à l'étape suivante.

Cliquer sur **Check**.
