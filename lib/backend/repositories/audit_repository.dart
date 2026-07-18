import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuditRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> logAction(String action, {Map<String, dynamic>? metadata}) async {
    final user = _auth.currentUser;
    await _firestore.collection('audit_logs').add({
      'action': action,
      'userId': user?.uid ?? 'anonymous',
      'userEmail': user?.email ?? 'anonymous',
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata ?? {},
    });
  }

  Future<void> logError(dynamic error, {StackTrace? stackTrace, String? context}) async {
    final user = _auth.currentUser;
    await _firestore.collection('error_logs').add({
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'userId': user?.uid ?? 'anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
