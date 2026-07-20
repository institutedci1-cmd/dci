import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';
import 'package:d_c_i_teacher_app/backend/repositories/result_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/models/announcement.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';
import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/models/homework_assignment.dart';
import 'package:d_c_i_teacher_app/backend/repositories/attendance_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/daily_report_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/homework_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/exam_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/student_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/auth_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/user_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/announcement_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/notification_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/config_repository.dart';
import 'package:d_c_i_teacher_app/backend/repositories/audit_repository.dart';
import 'package:d_c_i_teacher_app/backend/services/whatsapp_service.dart';
import 'package:d_c_i_teacher_app/backend/services/storage_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
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
  final configRepo = ref.watch(configRepositoryProvider);
  return UserRepository(configRepository: configRepo);
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

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepository();
});

final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  return ResultRepository();
});


final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});

final studentsStreamProvider = StreamProvider<List<Student>>((ref) {
  return ref.watch(studentRepositoryProvider).getAllStudentsStream();
});

final currentUserDataStreamProvider = StreamProvider<Teacher?>((ref) {
  return ref.watch(userRepositoryProvider).getUserStream();
});

final userDataStreamProvider = StreamProvider.family<Teacher?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUserStreamById(uid);
});

final allUsersStreamProvider = StreamProvider<List<Teacher>>((ref) {
  return ref.watch(userRepositoryProvider).getAllUsersStream();
});

final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).getUnreadCountStream();
});

final instituteInfoStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return ref.watch(configRepositoryProvider).getInstituteInfoStream();
});

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  return ref.watch(announcementRepositoryProvider).getAnnouncementsStream();
});

final studentAttendanceLogsProvider = StreamProvider<List<StudentAttendance>>((ref) {
  return ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs();
});

final dailyAttendanceReportProvider = FutureProvider.family<({List<Student> students, List<StudentAttendance> attendance}), ({String className, DateTime date})>((ref, arg) async {
  final studentRepo = ref.read(studentRepositoryProvider);
  final attendanceRepo = ref.read(attendanceRepositoryProvider);

  final results = await Future.wait([
    studentRepo.getStudentsByClass(arg.className),
    attendanceRepo.getDailyAttendance(arg.className, arg.date),
  ]);

  return (
    students: results[0] as List<Student>,
    attendance: results[1] as List<StudentAttendance>,
  );
});

final studentAttendanceHistoryProvider = StreamProvider.family<List<StudentAttendance>, String>((ref, studentId) {
  return ref.watch(attendanceRepositoryProvider).getStudentAttendanceHistory(studentId);
});

final homeworkStreamProvider = StreamProvider<List<HomeworkAssignment>>((ref) {
  return ref.watch(homeworkRepositoryProvider).getUserHomework();
});

final examsStreamProvider = StreamProvider<List<Exam>>((ref) {
  return ref.watch(examRepositoryProvider).getExamsStream();
});

final teacherExamsStreamProvider = StreamProvider.family<List<Exam>, String>((ref, teacherUid) {
  return ref.watch(examRepositoryProvider).getExamsByTeacherStream(teacherUid);
});

final dateExamsStreamProvider = StreamProvider.family<List<Exam>, DateTime>((ref, date) {
  return ref.watch(examRepositoryProvider).getExamsByDateStream(date);
});

final examResultsStreamProvider = StreamProvider.family<List<ExamResult>, String>((ref, examId) {
  return ref.watch(resultRepositoryProvider).getExamResultsStream(examId);
});

final studentResultsStreamProvider = StreamProvider.family<List<ExamResult>, String>((ref, studentId) {
  return ref.watch(resultRepositoryProvider).getStudentResultsStream(studentId);
});

final teacherResultsStreamProvider = StreamProvider.family<List<ExamResult>, String>((ref, teacherUid) {
  return ref.watch(resultRepositoryProvider).getResultsByRecordedByStream(teacherUid);
});


final recentReportsProvider = StreamProvider.family<List<DailyReport>, int>((ref, limit) {
  return ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: limit);
});

final subjectsStreamProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(configRepositoryProvider).getSubjectsStream();
});

final teacherSubjectsProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(userRepositoryProvider).getAllUserSubjects();
});
