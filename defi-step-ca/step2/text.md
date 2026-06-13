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
**génère la paire de clés** et écrit le certificat à côté, suffixé `-cert.pub`. Pense
à viser la bonne provisioner (`--provisioner admin --password-file …`), à donner
l'URL et la racine de la CA, à borner la durée (`--not-after`), et à ne pas chiffrer
la clé privée pour un lab (`--no-password --insecure`).
</details>

<details>
<summary>✅ Solution de référence</summary>

```
step ssh certificate deploy /root/id_deploy \
  --provisioner admin --password-file /root/.step-password \
  --not-after 1h --no-password --insecure \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt"

ssh-keygen -L -f /root/id_deploy-cert.pub
```

`deploy` est à la fois le sujet et le principal du certificat. Le fichier
`/root/id_deploy-cert.pub` est créé automatiquement à partir de `/root/id_deploy`.
</details>
