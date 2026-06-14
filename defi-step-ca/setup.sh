#!/bin/bash
set -e
cd /tmp
wget -q https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
wget -q https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
dpkg -i step-cli_amd64.deb step-ca_amd64.deb || apt-get install -f -y
apt-get update -qq
apt-get install -y -qq jq
echo "LabPKI-non-securise" > /root/.step-password
chmod 600 /root/.step-password
step ca init --deployment-type standalone --name "Defi Lab Root CA" \
  --dns localhost --address ":4443" --provisioner admin \
  --password-file /root/.step-password --ssh
nohup step-ca "$(step path)/config/ca.json" --password-file /root/.step-password \
  >/var/log/step-ca.log 2>&1 &
touch /root/.setup-done
