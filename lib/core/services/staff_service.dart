import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

class StaffService {
  final Ref ref;

  StaffService(this.ref);

  bool canManageStudents(Teacher? user) {
    if (user == null) return false;
    return user.role == 'Admin' || user.role == 'Director';
  }

  bool canDeleteReport(Teacher? user, String reportCreatedBy) {
    if (user == null) return false;
    if (user.role == 'Admin') return true;
    return user.uid == reportCreatedBy;
  }

  Future<List<Teacher>> getActiveTeachers() async {
    final teachers = await ref.read(userRepositoryProvider).getTeachers();
    // Filter out disabled accounts if applicable in future
    return teachers;
  }

  String getRoleBadgeColor(String role) {
    switch (role) {
      case 'Admin':
        return '#EF4444'; // Red
      case 'Director':
        return '#8B5CF6'; // Purple
      case 'Teacher':
        return '#059669'; // Emerald
      default:
        return '#6B7280'; // Gray
    }
  }
}

final staffServiceProvider = Provider<StaffService>((ref) {
  return StaffService(ref);
});
