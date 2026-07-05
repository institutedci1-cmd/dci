const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const axios = require("axios").default;
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');
const smClient = new SecretManagerServiceClient();
const {Storage} = require('@google-cloud/storage');
const storage = new Storage();

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

							// Detect media or interactive/template payloads
							let media = null;
							let interactive = null;
							let template = null;

							if (m.image) {
								media = { type: 'image', id: m.image.id, mime_type: m.image.mime_type, caption: m.image.caption };
							} else if (m.video) {
								media = { type: 'video', id: m.video.id, mime_type: m.video.mime_type, caption: m.video.caption };
							} else if (m.audio) {
								media = { type: 'audio', id: m.audio.id, mime_type: m.audio.mime_type };
							} else if (m.document) {
								media = { type: 'document', id: m.document.id, mime_type: m.document.mime_type, filename: m.document.filename };
							} else if (m.sticker) {
								media = { type: 'sticker', id: m.sticker.id };
							} else if (m.location) {
								media = { type: 'location', lat: m.location.latitude, lon: m.location.longitude, name: m.location.name };
							} else if (m.contacts) {
								media = { type: 'contacts', contacts: m.contacts };
							}

							if (m.interactive) {
								interactive = m.interactive;
							}
							if (m.template) {
								template = m.template;
							}

							const doc = {
								from: from,
								timestamp: timestamp,
								text: text,
								media: media,
								interactive: interactive,
								template: template,
								raw: m,
								receivedAt: admin.firestore.FieldValue.serverTimestamp(),
							};

							writes.push(admin.firestore().collection('whatsapp_messages').add(doc));
				}
			}
		}
		await Promise.all(writes);

		// Handle statuses if present in the webhook payload
		const statuses = body.entry
			.flatMap(e => (e.changes || []))
			.flatMap(c => (c.value && c.value.statuses) ? c.value.statuses : []);

		const statusWrites = [];
		for (const s of statuses) {
			try {
				const mid = s.id || s.message_id || null;
				const statusObj = {
					messageId: mid,
					status: s.status || s.statuses || null,
					recipient_id: s.recipient_id || s.recipient || null,
					timestamp: s.timestamp ? Number(s.timestamp) : Date.now(),
					raw: s,
					receivedAt: admin.firestore.FieldValue.serverTimestamp(),
				};
				statusWrites.push(admin.firestore().collection('whatsapp_statuses').add(statusObj));

				if (mid) {
					// Try to update corresponding message document with latest status
					const q = await admin.firestore().collection('whatsapp_messages').where('raw.id','==', mid).limit(1).get();
					if (!q.empty) {
						const docRef = q.docs[0].ref;
						statusWrites.push(docRef.update({ last_status: statusObj.status, last_status_at: admin.firestore.FieldValue.serverTimestamp(), raw_status: s }));
					}
				}
			} catch (err) {
				console.error('status handling error', err);
			}
		}
		if (statusWrites.length) await Promise.all(statusWrites);
		res.status(200).send('ok');
	} catch (err) {
		console.error('webhook error', err);
		res.status(500).send('error');
	}
});

// Callable function to fetch media bytes from WhatsApp and store in GCS, returning a signed URL
exports.fetchWhatsAppMedia = functions.https.onCall(async (data, context) => {
	if (!context.auth) {
		throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
	}
	const mediaId = data.mediaId;
	if (!mediaId) {
		throw new functions.https.HttpsError('invalid-argument', 'mediaId required');
	}

	const creds = await getWhatsAppCredentials();
	if (!creds || !creds.token) {
		throw new functions.https.HttpsError('failed-precondition', 'WhatsApp credentials not configured.');
	}
	const token = creds.token;

	try {
		// Get the media URL from WhatsApp Graph API
		const metaUrl = `https://graph.facebook.com/v17.0/${mediaId}`;
		const metaResp = await axios.get(metaUrl, { headers: { Authorization: `Bearer ${token}` } });
		const mediaUrl = metaResp.data && metaResp.data.url;
		if (!mediaUrl) throw new Error('media url not returned');

		// Fetch the media bytes
		const mediaResp = await axios.get(mediaUrl, { responseType: 'arraybuffer' });
		const contentType = mediaResp.headers['content-type'] || 'application/octet-stream';
		const ext = (contentType.split('/')[1] || 'bin').split('+')[0];

		// Determine bucket
		const bucket = admin.storage().bucket();
		const filePath = `whatsapp_media/${mediaId}.${ext}`;
		const file = bucket.file(filePath);

		await file.save(Buffer.from(mediaResp.data), { contentType });

		// Make a signed URL valid for 1 hour
		const [url] = await file.getSignedUrl({ action: 'read', expires: Date.now() + 60 * 60 * 1000 });
		return { url };
	} catch (err) {
		console.error('fetch media error', err);
		throw new functions.https.HttpsError('internal', 'Failed to fetch media', { message: err.message });
	}
});
