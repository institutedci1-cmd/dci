import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';

class ResultRepository {
  ResultRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _resultsCollection => _firestore.collection('exam_results');

  Future<void> saveResults(List<ExamResult> results) async {
    final batch = _firestore.batch();
    for (var result in results) {
      final docRef = result.id.isEmpty ? _resultsCollection.doc() : _resultsCollection.doc(result.id);
      batch.set(docRef, result.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  Stream<List<ExamResult>> getExamResultsStream(String examId) {
    return _resultsCollection
        .where('examId', isEqualTo: examId)
        .orderBy('marksObtained', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamResult.fromFirestore(doc))
            .toList());
  }

  Stream<List<ExamResult>> getStudentResultsStream(String studentId) {
    return _resultsCollection
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamResult.fromFirestore(doc))
            .toList());
  }

  Stream<List<ExamResult>> getResultsByRecordedByStream(String teacherUid) {
    return _resultsCollection
        .where('recordedBy', isEqualTo: teacherUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamResult.fromFirestore(doc))
            .toList());
  }
}
