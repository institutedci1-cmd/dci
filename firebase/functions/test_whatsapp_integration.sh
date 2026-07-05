#!/usr/bin/env bash
set -euo pipefail

# Smoke test for WhatsApp integration
# Requires: firebase CLI, gcloud (if using Secret Manager), jq, curl

PROJECT_ID=${PROJECT_ID:-<PROJECT_ID>}
REGION=${REGION:-us-central1}
VERIFY_TOKEN=${VERIFY_TOKEN:-YOUR_VERIFY_TOKEN}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Installing dependencies..."
npm install

echo "Deploying functions (sendWhatsAppMessage, whatsappWebhook)..."
firebase deploy --project "$PROJECT_ID" --only functions:sendWhatsAppMessage,functions:whatsappWebhook

echo "Waiting for deployment to settle..."
sleep 5

WEBHOOK_URL="https://${REGION}-${PROJECT_ID}.cloudfunctions.net/whatsappWebhook"
echo "Webhook URL: $WEBHOOK_URL"

echo "Verifying webhook (GET challenge)..."
CHALLENGE="health-check-$(date +%s)"
RESPONSE=$(curl -sS -G "$WEBHOOK_URL" --data-urlencode "hub.mode=subscribe" --data-urlencode "hub.challenge=$CHALLENGE" --data-urlencode "hub.verify_token=$VERIFY_TOKEN" || true)
echo "Response: $RESPONSE"

echo "Simulating incoming message (POST)..."
cat > /tmp/sample_whatsapp.json <<'JSON'
{"entry":[{"changes":[{"value":{"messages":[{"from":"15551234567","id":"wamid.test","timestamp":"1620222222","text":{"body":"Hello from test script"}}]}}]}]}
JSON

curl -sS -X POST -H "Content-Type: application/json" -d @/tmp/sample_whatsapp.json "$WEBHOOK_URL"

echo "Posted sample message. Check Firestore 'whatsapp_messages' collection in console." 

echo "Done."
