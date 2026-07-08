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

    // For better overwriting logic, we could first delete existing records for this class/subject/date
    // But for a simple tick-and-submit, we'll just add. 
    // If we want "Edit Attendance", we'd need to find and update or delete-then-add.
    
    for (var i = 0; i < attendanceData.length; i += 500) {
      final batch = _firestore.batch();
      final chunk = attendanceData.sublist(
          i, i + 500 > attendanceData.length ? attendanceData.length : i + 500);

      for (var studentAttendance in chunk) {
        // We use a deterministic ID to avoid duplicates if submitted multiple times
        // Format: class_subject_date_studentId
        final dateStr = "${studentAttendance.date.year}-${studentAttendance.date.month}-${studentAttendance.date.day}";
        final docId = "${studentAttendance.className}_${studentAttendance.subject}_${dateStr}_${studentAttendance.studentId}"
            .replaceAll(' ', '_');
        
        final docRef = _studentAttendanceCollection.doc(docId);
        batch.set(docRef, studentAttendance.toFirestore(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  Stream<List<AttendanceRecord>> getUserAttendance({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _attendanceCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList());
  }

  Stream<List<StudentAttendance>> getStudentAttendanceLogs({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _studentAttendanceCollection
        .where('markedBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentAttendance.fromFirestore(doc))
            .toList());
  }

  Future<List<StudentAttendance>> getMonthlyAttendance(String className, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    final query = await _studentAttendanceCollection
        .where('class', isEqualTo: className)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    return query.docs.map((doc) => StudentAttendance.fromFirestore(doc)).toList();
  }
}
