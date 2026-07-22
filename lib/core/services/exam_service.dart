import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class ExamService {
  final Ref ref;

  ExamService(this.ref);

  Future<void> scheduleExam(Exam exam) async {
    final repository = ref.read(examRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    Map<String, dynamic>? previousValue;
    if (exam.id.isNotEmpty) {
      final existing = await repository.getExamById(exam.id);
      previousValue = existing?.toFirestore();
    }

    await repository.saveExam(exam);

    await auditRepo.logAction(
      module: 'EXAM',
      action: exam.id.isEmpty ? 'SCHEDULE' : 'UPDATE',
      previousValue: previousValue,
      newValue: exam.toFirestore(),
    );
  }

  Future<void> deleteExam(String examId) async {
    final currentUser = ref.read(currentUserDataStreamProvider).value;
    if (currentUser?.role != 'Admin') {
       throw Exception('Unauthorized: Only Admins can delete exams.');
    }

    final repository = ref.read(examRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final existing = await repository.getExamById(examId);

    await repository.deleteExam(examId);

    await auditRepo.logAction(
      module: 'EXAM',
      action: 'DELETE',
      previousValue: existing?.toFirestore(),
      metadata: {'examId': examId},
    );
  }
}
