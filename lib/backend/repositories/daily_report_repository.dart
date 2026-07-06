import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _reportsCollection => _firestore.collection('daily_reports');

  Future<void> submitReport({
    required String className,
    required String subject,
    required String teacher,
    required String chapter,
    required String topics,
    required int presentCount,
    required int absentCount,
    required String homeworkAssigned,
    required String remarks,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _reportsCollection.add({
      'class': className,
      'subject': subject,
      'teacher': teacher,
      'chapter': chapter,
      'topics': topics,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'homeworkAssigned': homeworkAssigned,
      'remarks': remarks,
      'createdBy': user.uid,
      'createdByEmail': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getLastReport() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final querySnapshot = await _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.data() as Map<String, dynamic>;
  }

  Stream<QuerySnapshot> getRecentReports({int limit = 3}) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }
}
