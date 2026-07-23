import 'package:d_c_i_teacher_app/backend/models/daily_report_template.dart';
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
    final user = _auth.currentUser;
    final reports = await getReports(limit: 1, creatorId: user?.uid);
    return reports.isNotEmpty ? reports.first : null;
  }

  Future<DailyReport?> getReportById(String id) async {
    final doc = await _reportsCollection.doc(id).get();
    return doc.exists ? DailyReport.fromFirestore(doc) : null;
  }

  Future<List<DailyReport>> getReports({int limit = 20, String? creatorId}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    Query query = _reportsCollection;
    if (creatorId != null) {
      query = query.where('createdBy', isEqualTo: creatorId);
    }

    final querySnapshot = await query.limit(limit).get();

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
  Stream<List<DailyReport>> getRecentReports({int limit = 3, String? creatorId}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    Query query = _reportsCollection;
    if (creatorId != null) {
      query = query.where('createdBy', isEqualTo: creatorId);
    }

    return query
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

  // Templates
  Future<void> saveTemplate(DailyReportTemplate template) async {
    await _firestore.collection('daily_report_templates').add(template.toFirestore());
  }

  Stream<List<DailyReportTemplate>> getTemplatesStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('daily_report_templates')
        .where('createdBy', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DailyReportTemplate.fromFirestore(doc)).toList());
  }

  Future<void> deleteTemplate(String id) async {
    await _firestore.collection('daily_report_templates').doc(id).delete();
  }
}
