import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class AnnouncementService {
  final Ref ref;

  AnnouncementService(this.ref);

  Future<void> createAnnouncement({
    required String title,
    required String description,
    required String category,
    String? link,
  }) async {
    final repository = ref.read(announcementRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.createAnnouncement(
      title: title,
      description: description,
      category: category,
      link: link,
    );

    await auditRepo.logAction(
      module: 'ANNOUNCEMENT',
      action: 'CREATE',
      newValue: {
        'title': title,
        'category': category,
      },
    );
  }
}

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService(ref);
});
