import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/core/services/student_service.dart';
import 'package:d_c_i_teacher_app/core/services/teacher_service.dart';
import 'package:d_c_i_teacher_app/core/services/attendance_service.dart';
import 'package:d_c_i_teacher_app/core/services/exam_service.dart';
import 'package:d_c_i_teacher_app/core/services/result_service.dart';
import 'package:d_c_i_teacher_app/core/services/report_service.dart';
import 'package:d_c_i_teacher_app/core/services/homework_service.dart';
import 'package:d_c_i_teacher_app/core/services/auth_service.dart';
import 'package:d_c_i_teacher_app/core/services/announcement_service.dart';
import 'package:d_c_i_teacher_app/core/services/dci_notification_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService(ref);
});

final dciNotificationServiceProvider = Provider<DciNotificationService>((ref) {
  return DciNotificationService(ref);
});

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService(ref);
});

final teacherServiceProvider = Provider<TeacherService>((ref) {
  return TeacherService(ref);
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref);
});

final examServiceProvider = Provider<ExamService>((ref) {
  return ExamService(ref);
});

final resultServiceProvider = Provider<ResultService>((ref) {
  return ResultService(ref);
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref);
});

final homeworkServiceProvider = Provider<HomeworkService>((ref) {
  return HomeworkService(ref);
});
