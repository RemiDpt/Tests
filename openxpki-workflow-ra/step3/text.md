# Étape 3 — Côté opérateur RA : valider et émettre

Changer de casquette. Se **déconnecter** de l'interface (menu en haut à droite), puis
se reconnecter en tant qu'**opérateur RA** :
- Username : `raop`
- Password : `openxpki`

Le tableau de bord opérateur est différent : il liste les **demandes en attente**.
1. retrouver la demande de `bob` pour `serveur.lab.local` (l'identifiant de
   workflow noté à l'étape 2) ;
2. l'ouvrir et examiner ce que voit un opérateur : le contenu de la CSR, le profil
   demandé, le demandeur ;
3. **approuver** la demande.

À l'approbation, la CA émet le certificat — le workflow passe en `SUCCESS`.

Récupérer le certificat émis : ouvrir le workflow (ou se reconnecter en `bob`),
télécharger/afficher le **certificat au format PEM**, et le copier dans le terminal.
Coller le contenu dans un fichier (colle entre les deux lignes, termine par `EOF`) :

```
cat > /root/demandeur.crt <<'EOF'
```
*(colle ici le bloc `-----BEGIN CERTIFICATE-----` … `-----END CERTIFICATE-----`)*
```
EOF
```

Inspecter le résultat :

```
openssl x509 -in /root/demandeur.crt -noout -subject -issuer -dates
```{{exec}}

L'émetteur est la CA de démonstration OpenXPKI (« OpenXPKI Issuing DUMMY CA ») — et
le sujet, l'identité validée par l'opérateur.

Cliquer sur **Check**.
