import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:d_c_i_teacher_app/index.dart';

class NavigationService {
  static void navigateToHome(BuildContext context) {
    context.goNamed(HomeDashboardWidget.routeName);
  }

  static void navigateToLogin(BuildContext context) {
    context.goNamed(LoginWidget.routeName);
  }

  static void navigateToReports(BuildContext context) {
    context.goNamed(ReportsDashboardWidget.routeName);
  }

  static void navigateToAttendanceDashboard(BuildContext context) {
    context.goNamed(AttendanceDashboardWidget.routeName);
  }

  static void navigateToDailyReport(BuildContext context) {
    context.goNamed(DailyReportFormWidget.routeName);
  }

  static void navigateToHomework(BuildContext context) {
    context.goNamed(HomeworkAssignmentWidget.routeName);
  }

  static void navigateToStudentList(BuildContext context) {
    context.goNamed(StudentListWidget.routeName);
  }

  static void navigateToExams(BuildContext context) {
    context.goNamed(ExamsDashboardWidget.routeName);
  }

  static void navigateToResults(BuildContext context) {
    context.goNamed(ExamsDashboardWidget.routeName);
  }

  static void navigateToExamsDashboard(BuildContext context) {
    context.goNamed(ExamsDashboardWidget.routeName);
  }

  static void navigateToAnnouncements(BuildContext context) {
    context.goNamed(AnnouncementsFeedWidget.routeName);
  }

  static void navigateToAbout(BuildContext context) {
    context.goNamed(AboutDCIWidget.routeName);
  }

  static void navigateToStudentProfile(BuildContext context, {required dynamic student}) {
    context.pushNamed(
      StudentProfileWidget.routeName,
      extra: {'student': student},
    );
  }

  static void navigateToEditStudent(BuildContext context, {dynamic student}) {
    context.pushNamed(
      EditStudentWidget.routeName,
      extra: {'student': student},
    );
  }

  static void navigateToTeacherProfile(BuildContext context, {dynamic userData}) {
    context.pushNamed(
      TeacherProfileWidget.routeName,
      extra: {'userData': userData},
    );
  }
}
