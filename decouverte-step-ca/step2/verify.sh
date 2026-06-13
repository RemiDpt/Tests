#!/bin/bash
if curl -sk https://localhost:4443/health 2>/dev/null | grep -q '"status":"ok"'; then
  exit 0
fi
if pgrep -x step-ca >/dev/null 2>&1; then
  echo "step-ca tourne mais ne répond pas encore. Attends 2-3 secondes et re-clique sur Check."
else
  echo "step-ca n'est pas démarré. Lance :"
  echo "  step-ca \$(step path)/config/ca.json --password-file /root/.step-password &"
fi
exit 1
