#!/bin/bash
# Build and deploy to Firebase Hosting
# Usage: ./deploy.sh

set -euo pipefail

echo "==> Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo ""
echo "==> Deployment complete!"
echo "    Your site is live at:"
firebase hosting:channel:list 2>/dev/null || true
echo ""
echo "    Default URL: https://$(grep -o '"default": "[^"]*"' .firebaserc | head -1 | cut -d'"' -f4).web.app"
echo ""
echo "    To preview before deploying to production:"
echo "    firebase hosting:channel:deploy preview"
