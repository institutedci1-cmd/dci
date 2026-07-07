import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/homework_assignment.dart';

class HomeworkRepository {
  HomeworkRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _homeworkCollection => _firestore.collection('homework_assignments');

  Future<void> saveHomework(HomeworkAssignment homework) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _homeworkCollection.add(homework.toFirestore());
  }

  Stream<List<HomeworkAssignment>> getUserHomework({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _homeworkCollection
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HomeworkAssignment.fromFirestore(doc))
            .toList());
  }

  Future<void> updateHomeworkStatus(String homeworkId, String status) async {
    if (homeworkId.isEmpty) return;
    await _homeworkCollection.doc(homeworkId).update({'status': status});
  }

  Future<void> deleteHomework(String homeworkId) async {
    if (homeworkId.isEmpty) return;
    await _homeworkCollection.doc(homeworkId).delete();
  }
}
