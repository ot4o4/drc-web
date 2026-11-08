#!/usr/bin/env bash
# Déploie le site web Darou Rahmane Chicken sur Render et vérifie la mise en ligne.
# Usage : ./deploy.sh   (depuis ~/drc-web, après git commit)
set -euo pipefail

SERVICE_ID="srv-dbluinhsrm7s73efrr4g"
URL="https://darourahmane-chicken.onrender.com"
KEY_FILE="$HOME/.secrets/render_key"
KEY="$(cat "$KEY_FILE")"

cd "$(dirname "$0")"

# Le dépôt doit être poussé : on déploie le dernier commit de main.
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  Modifications non commitées — commit + push d'abord." >&2
  exit 1
fi
git push origin main

echo "→ Déclenchement du déploiement Render…"
DEPLOY_ID="$(curl -sS -X POST \
  -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
  -d '{}' "https://api.render.com/v1/services/$SERVICE_ID/deploys" \
  | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')"
echo "  deploy: $DEPLOY_ID"

for i in $(seq 1 60); do
  STATUS="$(curl -sS -H "Authorization: Bearer $KEY" \
    "https://api.render.com/v1/services/$SERVICE_ID/deploys/$DEPLOY_ID" \
    | python3 -c 'import sys,json;print(json.load(sys.stdin)["status"])')"
  echo "  [$i] $STATUS"
  case "$STATUS" in
    live) break ;;
    build_failed|update_failed|canceled)
      echo "✗ Déploiement en échec : $STATUS" >&2; exit 1 ;;
  esac
  sleep 6
done

echo "→ Vérification de $URL"
CODE="$(curl -s -o /dev/null -w '%{http_code}' "$URL/")"
echo "  HTTP $CODE"
[ "$CODE" = "200" ] || { echo "✗ Le site ne répond pas correctement." >&2; exit 1; }
echo "✓ En ligne : $URL"
