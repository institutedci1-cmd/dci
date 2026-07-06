import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/daily_report_repository.dart';
import '../repositories/homework_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/announcement_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final dailyReportRepositoryProvider = Provider<DailyReportRepository>((ref) {
  return DailyReportRepository();
});

final homeworkRepositoryProvider = Provider<HomeworkRepository>((ref) {
  return HomeworkRepository();
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});
