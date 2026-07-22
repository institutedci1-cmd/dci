import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class HomeworkService {
  final Ref ref;

  HomeworkService(this.ref);

  Future<void> saveHomework(HomeworkAssignment homework) async {
    final repository = ref.read(homeworkRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    Map<String, dynamic>? previousValue;
    if (homework.id.isNotEmpty) {
      final existing = await repository.getHomeworkById(homework.id);
      previousValue = existing?.toFirestore();
    }

    await repository.saveHomework(homework);

    await auditRepo.logAction(
      module: 'HOMEWORK',
      action: homework.id.isEmpty ? 'CREATE' : 'UPDATE',
      previousValue: previousValue,
      newValue: homework.toFirestore(),
    );
  }

  Future<void> updateStatus(String id, String status) async {
    final repository = ref.read(homeworkRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final existing = await repository.getHomeworkById(id);

    await repository.updateHomeworkStatus(id, status);

    await auditRepo.logAction(
      module: 'HOMEWORK',
      action: 'UPDATE_STATUS',
      previousValue: existing?.toFirestore(),
      newValue: {'status': status},
      metadata: {'homeworkId': id},
    );
  }

  Future<void> deleteHomework(String id) async {
    final repository = ref.read(homeworkRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final existing = await repository.getHomeworkById(id);

    await repository.deleteHomework(id);

    await auditRepo.logAction(
      module: 'HOMEWORK',
      action: 'DELETE',
      previousValue: existing?.toFirestore(),
      metadata: {'homeworkId': id},
    );
  }
}
