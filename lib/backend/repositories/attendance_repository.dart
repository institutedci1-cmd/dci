import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _attendanceCollection => _firestore.collection('attendance_records');

  Future<void> recordAttendance({
    required String status,
    required String remarks,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _attendanceCollection.add({
      'status': status,
      'remarks': remarks,
      'createdBy': user.uid,
      'createdByEmail': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserAttendance() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _attendanceCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
