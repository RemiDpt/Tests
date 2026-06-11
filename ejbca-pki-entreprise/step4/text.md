# Étape 4 — Le cap post-quantique

Depuis EJBCA Community 9.1, tu peux créer une CA signée en **ML-DSA** — l'algorithme
de signature post-quantique standardisé par le NIST (FIPS 204), qui remplace le
candidat Dilithium des versions précédentes.

Dans l'**Admin UI** : **Certification Authorities** → créer une nouvelle CA :
- nom : `PQRootCA` ;
- algorithme de signature : **ML-DSA-65** ;
- spécification de clé : **ML-DSA-65** ;
- validité : à ta main (par exemple 10 ans) ;
- le reste : valeurs par défaut.

Une fois créée, exporter son certificat racine et le regarder avec openssl :

```
docker exec ejbca /opt/keyfactor/bin/ejbca.sh ca getcacert \
  --caname PQRootCA -f /tmp/pqroot.pem
docker cp ejbca:/tmp/pqroot.pem /root/pqroot.pem
openssl x509 -in /root/pqroot.pem -noout -text | head -15
```{{exec}}

Regarde la ligne *Signature Algorithm*. Selon la version d'openssl de la machine,
tu verras `ML-DSA-65`… ou un **OID brut** que ton openssl ne sait pas nommer. Ce
n'est pas un bug, c'est une leçon : pendant la transition post-quantique, une
partie de ton écosystème comprendra les nouveaux algorithmes, l'autre pas encore.
**C'est exactement pour ça que la crypto-agilité se prépare maintenant.**

---

**Ce que le parcours t'a outillé à faire :**
- des certificats **courts et renouvelés automatiquement** (niveau 1, OpenBao) :
  le parc peut changer d'algorithme à la vitesse du renouvellement ;
- des **profils centralisés** (OpenXPKI, EJBCA) : l'algorithme se change en un
  point, pas serveur par serveur ;
- et maintenant une CA **ML-DSA** opérationnelle pour commencer à tester tes
  chaînes, tes clients, tes équipements.

EJBCA propose aussi des montages **hybrides** (chaînes mêlant algorithmes
classiques et post-quantiques) pour accompagner cette transition — c'est l'approche
généralement recommandée, notamment par l'ANSSI, pour ne pas parier toute sa
sécurité sur les seuls nouveaux algorithmes pendant leur jeunesse.
