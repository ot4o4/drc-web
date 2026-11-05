#!/usr/bin/env bash
# Bascule le site sur le domaine darourahmanechicken.sn une fois le DNS en place.
# Usage : ./switch-domain.sh
set -euo pipefail

DOMAIN="darourahmanechicken.sn"
OLD="darourahmane-chicken.onrender.com"
SVC="srv-dbluinhsrm7s73efrr4g"
cd "$(dirname "$0")"

echo "→ Vérification du DNS pour $DOMAIN"
IP="$(python3 -c "import socket;print(socket.gethostbyname('$DOMAIN'))" 2>/dev/null || true)"
if [ "$IP" != "216.24.57.1" ]; then
  echo "✗ $DOMAIN ne pointe pas encore vers Render (IP: ${IP:-aucune})."
  echo "  Chez le registrar : A @ → 216.24.57.1 et CNAME www → $OLD"
  exit 1
fi
echo "  OK ($IP)"

echo "→ Bascule des liens canoniques"
python3 - "$DOMAIN" "$OLD" <<'EOF'
import sys, pathlib
domain, old = sys.argv[1], sys.argv[2]
for name in ['index.html', 'admin.html', 'sitemap.xml', 'robots.txt', 'README.md']:
    p = pathlib.Path(name)
    if not p.exists():
        continue
    s = p.read_text(encoding='utf-8')
    if old in s:
        p.write_text(s.replace(old, domain), encoding='utf-8')
        print('  ', name)
EOF

echo "→ Publication"
git add -A
git -c user.email="papis@darourahmane.sn" -c user.name="Papis Thiam" commit -q -m "domaine: bascule sur $DOMAIN" || echo "  (rien à committer)"
GT="$(cat /root/.secrets/github_token)"
git push "https://x-access-token:${GT}@github.com/ot4o4/drc-web.git" main

echo "→ Déploiement + vérification"
python3 /root/.hermes/scripts/drc_autodeploy.py

echo "→ Statut du domaine sur Render"
RK="$(cat /root/.secrets/render_key)"
curl -s -H "Authorization: Bearer $RK" "https://api.render.com/v1/services/$SVC/custom-domains" |
  python3 -c "import sys,json;[print('  ', x['customDomain']['name'], x['customDomain']['verificationStatus']) for x in json.load(sys.stdin)]"

echo "✓ Terminé — https://$DOMAIN (et https://www.$DOMAIN)"
