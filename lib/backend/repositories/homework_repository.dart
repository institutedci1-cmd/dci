import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeworkRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _homeworkCollection => _firestore.collection('homework_assignments');

  Future<void> saveHomework({
    required String className,
    required String subject,
    required String teacher,
    required String title,
    required String description,
    required String dueDate,
    required String status,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _homeworkCollection.add({
      'class': className,
      'subject': subject,
      'teacher': teacher,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
      'createdBy': user.uid,
      'createdByEmail': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserHomework() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _homeworkCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
