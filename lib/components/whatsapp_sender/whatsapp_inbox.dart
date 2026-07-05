import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../backend/whatsapp_inbox_service.dart';
import '../../backend/whatsapp_service.dart';

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
            final text = d['text'] ?? '';
            final media = d['media'];
            final lastStatus = d['last_status'];
            final ts = d['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch((d['timestamp'] is int) ? d['timestamp'] : (d['timestamp'] as num).toInt()) : null;

            String subtitle = text.isNotEmpty ? text : '<non-text message>';
            if (media != null && media is Map) {
              subtitle = '[${media['type']}] ' + subtitle;
            } else if (d['interactive'] != null) {
              subtitle = '[interactive] ' + subtitle;
            } else if (d['template'] != null) {
              subtitle = '[template] ' + subtitle;
            }

            Widget leading;
            if (media != null && media is Map && media['type'] == 'image' && media['id'] != null) {
              leading = FutureBuilder<String>(
                future: WhatsAppService.fetchMediaUrl(mediaId: media['id'] as String),
                builder: (context, snapUrl) {
                  if (snapUrl.hasData) {
                    return Image.network(snapUrl.data!, width: 56, height: 56, fit: BoxFit.cover);
                  }
                  return const SizedBox(width: 56, height: 56);
                },
              );
            } else {
              leading = const SizedBox.shrink();
            }

            return ListTile(
              leading: leading,
              title: Text(from),
              subtitle: Text(subtitle),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (ts != null) Text('${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'),
                  if (lastStatus != null) Text(lastStatus, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
