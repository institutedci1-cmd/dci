import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/pages/attendance_tracker/attendance_tracker_widget.dart';
import 'package:d_c_i_teacher_app/pages/exams/enter_marks_widget.dart';
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
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/backend/repositories/attendance_repository.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report_template.dart';
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

final currentStudentStreamProvider = StreamProvider<Student?>((ref) {
  final user = ref.watch(currentUserDataStreamProvider).value;
  if (user == null || user.role != 'Student') return Stream.value(null);
  return ref.watch(studentRepositoryProvider).getStudentByIdStream(user.uid);
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

final auditLogsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final access = ref.watch(accessControlProvider);
  final userId = (access.role == UserRole.teacher) ? access.user?.uid : null;
  return ref.watch(auditRepositoryProvider).getAuditLogs(userId: userId);
});

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  return ref.watch(announcementRepositoryProvider).getAnnouncementsStream();
});

final studentAttendanceLogsProvider = StreamProvider<List<StudentAttendance>>((ref) {
  final access = ref.watch(accessControlProvider);
  final creatorId = (access.role == UserRole.teacher) ? access.user?.uid : null;
  return ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(userId: creatorId);
});

final myAttendanceHistoryProvider = StreamProvider<List<StudentAttendance>>((ref) {
  final user = ref.watch(currentUserDataStreamProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(attendanceRepositoryProvider).getStudentAttendanceHistory(user.uid);
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

final studentHomeworkStreamProvider = StreamProvider.family<List<HomeworkAssignment>, String>((ref, className) {
  return ref.watch(homeworkRepositoryProvider).getHomeworkByClass(className);
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

final studentExamsStreamProvider = StreamProvider.family<List<Exam>, String>((ref, className) {
  return ref.watch(examRepositoryProvider).getExamsByClassStream(className);
});

final dateExamsStreamProvider = StreamProvider.family<List<Exam>, DateTime>((ref, date) {
  return ref.watch(examRepositoryProvider).getExamsByDateStream(date);
});

final examResultsStreamProvider = StreamProvider.family<List<ExamResult>, String>((ref, examId) {
  return ref.watch(resultRepositoryProvider).getExamResultsStream(examId);
});

final allResultsStreamProvider = StreamProvider<List<ExamResult>>((ref) {
  return ref.watch(resultRepositoryProvider).getAllResultsStream();
});

final studentResultsStreamProvider = StreamProvider.family<List<ExamResult>, String>((ref, studentId) {
  return ref.watch(resultRepositoryProvider).getStudentResultsStream(studentId);
});

final teacherResultsStreamProvider = StreamProvider.family<List<ExamResult>, String>((ref, teacherUid) {
  return ref.watch(resultRepositoryProvider).getResultsByRecordedByStream(teacherUid);
});


final recentReportsProvider = StreamProvider.family<List<DailyReport>, int>((ref, limit) {
  final access = ref.watch(accessControlProvider);
  final creatorId = (access.role == UserRole.teacher) ? access.user?.uid : null;
  return ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: limit, creatorId: creatorId);
});

final dailyReportTemplatesStreamProvider = StreamProvider<List<DailyReportTemplate>>((ref) {
  return ref.watch(dailyReportRepositoryProvider).getTemplatesStream();
});

final subjectsStreamProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(configRepositoryProvider).getSubjectsStream();
});

final teacherSubjectsProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(userRepositoryProvider).getAllUserSubjects();
});

final pendingTasksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final List<Map<String, dynamic>> tasks = [];
  final access = ref.watch(accessControlProvider);
  
  if (access.isStudent) return tasks;

  final examRepo = ref.read(examRepositoryProvider);
  final attendanceRepo = ref.read(attendanceRepositoryProvider);
  
  // 1. Check for today's attendance
  final today = DateTime.now();
  try {
    final hasAttendance = await attendanceRepo.hasAttendanceForDate(today);
    if (!hasAttendance) {
      tasks.add({
        'type': 'attendance',
        'title': 'Mark Today\'s Attendance',
        'subtitle': 'Required for student records',
        'icon': Icons.fact_check_rounded,
        'color': AppColors.warning,
        'route': AttendanceTrackerWidget.routeName,
      });
    }
  } catch (e) {
    debugPrint('PendingTasks: Error checking attendance: $e');
  }

  // 2. Check for past exams without published results
  if (access.canEnterMarks && access.user != null) {
    try {
      final myExams = await examRepo.getExamsByTeacher(access.user!.uid);
      final pastExamsWithoutResults = myExams.where((e) => e.date.isBefore(today) && !e.isPublished).toList();
      
      for (final exam in pastExamsWithoutResults) {
        tasks.add({
          'type': 'marks',
          'title': 'Publish Results: ${exam.subject}',
          'subtitle': 'Exam on ${dateTimeFormat('yMMMd', exam.date)}',
          'icon': Icons.grade_rounded,
          'color': AppColors.primary,
          'route': EnterMarksWidget.routeName,
          'extra': {'exam': exam},
        });
      }
    } catch (e) {
      debugPrint('PendingTasks: Error checking exams: $e');
    }
  }

  return tasks;
});
