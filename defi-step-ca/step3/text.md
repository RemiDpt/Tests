# Défi 3 — Une politique qui refuse pour de vrai

Une PKI sérieuse ne se contente pas d'émettre : elle **refuse** ce qui sort de son
périmètre. step-ca sait contraindre une provisioner par une **politique** (`policy`)
qui liste les noms autorisés. Ici, on veut qu'`admin` ne puisse émettre que pour le
domaine `lab.local`.

Assure-toi d'abord que la CA tourne *(bloc fourni)* :

```
pgrep -f "step-ca .*ca.json" >/dev/null || nohup step-ca "$(step path)/config/ca.json" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2 && curl -sk https://localhost:4443/health
```{{exec}}

## 🎯 Objectif
1. Contraindre la provisioner `admin` pour qu'elle n'émette **que** des certificats
   dont les noms DNS sont en `*.lab.local`.
2. Émettre un certificat conforme pour `app.lab.local` dans **`/root/good.crt`**.

## ✅ Critère de réussite
- `/root/good.crt` existe et vise `app.lab.local` ;
- la politique **bloque réellement** : le `verify.sh` tentera lui-même d'émettre un
  certificat pour `app.evil.com` — il **doit échouer**. Si la CA l'accepte, le défi
  n'est pas réussi.

Clique sur **Check** quand ta politique est en place et `good.crt` émis.

---

<details>
<summary>🆘 Indice</summary>

La politique vit dans `ca.json` (`$(step path)/config/ca.json`), au niveau de la
provisioner, sous une clé `policy`. La forme : `policy.x509.allow.dns` = liste de
motifs autorisés. Après modification du fichier, **la CA doit être redémarrée** pour
recharger sa configuration. `jq` est installé pour éditer le JSON proprement.
</details>

<details>
<summary>✅ Solution de référence</summary>

```
CONFIG="$(step path)/config/ca.json"

# Ajoute la politique X.509 à la provisioner 'admin'.
jq '(.authority.provisioners[] | select(.name=="admin")).policy =
      {"x509":{"allow":{"dns":["*.lab.local"]}}}' "$CONFIG" > /tmp/ca.json \
  && mv /tmp/ca.json "$CONFIG"

# Redémarre la CA pour recharger la config.
pkill -f "step-ca .*ca.json"; sleep 1
nohup step-ca "$CONFIG" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2

# Émet un certificat conforme.
TOKEN=$(step ca token app.lab.local --provisioner admin --password-file /root/.step-password \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt")
step ca certificate app.lab.local /root/good.crt /root/good.key --token "$TOKEN" \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt" --force
```

Pour t'en convaincre, tente toi-même `app.evil.com` : la CA doit refuser de signer.
</details>
