import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';

class ResultRepository {
  ResultRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _resultsCollection => _firestore.collection('exam_results');

  Future<void> saveResults(List<ExamResult> results) async {
    final batch = _firestore.batch();
    for (var result in results) {
      final docRef = result.id.isEmpty ? _resultsCollection.doc() : _resultsCollection.doc(result.id);
      batch.set(docRef, result.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<List<ExamResult>> getExamResults(String examId) async {
    final query = await _resultsCollection
        .where('examId', isEqualTo: examId)
        .get();

    final results = query.docs
        .map((doc) => ExamResult.fromFirestore(doc))
        .toList();
    
    results.sort((a, b) => b.marksObtained.compareTo(a.marksObtained));
    return results;
  }

  Future<List<ExamResult>> getStudentResults(String studentId) async {
    final query = await _resultsCollection
        .where('studentId', isEqualTo: studentId)
        .get();

    final results = query.docs
        .map((doc) => ExamResult.fromFirestore(doc))
        .toList();

    results.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return results;
  }

  Stream<List<ExamResult>> getExamResultsStream(String examId) {
    return _resultsCollection
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs
              .map((doc) => ExamResult.fromFirestore(doc))
              .toList();
          // Local sort to avoid requiring a Firestore composite index
          results.sort((a, b) => b.marksObtained.compareTo(a.marksObtained));
          return results;
        });
  }

  Stream<List<ExamResult>> getStudentResultsStream(String studentId) {
    return _resultsCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs
              .map((doc) => ExamResult.fromFirestore(doc))
              .toList();
          // Local sort to avoid index
          results.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return results;
        });
  }

  Stream<List<ExamResult>> getResultsByRecordedByStream(String teacherUid) {
    return _resultsCollection
        .where('recordedBy', isEqualTo: teacherUid)
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs
              .map((doc) => ExamResult.fromFirestore(doc))
              .toList();
          // Local sort to avoid index
          results.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return results;
        });
  }

  Stream<List<ExamResult>> getAllResultsStream({int limit = 500}) {
    return _resultsCollection
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ExamResult.fromFirestore(doc)).toList());
  }
}
