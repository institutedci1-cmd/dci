import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/core/services/staff_service.dart';

class StudentService {
  final Ref ref;

  StudentService(this.ref);

  Future<void> saveStudent(Student student, {bool isNew = false}) async {
    final staffService = ref.read(staffServiceProvider);
    final currentUser = ref.read(currentUserDataStreamProvider).value;

    if (!staffService.canManageStudents(currentUser)) {
      throw Exception('Unauthorized: You do not have permission to manage students.');
    }

    final repository = ref.read(studentRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    Map<String, dynamic>? previousValue;
    if (!isNew) {
      final existing = await repository.getStudentById(student.id);
      previousValue = existing?.toFirestore();
    }

    await repository.updateStudent(student);

    await auditRepo.logAction(
      module: 'STUDENT',
      action: isNew ? 'CREATE' : 'UPDATE',
      previousValue: previousValue,
      newValue: student.toFirestore(),
      metadata: {'studentId': student.studentId},
    );
  }

  Future<void> deleteStudent(String studentId) async {
    final currentUser = ref.read(currentUserDataStreamProvider).value;

    if (currentUser?.role != 'Admin') {
      throw Exception('Unauthorized: Only Admins can delete students.');
    }

    final repository = ref.read(studentRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final existing = await repository.getStudentById(studentId);

    await repository.deleteStudent(studentId);

    await auditRepo.logAction(
      module: 'STUDENT',
      action: 'DELETE',
      previousValue: existing?.toFirestore(),
      metadata: {'studentId': studentId},
    );
  }

  Future<void> bulkImport(List<Map<String, String>> studentsData) async {
    final currentUser = ref.read(currentUserDataStreamProvider).value;
    if (currentUser?.role != 'Admin') {
      throw Exception('Unauthorized: Only Admins can perform bulk imports.');
    }

    final repository = ref.read(studentRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.bulkAddStudents(studentsData);

    await auditRepo.logAction(
      module: 'STUDENT',
      action: 'BULK_IMPORT',
      metadata: {'count': studentsData.length},
    );
  }
}
