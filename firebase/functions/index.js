const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const axios = require("axios").default;
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');
const smClient = new SecretManagerServiceClient();

let _cachedWhatsApp = null;

async function getWhatsAppCredentials() {
	// Prefer functions config for local/dev; otherwise load from Secret Manager
	if (_cachedWhatsApp) return _cachedWhatsApp;

	const cfg = functions.config().whatsapp || {};
	if (cfg.token && cfg.phone_id) {
		_cachedWhatsApp = { token: cfg.token, phoneId: cfg.phone_id };
		return _cachedWhatsApp;
	}

	// Secret Manager names: WHATSAPP_TOKEN and WHATSAPP_PHONE_ID
	const projectId = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || process.env.FIREBASE_CONFIG && JSON.parse(process.env.FIREBASE_CONFIG).projectId;
	if (!projectId) {
		throw new Error('GCP project id not found in environment; cannot load secrets');
	}

	async function accessSecret(name) {
		const namePath = `projects/${projectId}/secrets/${name}/versions/latest`;
		const [version] = await smClient.accessSecretVersion({ name: namePath });
		const payload = version.payload.data.toString('utf8');
		return payload;
	}

	try {
		const token = await accessSecret('WHATSAPP_TOKEN');
		const phoneId = await accessSecret('WHATSAPP_PHONE_ID');
		_cachedWhatsApp = { token: token.trim(), phoneId: phoneId.trim() };
		return _cachedWhatsApp;
	} catch (err) {
		// Fall back to functions config error handled by caller
		return null;
	}
}

let _cachedVerifyToken = null;
async function getVerifyToken() {
	if (_cachedVerifyToken) return _cachedVerifyToken;
	const cfg = functions.config().whatsapp || {};
	if (cfg.verify_token) {
		_cachedVerifyToken = cfg.verify_token;
		return _cachedVerifyToken;
	}

	const projectId = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || process.env.FIREBASE_CONFIG && JSON.parse(process.env.FIREBASE_CONFIG).projectId;
	if (!projectId) return null;
	try {
		const namePath = `projects/${projectId}/secrets/WHATSAPP_VERIFY_TOKEN/versions/latest`;
		const [version] = await smClient.accessSecretVersion({ name: namePath });
		const payload = version.payload.data.toString('utf8');
		_cachedVerifyToken = payload.trim();
		return _cachedVerifyToken;
	} catch (err) {
		return null;
	}
}

// Callable Cloud Function to send an outbound WhatsApp text message
exports.sendWhatsAppMessage = functions.https.onCall(async (data, context) => {
	if (!context.auth) {
		throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
	}

	const to = data.to;
	const message = data.message;
	if (!to || !message) {
		throw new functions.https.HttpsError('invalid-argument', '`to` and `message` are required.');
	}

	const creds = await getWhatsAppCredentials();
	if (!creds || !creds.token || !creds.phoneId) {
		throw new functions.https.HttpsError('failed-precondition', 'WhatsApp credentials not configured.');
	}
	const token = creds.token;
	const phoneId = creds.phoneId;

	const url = `https://graph.facebook.com/v17.0/${phoneId}/messages`;
	try {
		const resp = await axios.post(
			url,
			{
				messaging_product: "whatsapp",
				to: to,
				type: "text",
				text: { body: message },
			},
			{
				headers: {
					Authorization: `Bearer ${token}`,
					"Content-Type": "application/json",
				},
			}
		);
		return { success: true, response: resp.data };
	} catch (err) {
		const code = err.response ? err.response.status : 500;
		const body = err.response ? err.response.data : err.message;
		throw new functions.https.HttpsError('internal', 'WhatsApp API error', { code, body });
	}
});

// Webhook endpoint to receive incoming WhatsApp messages from Meta
exports.whatsappWebhook = functions.https.onRequest(async (req, res) => {
	// Verification challenge
	if (req.method === 'GET') {
		const mode = req.query['hub.mode'];
		const challenge = req.query['hub.challenge'];
		const verifyToken = req.query['hub.verify_token'];
		const expected = await getVerifyToken();
		if (mode === 'subscribe' && verifyToken && expected && verifyToken === expected) {
			res.status(200).send(challenge);
			return;
		}
		res.status(403).send('Verification failed');
		return;
	}

	// POST: handle incoming messages
	try {
		const body = req.body || {};
		// Meta sends an array of entry objects
		const entries = body.entry || [];
		const writes = [];
		for (const entry of entries) {
			const changes = entry.changes || [];
			for (const change of changes) {
				const value = change.value || {};
				const messages = (value.messages) || [];
				for (const m of messages) {
					const from = m.from || m.sender?.id || null;
					const timestamp = m.timestamp ? Number(m.timestamp) : Date.now();
					const text = m.text?.body || null;
					const doc = {
						from: from,
						timestamp: timestamp,
						text: text,
						raw: m,
						receivedAt: admin.firestore.FieldValue.serverTimestamp(),
					};
					writes.push(admin.firestore().collection('whatsapp_messages').add(doc));
				}
			}
		}
		await Promise.all(writes);
		res.status(200).send('ok');
	} catch (err) {
		console.error('webhook error', err);
		res.status(500).send('error');
	}
});
