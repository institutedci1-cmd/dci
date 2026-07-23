import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_c_i_teacher_app/backend/models/exam.dart';

class ExamRepository {
  ExamRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference get _examsCollection => _firestore.collection('exams');

  Future<void> saveExam(Exam exam) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _examsCollection.add(exam.toFirestore());
  }

  Stream<List<Exam>> getExamsStream({int limit = 50}) {
    // We fetch all exams, but could filter by class or createdBy if needed.
    // For now, let's show all upcoming/recent exams.
    return _examsCollection
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exam.fromFirestore(doc))
            .toList());
  }

  Stream<List<Exam>> getExamsByTeacherStream(String teacherUid) {
    return _examsCollection
        .where('createdBy', isEqualTo: teacherUid)
        .snapshots()
        .map((snapshot) {
          final exams = snapshot.docs
              .map((doc) => Exam.fromFirestore(doc))
              .toList();
          // Local sort
          exams.sort((a, b) => b.date.compareTo(a.date));
          return exams;
        });
  }

  Future<List<Exam>> getExamsByTeacher(String teacherUid) async {
    final querySnapshot = await _examsCollection
        .where('createdBy', isEqualTo: teacherUid)
        .get();

    final exams = querySnapshot.docs
        .map((doc) => Exam.fromFirestore(doc))
        .toList();
    
    exams.sort((a, b) => b.date.compareTo(a.date));
    return exams;
  }

  Stream<List<Exam>> getExamsByDateStream(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _examsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exam.fromFirestore(doc))
            .toList());
  }

  Future<Exam?> getExamById(String id) async {
    final doc = await _examsCollection.doc(id).get();
    return doc.exists ? Exam.fromFirestore(doc) : null;
  }

  Future<void> deleteExam(String examId) async {
    if (examId.isEmpty) return;
    await _examsCollection.doc(examId).delete();
  }

  Future<void> setExamPublishStatus(String examId, bool isPublished) async {
    if (examId.isEmpty) return;
    await _examsCollection.doc(examId).update({'isPublished': isPublished});
  }

  Stream<List<Exam>> getExamsByClassStream(String className) {
    return _examsCollection
        .where('class', isEqualTo: className)
        .snapshots()
        .map((snapshot) {
          final exams = snapshot.docs
              .map((doc) => Exam.fromFirestore(doc))
              .toList();
          // Local sort: Upcoming first
          exams.sort((a, b) => a.date.compareTo(b.date));
          return exams;
        });
  }
}
