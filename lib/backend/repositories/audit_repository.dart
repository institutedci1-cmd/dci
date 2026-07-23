import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuditRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> logAction({
    required String module,
    required String action,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    final deviceMetadata = {
      'platform': kIsWeb ? 'Web' : Platform.operatingSystem,
      'isWeb': kIsWeb,
      ...metadata ?? {},
    };

    await _firestore.collection('audit_logs').add({
      'module': module,
      'action': action,
      'userId': user?.uid ?? 'anonymous',
      'userEmail': user?.email ?? 'anonymous',
      'timestamp': FieldValue.serverTimestamp(),
      'previousValue': previousValue,
      'newValue': newValue,
      'metadata': deviceMetadata,
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

  Stream<List<Map<String, dynamic>>> getAuditLogs({String? userId, int limit = 50}) {
    Query query = _firestore.collection('audit_logs');
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    
    return query
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList());
  }
}
