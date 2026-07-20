import 'package:d_c_i_teacher_app/backend/repositories/interfaces/i_daily_report_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';

class DailyReportRepository implements IDailyReportRepository {
  DailyReportRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _reportsCollection => _firestore.collection('daily_reports');

  @override
  Future<void> submitReport(DailyReport report) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _reportsCollection.add(report.toFirestore());
  }

  @override
  Future<DailyReport?> getLastReport() async {
    final reports = await getReports(limit: 1);
    return reports.isNotEmpty ? reports.first : null;
  }

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
    
    list.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return -1;
      if (b.createdAt == null) return 1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return list;
  }

  @override
  Stream<List<DailyReport>> getRecentReports({int limit = 3}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .limit(50) 
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => DailyReport.fromFirestore(doc))
              .toList();
          
          list.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return -1;
            if (b.createdAt == null) return 1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return list.take(limit).toList();
        });
  }

  @override
  Future<List<DailyReport>> getReportsByDateRange(DateTime start, DateTime end) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final querySnapshot = await _reportsCollection
        .where('createdBy', isEqualTo: user.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();

    return querySnapshot.docs.map((doc) => DailyReport.fromFirestore(doc)).toList();
  }
}
