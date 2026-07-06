import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentRepository {
  StudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _studentsCollection => _firestore.collection('students');

  Future<List<Student>> getStudentsByClass(String className) async {
    final querySnapshot = await _studentsCollection
        .where('class', isEqualTo: className)
        .orderBy('name')
        .get();

    return querySnapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
  }

  Stream<List<Student>> getAllStudentsStream() {
    return _studentsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
  }
}
