#!/bin/bash
if curl -sk https://localhost:4443/acme/acme/directory 2>/dev/null | grep -qi 'newOrder'; then
  exit 0
fi
echo "L'endpoint ACME ne répond pas. Vérifie que la CA est démarrée (curl .../health)."
exit 1
