import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/whatsapp_service.dart';

class WhatsAppSender extends StatefulWidget {
  const WhatsAppSender({super.key});

  @override
  State<WhatsAppSender> createState() => _WhatsAppSenderState();
}

class _WhatsAppSenderState extends State<WhatsAppSender> {
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final to = _phoneCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (to.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter phone and message')));
      return;
    }

    setState(() => _loading = true);
    try {
      // Ensure user signed in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Sign in required');

      final res = await WhatsAppService.sendMessage(to: to, message: msg);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent: ${res['success'] ?? true}')));
      _msgCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Recipient (E.164) e.g. 15551234567'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _send,
              child: _loading ? const CircularProgressIndicator.adaptive() : const Text('Send WhatsApp Message'),
            ),
          ],
        ),
      ),
    );
  }
}
