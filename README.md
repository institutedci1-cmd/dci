# Deshmukh Teacher App

A Flutter project designed for teachers at Deshmukh Coaching Institute.

## Deployment Guide

### Android
1. **Keystore**: Create a release keystore and place it in a secure location.
2. **Configuration**: Create `android/key.properties` (use `android/key.properties.example` as a template) and fill in your keystore details.
3. **Build**: Run `flutter build apk --release` or `flutter build appbundle --release`.

### iOS
1. **Signing**: Open `ios/Runner.xcworkspace` in Xcode and configure your Development Team in the "Signing & Capabilities" tab.
2. **Build**: Run `flutter build ipa --release`.

### Firebase
1. Ensure the Firebase Project ID in `lib/backend/firebase/firebase_config.dart` matches your production project.
2. Deploy Firestore rules and indexes using `firebase deploy --only firestore`.

## Project Configuration
- **Package Name**: `com.dciteacherapp`
- **Target SDK**: 35 (Android)
- **Min SDK**: 23 (Android) / 13.0 (iOS)

## WhatsApp Cloud API Integration

This project includes a Firebase Cloud Function `sendWhatsAppMessage` and a small Flutter client UI to send outbound WhatsApp text messages via the Meta/WhatsApp Cloud API.

Quick setup

I implemented both outgoing and incoming flows and added test scripts.

To run the automated smoke tests (in `firebase/functions`):

```bash
# Bash
cd firebase/functions
./test_whatsapp_integration.sh

# PowerShell
cd firebase/functions
./test_whatsapp_integration.ps1 -ProjectId <PROJECT_ID> -Region <REGION> -VerifyToken <VERIFY_TOKEN>
```

The scripts deploy the functions and POST a sample incoming message to the webhook to verify Firestore writes.
- Configure WhatsApp credentials for Cloud Functions (replace placeholders):

```bash
firebase functions:config:set whatsapp.token="YOUR_PAGE_ACCESS_TOKEN" whatsapp.phone_id="YOUR_PHONE_NUMBER_ID"
```

- Deploy the Cloud Function:

```bash
cd firebase/functions
firebase deploy --only functions:sendWhatsAppMessage
```

- Add `cloud_functions` to the Flutter app and fetch packages:

```bash
flutter pub get
```

Usage from the app

- A callable function is implemented: `sendWhatsAppMessage`.
- A helper service is at `lib/backend/whatsapp_service.dart` and a simple UI widget at `lib/components/whatsapp_sender/whatsapp_sender.dart`.
- The callable requires an authenticated Firebase user.

Security notes

- For production, consider storing the WhatsApp token in Secret Manager and referencing it from Cloud Functions rather than `functions.config()`.
	- To create secrets and grant access to the Cloud Functions service account:

```bash
# Create secrets
gcloud secrets create WHATSAPP_TOKEN --replication-policy="automatic"
gcloud secrets create WHATSAPP_PHONE_ID --replication-policy="automatic"

# Add values
echo -n "YOUR_PAGE_ACCESS_TOKEN" | gcloud secrets versions add WHATSAPP_TOKEN --data-file=-
echo -n "YOUR_PHONE_NUMBER_ID" | gcloud secrets versions add WHATSAPP_PHONE_ID --data-file=-

# Grant the Cloud Functions runtime service account access to read secrets
# Replace <PROJECT_ID> with your project id
gcloud projects add-iam-policy-binding <PROJECT_ID> \
	--member="serviceAccount:<PROJECT_ID>@appspot.gserviceaccount.com" \
	--role="roles/secretmanager.secretAccessor"
```

The functions code will prefer `functions.config().whatsapp` for local/dev convenience, and fall back to Secret Manager in production.

Webhook (incoming messages)

- A webhook endpoint `whatsappWebhook` is exposed in Cloud Functions. Configure your WhatsApp Cloud API app to forward incoming messages to:

```
https://REGION-PROJECT.cloudfunctions.net/whatsappWebhook
```

- The webhook verifies using the `WHATSAPP_VERIFY_TOKEN` secret or `functions.config().whatsapp.verify_token`.
- Incoming WhatsApp message objects are stored in Firestore under the `whatsapp_messages` collection. A simple inbox UI is provided at `lib/components/whatsapp_sender/whatsapp_inbox.dart`.
- If you need two-way messaging (receive messages), I can add a webhook handler in `firebase/functions` and instructions to wire it to your public endpoint.

If you'd like, I can now deploy and run an end-to-end test or add incoming webhook handling.

