# Étape 3 — La clé ne sort pas, et pourtant elle signe

Toute la promesse du HSM tient en deux affirmations qui semblent contradictoires : la
clé privée est **inutilisable de l'extérieur**, et pourtant elle **signe**. Vérifions
les deux.

Si besoin, ré-exporte le module :

```
export MODULE=$(ls /usr/lib/softhsm/libsofthsm2.so /usr/lib/*/softhsm/libsofthsm2.so 2>/dev/null | head -1)
```{{exec}}

**Preuve 1 — on ne peut pas extraire la clé.** Tente de lire la clé privée pour la
sortir du HSM :

```
pkcs11-tool --module $MODULE --token-label "CA-Root-HSM" --login --pin 1234 \
  --read-object --type privkey --label "ca-root-key" --output-file /tmp/vol.key
```{{exec}}

> Cette commande **doit échouer** (erreur du type *non extractable / sensitive*). Ce
> n'est pas un bug : c'est exactement la protection recherchée. La clé est marquée
> *sensible* et *non extractible* à la génération — le HSM refuse de la divulguer, même
> à toi, même avec le bon PIN.

**Preuve 2 — la clé signe quand même.** On fabrique le certificat racine auto-signé en
demandant à OpenSSL de signer *via le HSM*. La clé ne quitte jamais le token ; seul le
résultat signé en sort :

```
openssl req -new -x509 -days 3650 \
  -engine pkcs11 -keyform engine \
  -key "pkcs11:token=CA-Root-HSM;object=ca-root-key;type=private;pin-value=1234" \
  -subj "/CN=Lab Root CA HSM/O=labPKI" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign" \
  -out /root/ca-hsm.crt
```{{exec}}

> ⚠️ **À TESTER EN LIVE — commande la plus sensible du lab.** L'engine PKCS#11
> d'OpenSSL est capricieux selon la version :
> - sur **OpenSSL 1.1**, la syntaxe `-engine pkcs11 -keyform engine` ci-dessus est la
>   plus courante ;
> - sur **OpenSSL 3** (Ubuntu récents), l'engine est déprécié : il faut parfois passer
>   par `pkcs11-provider`, ou déclarer l'engine dans `openssl.cnf` ;
> - si l'engine ne trouve pas le module, exporte `PKCS11_MODULE_PATH=$MODULE` avant la
>   commande, ou vérifie que SoftHSM2 est enregistré auprès de p11-kit
>   (`p11-kit list-modules`).
> Si cette étape résiste, le cœur pédagogique (Preuves 1 et la clé née dans le HSM) est
> déjà acquis aux étapes 1-2.

Inspecter le certificat racine obtenu :

```
openssl x509 -in /root/ca-hsm.crt -noout -subject -issuer -dates
```{{exec}}

Sujet = émetteur (`Lab Root CA HSM`) : c'est bien une racine **auto-signée**. Mais
cette fois, la clé qui l'a signée n'a jamais touché le disque.

Cliquer sur **Check**.
