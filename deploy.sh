#!/bin/bash
# Local deploy script
# Reads config from .env file, injects into templates, deploys to Firebase.
#
# Usage:
#   1. Copy .env.example to .env and fill in your values
#   2. Run: ./deploy.sh

set -euo pipefail

ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Copy .env.example to .env and fill in your values."
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

# Validate required vars
for var in FIREBASE_PROJECT_ID GA4_MEASUREMENT_ID DEFAULT_URL ROUTES_JSON; do
  if [ -z "${!var:-}" ]; then
    echo "Error: $var is not set in $ENV_FILE"
    exit 1
  fi
done

echo "==> Injecting config..."

# Work on copies so we don't modify tracked files
cp public/index.html public/index.html.bak
cp .firebaserc .firebaserc.bak

sed -i.tmp "s|__GA4_MEASUREMENT_ID__|${GA4_MEASUREMENT_ID}|g" public/index.html
sed -i.tmp "s|__DEFAULT_URL__|${DEFAULT_URL}|g" public/index.html
sed -i.tmp "s|__ROUTES_JSON__|${ROUTES_JSON}|g" public/index.html
sed -i.tmp "s|__FIREBASE_PROJECT_ID__|${FIREBASE_PROJECT_ID}|g" .firebaserc
rm -f public/index.html.tmp .firebaserc.tmp

echo "==> Deploying to Firebase Hosting..."
firebase deploy --only hosting

# Restore templates
mv public/index.html.bak public/index.html
mv .firebaserc.bak .firebaserc

echo ""
echo "==> Done! Live at: https://${FIREBASE_PROJECT_ID}.web.app"
