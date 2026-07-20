import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';

abstract class IStudentRepository {
  Future<List<Student>> getStudentsByClass(String className);
  Future<List<Student>> getAllStudents();
  Future<List<Student>> getStudentsPaginated(int limit, {DocumentSnapshot? lastDocument});
  Stream<List<Student>> getAllStudentsStream();
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<void> bulkAddStudents(List<Map<String, String>> studentsData);
}
