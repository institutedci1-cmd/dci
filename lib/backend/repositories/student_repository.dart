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
        .get();

    final students = querySnapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
    
    students.sort((a, b) {
      final rollA = int.tryParse(a.rollNo) ?? 0;
      final rollB = int.tryParse(b.rollNo) ?? 0;
      if (rollA != 0 && rollB != 0) return rollA.compareTo(rollB);
      return a.name.compareTo(b.name);
    });
    return students;
  }

  Future<List<Student>> getAllStudents() async {
    final querySnapshot = await _studentsCollection.get();
    final students = querySnapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
    students.sort((a, b) => a.name.compareTo(b.name));
    return students;
  }

  Stream<List<Student>> getAllStudentsStream() {
    return _studentsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
  }

  Future<void> updateStudent(Student student) async {
    await _studentsCollection.doc(student.id).set(student.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteStudent(String id) async {
    await _studentsCollection.doc(id).delete();
  }

  Future<void> bulkAddStudents(List<Map<String, String>> studentsData) async {
    print('StudentRepository: Starting bulk add for ${studentsData.length} students');
    
    // Process in batches of 500 (Firestore limit)
    for (var i = 0; i < studentsData.length; i += 500) {
      final chunk = studentsData.sublist(
        i, i + 500 > studentsData.length ? studentsData.length : i + 500
      );
      
      final currentBatch = _firestore.batch();
      
      for (var data in chunk) {
        final studentId = data['student_id']?.toString().trim();
        if (studentId == null || studentId.isEmpty) {
          print('StudentRepository: Skipping student with empty ID');
          continue;
        }

        // We use a specific document ID based on student_id to achieve "upsert" 
        final docRef = _studentsCollection.doc(studentId);
        
        final studentData = {
          'name': data['name']?.toString().trim() ?? '',
          'student_id': studentId,
          'roll_no': data['roll_no']?.toString().trim() ?? '',
          'class': data['class']?.toString().trim() ?? '',
          'parent_phone': data['parent_phone']?.toString().trim() ?? '',
          'updated_at': FieldValue.serverTimestamp(),
        };

        // For new documents, add created_at
        currentBatch.set(docRef, studentData, SetOptions(merge: true));
        // We can't easily conditionally add created_at in a batch set with merge.
        // Usually, we just use a server timestamp for both or handle it differently.
        // Let's just ensure basic fields are there.
      }
      
      try {
        await currentBatch.commit();
        print('StudentRepository: Committed batch of ${chunk.length} students');
      } catch (e) {
        print('StudentRepository: Error committing batch: $e');
        rethrow;
      }
    }
  }
}
