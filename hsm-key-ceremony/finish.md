# Terminé

Ce que tu as accompli — une cérémonie de clés de bout en bout :
- créé un **token** dans un HSM (SoftHSM2) ;
- **généré la clé de CA racine à l'intérieur** du module, jamais sur le disque ;
- **prouvé** que la clé privée est non extractible — le HSM refuse de la divulguer ;
- signé un **certificat racine auto-signé** *via* le HSM, sans jamais exposer la clé.

Tu as posé le dernier étage de la pyramide du parcours : non plus *comment émettre*,
mais **comment protéger ce qui rend l'émission digne de confiance**.

**Le parcours complet :**

| Lab | Question traitée |
|-----|------------------|
| niveau 0 (step-ca) | comment émettre un certificat ? |
| niveau 1 (token court) | comment automatiser sans secret durable ? |
| OpenBao | comment rendre les certificats courts et dynamiques ? |
| OpenXPKI | comment encadrer l'émission par une validation humaine ? |
| niveau 2 (HSM) | comment protéger la clé qui fait foi ? |

**Pour aller plus loin :**
- rejouer la cérémonie avec une clé **ECDSA** plutôt que RSA ;
- signer une **intermédiaire** par la racine du HSM, puis des certificats feuilles par l'intermédiaire ;
- brancher la clé du HSM sur une vraie CA (step-ca compilé avec PKCS#11, ou EJBCA/OpenXPKI adossés à un HSM).
