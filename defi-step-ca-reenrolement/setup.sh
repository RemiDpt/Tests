#!/bin/bash
set -e
cd /tmp
wget -q https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
dpkg -i step-cli_amd64.deb || apt-get install -f -y
apt-get update -qq
apt-get install -y -qq jq openssl

cd /root

# Ancienne racine RSA — celle qui arrive en fin de vie dans la fiction.
step certificate create "Old Corp Root CA (RSA)" old_root.crt old_root.key \
  --profile root-ca --kty RSA --size 2048 --no-password --insecure

# Nouvelle racine ECDSA — la cible de la migration (fournie, déjà prête).
step certificate create "New Corp Root CA (ECDSA)" new_root.crt new_root.key \
  --profile root-ca --kty EC --curve P-256 --no-password --insecure

mkdir -p /root/parc

# ~50 certificats de service signés par l'ANCIENNE racine.
# Un service sur quatre a des SAN supplémentaires : c'est le piège du réenrôlement.
for i in $(seq 1 50); do
  cn="svc${i}.lab.local"
  if [ $((i % 4)) -eq 0 ]; then
    step certificate create "$cn" "/root/parc/svc${i}.crt" "/root/parc/svc${i}.key" \
      --profile leaf --ca old_root.crt --ca-key old_root.key \
      --san "$cn" --san "api.${cn}" --san "admin.${cn}" \
      --not-after 720h --no-password --insecure >/dev/null 2>&1
  else
    step certificate create "$cn" "/root/parc/svc${i}.crt" "/root/parc/svc${i}.key" \
      --profile leaf --ca old_root.crt --ca-key old_root.key \
      --not-after 720h --no-password --insecure >/dev/null 2>&1
  fi
done

# Services hors-service : ils ne doivent PAS être réenrôlés (Défi 2).
cat > /root/parc/decommissionnes.txt <<'EOF'
svc6
svc13
svc20
svc27
svc34
svc41
svc48
EOF

touch /root/.setup-done
echo "Setup terminé : 50 certificats dans /root/parc, ancienne racine RSA et nouvelle racine ECDSA prêtes."
