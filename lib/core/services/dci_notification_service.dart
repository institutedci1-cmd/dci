import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class DciNotificationService {
  final Ref ref;

  DciNotificationService(this.ref);

  Future<void> markAsRead(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.markAsRead(notificationId);

    await auditRepo.logAction(
      module: 'NOTIFICATION',
      action: 'MARK_READ',
      metadata: {'notificationId': notificationId},
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final existing = await repository.getNotificationById(notificationId);

    await repository.deleteNotification(notificationId);

    await auditRepo.logAction(
      module: 'NOTIFICATION',
      action: 'DELETE',
      previousValue: existing?.toFirestore(),
      metadata: {'notificationId': notificationId},
    );
  }
}

final dciNotificationServiceProvider = Provider<DciNotificationService>((ref) {
  return DciNotificationService(ref);
});
