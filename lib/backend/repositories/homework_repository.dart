import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/homework.dart';

class HomeworkRepository {
  HomeworkRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _homeworkCollection => _firestore.collection('homework');

  Future<void> addHomework(Homework homework) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _homeworkCollection.add(homework.toFirestore());
  }

  Future<void> updateHomework(Homework homework) async {
    if (homework.id.isEmpty) return;
    await _homeworkCollection.doc(homework.id).set(homework.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteHomework(String homeworkId) async {
    if (homeworkId.isEmpty) return;
    await _homeworkCollection.doc(homeworkId).delete();
  }

  Stream<List<Homework>> getHomeworkHistory({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // Filtering by teacherId to ensure they only see their own history initially
    // Standard ERP practice: admins see all, teachers see theirs.
    return _homeworkCollection
        .where('teacherId', isEqualTo: user.uid)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Homework.fromFirestore(doc))
              .toList();
          
          // Manual sort by assignedDate descending (newest first)
          list.sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
          return list;
        });
  }
  
  // Method to get all homework (for admins or global search if needed)
  Stream<List<Homework>> getAllHomeworkHistory({int limit = 100}) {
    return _homeworkCollection
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Homework.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
          return list;
        });
  }
}
