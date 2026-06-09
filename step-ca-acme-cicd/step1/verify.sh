#!/bin/bash
CFG="/root/.step/config/ca.json"
if [ -f "$CFG" ] && grep -qi '"type": *"ACME"' "$CFG"; then
  exit 0
fi
echo "Provisioner ACME non trouvée. Lance 'step ca provisioner add acme --type ACME'."
exit 1
