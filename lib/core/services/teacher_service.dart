import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class TeacherService {
  final Ref ref;

  TeacherService(this.ref);

  Future<void> createTeacher({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String designation,
    required String phoneNumber,
    String? employeeId,
    required String subjectExpertise,
  }) async {
    final currentUser = ref.read(currentUserDataStreamProvider).value;
    if (currentUser?.role != 'Admin') {
      throw Exception('Unauthorized: Only Admins can create new faculty profiles.');
    }

    final repository = ref.read(userRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.createNewUser(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
      designation: designation,
      phoneNumber: phoneNumber,
      employeeId: employeeId,
      subjectExpertise: subjectExpertise,
    );

    await auditRepo.logAction(
      module: 'FACULTY',
      action: 'CREATE',
      newValue: {
        'email': email,
        'role': role,
        'displayName': displayName,
      },
    );
  }

  Future<void> updateTeacher(Teacher teacher) async {
    final currentUser = ref.read(currentUserDataStreamProvider).value;
    final isAdmin = currentUser?.role == 'Admin';
    final isDirector = currentUser?.role == 'Director';

    if (!isAdmin && !isDirector && currentUser?.uid != teacher.uid) {
      throw Exception('Unauthorized: You can only update your own profile.');
    }

    final repository = ref.read(userRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    final existing = await repository.getUserDataById(teacher.uid);

    await repository.updateProfile(teacher);

    await auditRepo.logAction(
      module: 'FACULTY',
      action: 'UPDATE',
      previousValue: existing?.toFirestore(),
      newValue: teacher.toFirestore(),
      metadata: {'uid': teacher.uid},
    );
  }

  Future<void> updateProfilePicture(File file, {String? targetUid}) async {
    final repository = ref.read(userRepositoryProvider);
    final auditRepo = ref.read(auditRepositoryProvider);

    await repository.uploadProfilePicture(file, targetUid: targetUid);

    await auditRepo.logAction(
      module: 'FACULTY',
      action: 'UPDATE_PHOTO',
      metadata: {'uid': targetUid ?? 'self'},
    );
  }

  Future<void> toggleNotifications(bool enabled) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.toggleNotifications(enabled);
  }
}
