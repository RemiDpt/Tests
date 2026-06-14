#!/bin/bash
set -e
BAO_VERSION="2.3.1"
cd /tmp
wget -q "https://github.com/openbao/openbao/releases/download/v${BAO_VERSION}/bao_${BAO_VERSION}_linux_amd64.deb"
dpkg -i "bao_${BAO_VERSION}_linux_amd64.deb" || apt-get install -f -y
apt-get update -qq
apt-get install -y -qq jq
touch /root/.setup-done
