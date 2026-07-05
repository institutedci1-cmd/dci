import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../backend/whatsapp_inbox_service.dart';

class WhatsAppInbox extends StatelessWidget {
  const WhatsAppInbox({super.key});

  @override
  Widget build(BuildContext context) {
    final service = WhatsAppInboxService();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: service.messagesStream(),
      builder: (context, snap) {
        if (snap.hasError) return const Text('Error loading messages');
        if (!snap.hasData) return const CircularProgressIndicator.adaptive();
        final docs = snap.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, idx) {
            final d = docs[idx].data();
            final from = d['from'] ?? 'unknown';
            final text = d['text'] ?? '<non-text message>';
            final ts = d['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch((d['timestamp'] is int) ? d['timestamp'] : (d['timestamp'] as num).toInt()) : null;
            return ListTile(
              title: Text(from),
              subtitle: Text(text),
              trailing: ts != null ? Text('${ts.hour}:${ts.minute}') : null,
            );
          },
        );
      },
    );
  }
}
