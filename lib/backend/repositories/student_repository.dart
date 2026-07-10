import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../models/student.dart';

class StudentRepository {
  StudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _studentsCollection => _firestore.collection('students');

  Future<List<Student>> getStudentsByClass(String className) async {
    // Normalize input to match internal "Class X" format
    final normalizedClass = normalizeClassName(className);

    final querySnapshot = await _studentsCollection
        .where('class', isEqualTo: normalizedClass)
        .get();

    final students = querySnapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
    
    students.sort((a, b) {
      final rollA = int.tryParse(a.rollNo) ?? 0;
      final rollB = int.tryParse(b.rollNo) ?? 0;
      if (rollA != 0 && rollB != 0 && rollA != rollB) return rollA.compareTo(rollB);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return students;
  }

  Future<List<Student>> getAllStudents() async {
    final querySnapshot = await _studentsCollection.get();
    final students = querySnapshot.docs
        .map((doc) => Student.fromFirestore(doc))
        .toList();
    students.sort((a, b) {
      final rollA = int.tryParse(a.rollNo) ?? 0;
      final rollB = int.tryParse(b.rollNo) ?? 0;
      if (rollA != 0 && rollB != 0 && rollA != rollB) return rollA.compareTo(rollB);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return students;
  }

  Stream<List<Student>> getAllStudentsStream() {
    return _studentsCollection.snapshots().map((snapshot) {
      final students = snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
      students.sort((a, b) {
        final rollA = int.tryParse(a.rollNo) ?? 0;
        final rollB = int.tryParse(b.rollNo) ?? 0;
        if (rollA != 0 && rollB != 0 && rollA != rollB) return rollA.compareTo(rollB);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return students;
    });
  }

  Future<void> updateStudent(Student student) async {
    await _studentsCollection.doc(student.id).set(student.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteStudent(String id) async {
    await _studentsCollection.doc(id).delete();
  }

  Future<void> bulkAddStudents(List<Map<String, String>> studentsData) async {
    // Validation: Collect errors for a report
    final List<String> errors = [];
    final Set<String> seenIds = {};
    
    // Process in batches of 500 (Firestore limit)
    for (var i = 0; i < studentsData.length; i += 500) {
      final chunk = studentsData.sublist(
        i, i + 500 > studentsData.length ? studentsData.length : i + 500
      );
      
      final currentBatch = _firestore.batch();
      
      for (var j = 0; j < chunk.length; j++) {
        final data = chunk[j];
        final rowIndex = i + j + 1;
        
        final studentId = data['student_id']?.toString().trim();
        final name = data['name']?.toString().trim();
        final rollNo = data['roll_no']?.toString().trim();
        
        // Basic Validation
        if (studentId == null || studentId.isEmpty) {
          errors.add('Row $rowIndex: Missing Student ID');
          continue;
        }
        if (name == null || name.isEmpty) {
          errors.add('Row $rowIndex ($studentId): Missing Name');
          continue;
        }
        if (seenIds.contains(studentId)) {
          errors.add('Row $rowIndex: Duplicate Student ID ($studentId) in current file');
          continue;
        }
        seenIds.add(studentId);

        // Normalize class name (e.g. "10" or "10th" -> "Class 10")
        String className = normalizeClassName(data['class']?.toString());

        final docRef = _studentsCollection.doc(studentId);
        
        final studentData = {
          'name': name,
          'student_id': studentId,
          'roll_no': rollNo ?? '',
          'class': className,
          'section': data['section']?.toString().trim() ?? '',
          'gender': data['gender']?.toString().trim() ?? '',
          'dob': data['dob']?.toString().trim() ?? '',
          'parent_name': data['parent_name']?.toString().trim() ?? '',
          'parent_phone': data['parent_phone']?.toString().trim() ?? '',
          'alt_phone': data['alt_phone']?.toString().trim() ?? '',
          'email': data['email']?.toString().trim() ?? '',
          'village_city': data['village_city']?.toString().trim() ?? '',
          'address': data['address']?.toString().trim() ?? '',
          'pin_code': data['pin_code']?.toString().trim() ?? '',
          'admission_date': data['admission_date']?.toString().trim() ?? '',
          'batch': data['batch']?.toString().trim() ?? '',
          'fees_status': data['fees_status']?.toString().trim() ?? '',
          'notes': data['notes']?.toString().trim() ?? '',
          'subjects': (data['subjects']?.toString() ?? '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        currentBatch.set(docRef, studentData, SetOptions(merge: true));
      }
      
      try {
        await currentBatch.commit();
      } catch (e) {
        rethrow;
      }
    }
    
    if (errors.isNotEmpty) {
      throw Exception('Import completed with errors:\n${errors.take(5).join("\n")}${errors.length > 5 ? "\n...and ${errors.length - 5} more" : ""}');
    }
  }
}
