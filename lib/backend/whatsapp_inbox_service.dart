import 'package:cloud_firestore/cloud_firestore.dart';

class WhatsAppInboxService {
  final _col = FirebaseFirestore.instance.collection('whatsapp_messages');

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream({int limit = 50}) {
    return _col.orderBy('timestamp', descending: true).limit(limit).snapshots();
  }
}
