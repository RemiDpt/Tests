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

**Pourquoi cette approche.** Un certificat SSH remplace la gestion manuelle des
`authorized_keys` : au lieu de recopier des clés publiques partout, un serveur fait
confiance à **une** autorité, et tout certificat qu'elle signe (avec le bon principal)
est accepté. Le **principal** (`deploy`) est l'équivalent SSH du nom d'utilisateur
autorisé.

**Sous le capot.** `step ssh certificate` génère la paire de clés **et** demande à la
CA un certificat pour la clé publique, le tout en une commande ; le résultat sort
suffixé `-cert.pub`. La CA agit ici comme **CA SSH** (initialisée avec `--ssh`),
distincte de sa fonction X.509.

**Le piège — deux mots de passe à ne pas confondre.** `--provisioner-password-file`
authentifie la **provisioner** auprès de la CA ; `--password-file` chiffre la **clé
privée** générée. Comme `--password-file` et `--no-password` portent tous deux sur la
clé, ils sont **incompatibles** : c'est l'erreur classique sur cette commande.
</details>
