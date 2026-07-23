import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';

enum UserRole { director, admin, teacher, student, unknown }

class AccessControl {
  final Teacher? user;

  AccessControl(this.user);

  UserRole get role {
    if (user == null) return UserRole.unknown;
    final roleStr = user!.role.trim().toLowerCase();
    return switch (roleStr) {
      'director' => UserRole.director,
      'admin' => UserRole.admin,
      'teacher' => UserRole.teacher,
      'student' => UserRole.student,
      _ => UserRole.unknown,
    };
  }

  // --- Student Management ---
  bool get canManageStudents => role == UserRole.director || role == UserRole.admin;
  bool get canViewStudents => role != UserRole.student && role != UserRole.unknown;
  bool get isStudent => role == UserRole.student;

  // --- Teacher/Staff Management ---
  bool get canManageTeachers => role == UserRole.director || role == UserRole.admin;
  bool get canViewFacultyList => role == UserRole.director || role == UserRole.admin;

  // --- Attendance ---
  bool get canMarkAttendance => role == UserRole.teacher || role == UserRole.admin || role == UserRole.director;
  bool get canViewFullAttendanceReports => role == UserRole.director || role == UserRole.admin;

  // --- Examination & Results ---
  bool get canManageExams => role == UserRole.director || role == UserRole.admin;
  bool get canEnterMarks => role == UserRole.teacher || role == UserRole.admin || role == UserRole.director;
  bool get canViewFullResults => role == UserRole.director || role == UserRole.admin;

  // --- Daily Reports ---
  bool get canSubmitDailyReport => role == UserRole.teacher;
  bool get canViewDailyReports => role != UserRole.student && role != UserRole.unknown;

  // --- Global Reports & Analytics ---
  bool get canViewAdminReports => role == UserRole.director || role == UserRole.admin;

  // --- Settings ---
  bool get canManageFullSettings => role == UserRole.director;
  bool get canManageLimitedSettings => role == UserRole.admin;
}

final accessControlProvider = Provider<AccessControl>((ref) {
  final user = ref.watch(currentUserDataStreamProvider).value;
  return AccessControl(user);
});
