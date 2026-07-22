import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';

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
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => HomeworkAssignment.fromFirestore(doc))
              .toList();
          
          // Local sort to avoid index
          list.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return list.take(limit).toList();
        });
  }

  Future<HomeworkAssignment?> getHomeworkById(String id) async {
    final doc = await _homeworkCollection.doc(id).get();
    return doc.exists ? HomeworkAssignment.fromFirestore(doc) : null;
  }

  Future<void> updateHomeworkStatus(String homeworkId, String status) async {
    if (homeworkId.isEmpty) return;
    await _homeworkCollection.doc(homeworkId).update({'status': status});
  }

  Future<void> deleteHomework(String homeworkId) async {
    if (homeworkId.isEmpty) return;
    await _homeworkCollection.doc(homeworkId).delete();
  }

  Stream<List<HomeworkAssignment>> getHomeworkByClass(String className) {
    return _homeworkCollection
        .where('className', isEqualTo: className)
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => HomeworkAssignment.fromFirestore(doc))
              .toList();
          
          list.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          
          return list;
        });
  }
}
