# Terminé

Récapitulatif de ce qui a été monté :
- une hiérarchie racine + intermédiaire ;
- une CA en ligne répondant sur `:4443` ;
- un certificat émis, inspecté et vérifié contre la racine.

C'est une PKI complète, en moins de 30 minutes et sans installation locale.

**Suite du parcours :**
1. **OpenBao** — certificats dynamiques à durée de vie courte.
2. **OpenXPKI** — workflow d'autorité d'enregistrement (demande → validation → émission).

Chaque brique réutilise la même mécanique de scénario que celle-ci.
