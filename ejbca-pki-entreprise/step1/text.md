# Étape 1 — Explorer la PKI d'entreprise

Vérifier d'abord qu'EJBCA est prêt — son healthcheck applicatif répond `ALLOK` :

```
curl -s http://localhost/ejbca/publicweb/healthcheck/ejbcahealth
echo
```{{exec}}

> Si la réponse n'est pas `ALLOK`, attends une minute : WildFly (le serveur
> d'applications Java qui héberge EJBCA) peut encore être en train de déployer.

Ouvrir l'interface d'administration dans ton navigateur (avertissement de
certificat = normal, accepte l'exception) :

👉 [Ouvrir l'Admin UI d'EJBCA]({{TRAFFIC_HOST1_443}}/ejbca/adminweb/)

Prends quelques minutes pour repérer les grandes zones du menu :
- **Certification Authorities** : les CA gérées — il existe déjà une
  `ManagementCA`, créée au démarrage pour les besoins internes d'EJBCA ;
- **Certificate Profiles** : le *contenu* des certificats émis (usages, durées,
  extensions) — l'équivalent industriel du *rôle* OpenBao ou de la *provisioner*
  step-ca ;
- **End Entity Profiles** : ce qu'on a le droit de demander pour une entité
  finale (champs du DN, CA autorisées) ;
- **RA Functions** : la gestion des entités finales — on y revient à l'étape 3.

> Deux niveaux de profils, c'est la signature des PKI d'entreprise : on sépare
> « ce que contient le certificat » de « qui a le droit de demander quoi ».

Cliquer sur **Check**.
