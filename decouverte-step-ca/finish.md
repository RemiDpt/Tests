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
1. **niveau 1 (token court)** — automatiser l'émission sans secret durable.
2. **OpenBao** — certificats dynamiques à durée de vie courte.
3. **niveau 2 (HSM)** — protéger la clé de la CA dans un module matériel.

Chaque brique réutilise la même mécanique de scénario que celle-ci.
