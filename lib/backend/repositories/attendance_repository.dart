import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/attendance_record.dart';
import '../models/student_attendance.dart';

class AttendanceRepository {
  AttendanceRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _attendanceCollection => _firestore.collection('attendance_records');
  CollectionReference get _studentAttendanceCollection => _firestore.collection('student_attendance');

  Future<void> recordStaffAttendance(AttendanceRecord record) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _attendanceCollection.add(record.toFirestore());
  }

  Future<bool> checkAttendanceExists(String className, String subject, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // This query is kept simple to avoid index requirements
    final query = await _studentAttendanceCollection
        .where('class', isEqualTo: className)
        .where('subject', isEqualTo: subject)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> recordStudentAttendance(List<StudentAttendance> attendanceData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    for (var i = 0; i < attendanceData.length; i += 500) {
      final batch = _firestore.batch();
      final chunk = attendanceData.sublist(
          i, i + 500 > attendanceData.length ? attendanceData.length : i + 500);

      for (var studentAttendance in chunk) {
        final dateStr = "${studentAttendance.date.year}-${studentAttendance.date.month}-${studentAttendance.date.day}";
        final docId = "${studentAttendance.className}_${studentAttendance.subject}_${dateStr}_${studentAttendance.studentId}"
            .replaceAll(' ', '_');
        
        final docRef = _studentAttendanceCollection.doc(docId);
        batch.set(docRef, studentAttendance.toFirestore(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  // FIX: Removed server-side orderBy to bypass missing index errors. 
  // We now sort locally in Dart.
  Stream<List<AttendanceRecord>> getUserAttendance({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _attendanceCollection
        .where('createdBy', isEqualTo: user.uid)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList();
          
          // Local Sort: Newest first
          list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          return list.take(limit).toList();
        });
  }

  // FIX: Removed server-side orderBy to bypass missing index errors. 
  // We now sort locally in Dart.
  Stream<List<StudentAttendance>> getStudentAttendanceLogs({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _studentAttendanceCollection
        .where('markedBy', isEqualTo: user.uid)
        .limit(200)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
            .map((doc) => StudentAttendance.fromFirestore(doc))
            .toList();
            
          // Local Sort: Newest first. Pending records (null createdAt) go to top.
          list.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return b.date.compareTo(a.date);
            if (a.createdAt == null) return -1;
            if (b.createdAt == null) return 1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return list.take(limit).toList();
        });
  }

  Future<List<StudentAttendance>> getDailyAttendance(
      String className, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getAttendanceByDateRange(className, startOfDay, endOfDay);
  }

  Future<List<StudentAttendance>> getAttendanceByDateRange(
      String className, DateTime start, DateTime end) async {
    final query = await _studentAttendanceCollection
        .where('class', isEqualTo: className)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    final list = query.docs.map((doc) => StudentAttendance.fromFirestore(doc)).toList();
    // Sort locally to ensure consistency
    list.sort((a, b) => (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date));
    return list;
  }
}
