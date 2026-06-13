# Étape 1 — Créer la PKI

On repart d'une PKI neuve, exactement comme au niveau 0. La nouveauté n'est pas dans
la création : elle est dans la **façon dont on va se servir de la provisioner** aux
étapes suivantes.

Créer la PKI (version non-interactive, reproductible) :

```
rm -rf /root/.step
echo "LabPKI-non-securise" > /root/.step-password
step ca init --deployment-type standalone --name "CI/CD Lab CA" \
  --dns localhost --address ":4443" --provisioner admin \
  --password-file /root/.step-password
```{{exec}}

`step ca init` crée au passage une provisioner nommée `admin`, de type **JWK**.
Retiens-la : c'est elle qui, à l'étape 3, va jouer le rôle de l'**orchestrateur de
confiance** — celui qui détient le secret et émet des tokens courts pour les jobs.

> Pourquoi repartir de zéro (`rm -rf /root/.step`) ? Pour que le lab soit rejouable :
> si tu recommences l'étape, tu retombes sur une PKI propre, sans état résiduel.

Cliquer sur **Check** une fois la PKI générée.
