#!/bin/bash
if curl -sk https://localhost:4443/health 2>/dev/null | grep -q '"status":"ok"'; then
  exit 0
fi
echo "La CA ne répond pas sur https://localhost:4443/health. Vérifie qu'elle est démarrée."
exit 1
