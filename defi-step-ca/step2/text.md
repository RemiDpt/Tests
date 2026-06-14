# Défi 2 — Émettre un certificat SSH utilisateur

step-ca ne signe pas que du X.509 : la CA de ce lab a été initialisée avec le
**support SSH**. Une PKI SSH permet de remplacer les `authorized_keys` éparpillées par
des **certificats SSH** à courte durée, signés par une autorité.

D'abord, assure-toi que la CA tourne *(bloc fourni — ce n'est pas le défi)* :

```
pgrep -f "step-ca .*ca.json" >/dev/null || nohup step-ca "$(step path)/config/ca.json" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2 && curl -sk https://localhost:4443/health
```{{exec}}

## 🎯 Objectif
Émettre un **certificat SSH _utilisateur_** pour le principal `deploy`, valide **au
plus 1 heure**, et déposer le certificat résultant dans `/root/id_deploy-cert.pub`.

## ✅ Critère de réussite
- `/root/id_deploy-cert.pub` est un certificat SSH **de type _user_** ;
- il liste le principal **`deploy`** ;
- `ssh-keygen -L -f /root/id_deploy-cert.pub` l'affiche sans erreur.

Clique sur **Check** une fois le certificat émis.

---

<details>
<summary>🆘 Indice</summary>

La sous-commande dédiée est `step ssh certificate <principal> <fichier_clé>`. Elle
**génère la paire de clés** et écrit le certificat à côté, suffixé `-cert.pub`. Deux
mots de passe à ne pas confondre : `--provisioner-password-file` authentifie la
**provisioner** (obligatoire pour ne pas être bloqué en interactif), tandis que
`--password-file` sert à chiffrer la **clé privée générée**. Donne aussi l'URL et la
racine de la CA, et borne la durée avec `--not-after`.

> Piège : `--no-password` et `--password-file` portent tous deux sur la clé privée et
> sont **incompatibles** (`step` renvoie une erreur). N'en mets qu'un.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
step ssh certificate deploy /root/id_deploy \
  --provisioner admin \
  --provisioner-password-file /root/.step-password \
  --password-file /root/.step-password \
  --not-after 1h \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt"

ssh-keygen -L -f /root/id_deploy-cert.pub
```

`deploy` est à la fois le sujet et le principal du certificat. Le fichier
`/root/id_deploy-cert.pub` est créé automatiquement à partir de `/root/id_deploy`.

**Pourquoi un certificat SSH plutôt qu'une clé dans `authorized_keys`**

Le modèle « je copie ma clé publique dans le `authorized_keys` de chaque serveur » ne
tient pas à l'échelle. Dès que tu as quelques centaines de machines, plus personne ne
sait quelle clé traîne où ni à qui elle appartient, et le départ d'un collègue laisse
des clés orphelines un peu partout. Avec un certificat SSH, le serveur ne fait confiance
qu'à **une** autorité : tout certificat qu'elle signe, avec le bon principal, est
accepté — sans rien recopier sur la machine. C'est le basculement qu'ont documenté de
grosses infras comme Meta ou Uber : un développeur réclame un certificat valable
quelques heures le matin, et le soir il a déjà expiré tout seul. Le `principal`
(`deploy`) est l'équivalent SSH du nom de compte autorisé à se connecter.

**Une seule commande pour tout faire**

`step ssh certificate` génère la paire de clés **et** va demander à la CA de signer la
clé publique, d'un coup ; le certificat sort à côté, suffixé `-cert.pub`. Ici la CA
joue son rôle d'autorité SSH — c'est ce qu'a activé le `--ssh` à l'initialisation — une
casquette distincte de sa fonction X.509.

**Le piège : deux mots de passe différents**

C'est l'erreur classique sur cette commande. `--provisioner-password-file` authentifie
la provisioner auprès de la CA (sans lui, `step` te bloque en attendant une saisie) ;
`--password-file`, lui, chiffre la clé privée qui vient d'être générée. Et comme
`--password-file` et `--no-password` parlent tous les deux de cette clé, ils s'excluent :
tu en mets un, jamais les deux.
</details>
