#!/bin/bash
export BAO_ADDR=http://127.0.0.1:8200
export BAO_TOKEN=root

# 1) Un nom autorisé doit s'émettre.
if ! bao write -format=json pki/issue/prod common_name=app.lab.local ttl=10m >/tmp/ok.json 2>/dev/null; then
  echo "Le rôle 'prod' n'émet pas app.lab.local."
  echo "Existe-t-il, avec allowed_domains=lab.local et allow_subdomains=true ?"
  exit 1
fi

# 2) Un domaine interdit doit être refusé.
if bao write -format=json pki/issue/prod common_name=app.evil.com ttl=10m >/dev/null 2>&1; then
  echo "ÉCHEC : app.evil.com a été émis — le rôle n'est pas contraint au domaine lab.local."
  exit 1
fi

# 3) max_ttl doit plafonner : une demande à 24h ne doit pas donner > ~1h.
CRT=$(bao write -format=json pki/issue/prod common_name=long.lab.local ttl=24h 2>/dev/null | jq -r '.data.certificate // empty')
if [ -n "$CRT" ]; then
  echo "$CRT" > /tmp/long.crt
  NB=$(date -d "$(openssl x509 -in /tmp/long.crt -noout -startdate | cut -d= -f2)" +%s 2>/dev/null)
  NA=$(date -d "$(openssl x509 -in /tmp/long.crt -noout -enddate   | cut -d= -f2)" +%s 2>/dev/null)
  if [ -n "$NB" ] && [ -n "$NA" ]; then
    SPAN=$(( NA - NB ))
    if [ "$SPAN" -gt 7200 ]; then
      echo "ÉCHEC : certificat valide ~$(( SPAN / 3600 )) h — max_ttl n'est pas plafonné à 1 h."
      exit 1
    fi
  fi
fi

exit 0
