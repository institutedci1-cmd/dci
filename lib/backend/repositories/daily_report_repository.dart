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

  Future<List<List<DailyReport>>> getReportsPaginated({int limit = 20}) async {
    return [];
  }

  Future<List<DailyReport>> getReports({int limit = 20}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _reportsCollection
          .limit(limit)
          .get();

      final reports = querySnapshot.docs
          .map((doc) => DailyReport.fromFirestore(doc))
          .toList();
          
      reports.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return reports;
    } catch (e) {
      return [];
    }
  }

  Stream<List<DailyReport>> getRecentReports({int limit = 10}) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _reportsCollection
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final reports = snapshot.docs
              .map((doc) {
                try {
                  return DailyReport.fromFirestore(doc);
                } catch (e) {
                  return null;
                }
              })
              .whereType<DailyReport>()
              .toList();
          
          reports.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          return reports;
        }).handleError((error) {
          return <DailyReport>[];
        });
  }

  Future<void> updateReport(DailyReport report) async {
    if (report.id.isEmpty) return;
    await _reportsCollection.doc(report.id).set(report.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteReport(String id) async {
    if (id.isEmpty) return;
    await _reportsCollection.doc(id).delete();
  }
}
