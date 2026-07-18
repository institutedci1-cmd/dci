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
    final reports = await getReports(limit: 1);
    return reports.isNotEmpty ? reports.first : null;
  }

  // FIX: Removed server-side orderBy to bypass missing index errors. 
  // We now sort locally in Dart.
  Future<List<DailyReport>> getReports({int limit = 20}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final querySnapshot = await _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .limit(limit)
        .get();

    final list = querySnapshot.docs
        .map((doc) => DailyReport.fromFirestore(doc))
        .toList();
    
    // Local Sort: Newest first. Pending records (null createdAt) go to top.
    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return -1;
      if (b.createdAt == null) return 1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  Stream<List<DailyReport>> getRecentReports({int limit = 3}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .limit(50) // Fetch a slightly larger batch to sort locally
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => DailyReport.fromFirestore(doc))
              .toList();
          
          // Local Sort: Newest first. Pending records (null createdAt) go to top.
          list.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return -1;
            if (b.createdAt == null) return 1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return list.take(limit).toList();
        });
  }
}
