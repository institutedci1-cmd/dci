param(
  [string]$ProjectId = '<PROJECT_ID>',
  [string]$Region = 'us-central1',
  [string]$VerifyToken = 'YOUR_VERIFY_TOKEN'
)

Write-Host "Installing dependencies..."
npm install

Write-Host "Deploying functions..."
firebase deploy --project $ProjectId --only functions:sendWhatsAppMessage,functions:whatsappWebhook

Start-Sleep -Seconds 5

$webhookUrl = "https://$Region-$ProjectId.cloudfunctions.net/whatsappWebhook"
Write-Host "Webhook URL: $webhookUrl"

Write-Host "Verifying webhook (GET challenge)..."
$challenge = "health-check-$(Get-Date -UFormat %s)"
$response = Invoke-RestMethod -Uri "$webhookUrl?hub.mode=subscribe&hub.challenge=$challenge&hub.verify_token=$VerifyToken" -Method Get
Write-Host "Response: $($response.Content)"

Write-Host "Simulating incoming message (POST)..."
$sample = '{"entry":[{"changes":[{"value":{"messages":[{"from":"15551234567","id":"wamid.test","timestamp":"1620222222","text":{"body":"Hello from test script"}}]}}]}]}'

Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $sample -ContentType 'application/json'

Write-Host "Posted sample message. Check Firestore 'whatsapp_messages' collection in console."
