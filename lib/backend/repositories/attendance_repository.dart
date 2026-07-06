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

  Future<void> recordStudentAttendance(List<StudentAttendance> attendanceData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    
    for (var studentAttendance in attendanceData) {
      final docRef = _studentAttendanceCollection.doc();
      batch.set(docRef, studentAttendance.toFirestore());
    }

    await batch.commit();
  }

  Stream<List<AttendanceRecord>> getUserAttendance() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _attendanceCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList());
  }

  Stream<List<StudentAttendance>> getStudentAttendanceLogs() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _studentAttendanceCollection
        .where('markedBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentAttendance.fromFirestore(doc))
            .toList());
  }
}
