# Étape 4 — Renouvellement automatique

C'est *le* vrai sujet en CI/CD. Un certificat step-ca dure **24 h par défaut** : court,
volontairement. La question n'est donc pas « comment l'obtenir » mais « comment le
**renouveler sans personne** ».

`certbot` sait renouveler tous les certificats qu'il gère. Forçons un renouvellement
pour le voir à l'œuvre (sans `--force-renewal`, il ne renouvellerait pas un cert encore
valide) :

```
REQUESTS_CA_BUNDLE=$(step path)/certs/root_ca.crt \
  certbot renew --force-renewal
```{{exec}}

Le certificat est ré-émis automatiquement, toujours sans intervention.

**En production / CI, on automatise** avec une tâche planifiée. Exemple de cron qui
renouvelle toutes les 8 h (adapté à une durée de vie de 24 h) :

```
echo '0 */8 * * * root REQUESTS_CA_BUNDLE=/root/.step/certs/root_ca.crt certbot -q renew' \
  > /etc/cron.d/cert-renew
cat /etc/cron.d/cert-renew
```{{exec}}

---

**Pourquoi des certificats courts + renouvellement auto, c'est l'avenir.** Plus la
durée de vie est courte, moins la révocation compte (un certificat compromis expire
vite tout seul), et plus tu peux **changer d'algorithme rapidement** sur tout ton parc.
C'est exactement le levier de la **crypto-agilité** : le jour où tu migres vers des
algorithmes post-quantiques, un parc qui renouvelle déjà ses certificats toutes les
quelques heures bascule en quelques jours, pas en quelques années.

Tu viens de monter la brique qui rend cette agilité possible.
