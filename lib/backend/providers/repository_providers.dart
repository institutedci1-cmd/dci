import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/daily_report_repository.dart';
import '../repositories/homework_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/announcement_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/config_repository.dart';
import '../repositories/audit_repository.dart';
import '../services/whatsapp_service.dart';
import '../services/storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepository();
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final whatsappServiceProvider = Provider<WhatsappService>((ref) {
  return WhatsappService();
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

final studentsStreamProvider = StreamProvider((ref) {
  return ref.watch(studentRepositoryProvider).getAllStudentsStream();
});

final userStreamProvider = StreamProvider((ref) {
  return ref.watch(userRepositoryProvider).getUserStream();
});

final unreadNotificationsCountProvider = StreamProvider((ref) {
  return ref.watch(notificationRepositoryProvider).getUnreadCountStream();
});

final instituteInfoStreamProvider = StreamProvider((ref) {
  return ref.watch(configRepositoryProvider).getInstituteInfoStream();
});

final announcementsStreamProvider = StreamProvider((ref) {
  return ref.watch(announcementRepositoryProvider).getAnnouncementsStream();
});

final studentAttendanceLogsProvider = StreamProvider((ref) {
  return ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs();
});

final homeworkStreamProvider = StreamProvider((ref) {
  return ref.watch(homeworkRepositoryProvider).getUserHomework();
});

final recentReportsProvider = StreamProvider.family<dynamic, int>((ref, limit) {
  return ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: limit);
});

final subjectsStreamProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(configRepositoryProvider).getSubjectsStream();
});

final teacherSubjectsProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(userRepositoryProvider).getAllUserSubjects();
});
