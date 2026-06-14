# Défi 4 — Imposer un contenu par template

Une politique dit ce qui est **autorisé**. Un **template** dit ce que le certificat
**contiendra**, quoi que demande le client. C'est ainsi qu'on impose une OU, des
usages de clé, ou qu'on interdit qu'une feuille soit une CA — sans faire confiance au
demandeur.

Assure-toi que la CA tourne *(bloc fourni)* :

```
pgrep -f "step-ca .*ca.json" >/dev/null || nohup step-ca "$(step path)/config/ca.json" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2 && curl -sk https://localhost:4443/health
```{{exec}}

## 🎯 Objectif
Configurer la provisioner `admin` avec un **template X.509** qui force, sur **tout**
certificat émis, l'**unité organisationnelle** `OU = PKI-Defi` — même si le demandeur
ne la réclame pas.

## ✅ Critère de réussite
Le `verify.sh` émet lui-même un certificat de test via `admin`, **sans** préciser
d'OU, puis vérifie que le sujet contient bien `PKI-Defi`. Si le template n'impose pas
l'OU, le défi échoue.

Clique sur **Check** quand le template est en place.

---

<details>
<summary>🆘 Indice</summary>

Une provisioner peut pointer vers un fichier de template via
`options.x509.templateFile` dans `ca.json`. Le template est un gabarit (style Go) qui
produit le JSON du certificat : tu peux y figer `subject.organizationalUnit`. Pense à
réinjecter le sujet et les SANs demandés (`{{ toJson .Subject.CommonName }}`,
`{{ toJson .SANs }}`) pour ne pas casser l'émission, puis **redémarre la CA**.
</details>

<details>
<summary>✅ Solution de référence</summary>

Créer le template :

```
cat > /root/forced-ou.tpl <<'TPL'
{
	"subject": {
		"commonName": {{ toJson .Subject.CommonName }},
		"organizationalUnit": ["PKI-Defi"]
	},
	"sans": {{ toJson .SANs }},
	"keyUsage": ["digitalSignature", "keyEncipherment"],
	"extKeyUsage": ["serverAuth", "clientAuth"],
	"basicConstraints": { "isCA": false }
}
TPL
```

Brancher le template sur `admin` et redémarrer :

```
CONFIG="$(step path)/config/ca.json"
jq --arg tf /root/forced-ou.tpl \
  '(.authority.provisioners[] | select(.name=="admin")).options.x509.templateFile = $tf' \
  "$CONFIG" > /tmp/ca.json && mv /tmp/ca.json "$CONFIG"

pkill -f "step-ca .*ca.json"; sleep 1
nohup step-ca "$CONFIG" --password-file /root/.step-password >/var/log/step-ca.log 2>&1 &
sleep 2
```

Test rapide :

```
TOKEN=$(step ca token test.lab.local --provisioner admin --password-file /root/.step-password \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt")
step ca certificate test.lab.local /tmp/t.crt /tmp/t.key --token "$TOKEN" \
  --ca-url https://localhost:4443 --root "$(step path)/certs/root_ca.crt" --force
openssl x509 -in /tmp/t.crt -noout -subject
```

**Pourquoi cette approche.** Une politique **autorise ou refuse** ; un template
**fabrique le contenu**. Tu décides ce que portera *tout* certificat émis (ici l'OU),
indépendamment de ce que le demandeur réclame — utile pour imposer des usages de clé,
une OU, ou interdire qu'une feuille soit une CA.

**Sous le capot.** À chaque émission, step-ca applique ce gabarit (style Go) pour
produire le JSON du certificat. C'est pourquoi tu **réinjectes** `commonName` et `sans`
depuis la demande (`{{ toJson … }}`) : ce que tu n'écris pas dans le template
**disparaît** du certificat. Les valeurs que tu figes en dur (l'OU) s'imposent, elles.

**Le piège.** Deux choses. D'abord, à la différence d'une `policy`, le template
(`options.x509.templateFile`) au **niveau provisioner** est bien pris en compte en
self-hosted — ne confonds pas les deux mécanismes. Ensuite, comme toute modif de
`ca.json`, le template n'est actif qu'après **redémarrage** de la CA ; et un template
incomplet (sujet/SANs oubliés) casse l'émission au lieu de l'enrichir.
</details>
