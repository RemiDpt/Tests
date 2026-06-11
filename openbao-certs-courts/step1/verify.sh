#!/bin/bash
if BAO_ADDR=http://127.0.0.1:8200 bao status >/dev/null 2>&1; then
  exit 0
fi
echo "OpenBao ne répond pas sur 127.0.0.1:8200."
echo "Démarre-le : bao server -dev -dev-root-token-id=root >/var/log/bao.log 2>&1 &"
echo "Puis attends 2 secondes et re-clique sur Check."
exit 1
