import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_report.dart';

class DailyReportRepository {
  DailyReportRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _reportsCollection => _firestore.collection('daily_reports');

  Future<void> submitReport(DailyReport report) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _reportsCollection.add(report.toFirestore());
  }

  Future<DailyReport?> getLastReport() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final querySnapshot = await _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return DailyReport.fromFirestore(querySnapshot.docs.first);
  }

  Stream<List<DailyReport>> getRecentReports({int limit = 3}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyReport.fromFirestore(doc))
            .toList());
  }
}
