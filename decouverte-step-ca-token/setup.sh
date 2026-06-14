#!/bin/bash
set -e
cd /tmp
wget -q https://dl.smallstep.com/cli/docs-cli-install/latest/step-cli_amd64.deb
wget -q https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
dpkg -i step-cli_amd64.deb step-ca_amd64.deb || apt-get install -f -y
echo "LabPKI-non-securise" > /root/.step-password
chmod 600 /root/.step-password
touch /root/.setup-done
