# Terminé

> 🟢 **PARCOURS DÉCOUVERTE**

Récapitulatif de ce qui a été monté :
- une hiérarchie racine + intermédiaire ;
- une CA en ligne répondant sur `:4443` ;
- un certificat émis, inspecté et vérifié contre la racine ;
- un certificat **SSH** utilisateur signé par la même autorité.

C'est une PKI complète — HTTPS **et** SSH — en moins de 30 minutes et sans installation
locale.

**Suite du parcours :**
- **Step-ca, token court** — automatiser l'émission sans secret durable.
- **OpenBao** — certificats dynamiques à durée de vie courte.
- **HSM** — protéger la clé de la CA dans un module matériel.

Chaque brique réutilise la même mécanique de scénario que celle-ci.
