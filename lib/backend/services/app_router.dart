import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/daily_report.dart';
import '../models/homework.dart';
import '../providers/repository_providers.dart';
import '../../index.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn = authRepository.currentUser != null;
      final isLoggingIn = state.matchedLocation == LoginWidget.routePath || 
                          state.matchedLocation == SignUpWidget.routePath ||
                          state.matchedLocation == PhoneLoginWidget.routePath;

      if (!loggedIn) {
        return isLoggingIn ? null : LoginWidget.routePath;
      }

      if (isLoggingIn) {
        return HomeDashboardWidget.routePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeDashboardWidget(),
      ),
      GoRoute(
        name: LoginWidget.routeName,
        path: LoginWidget.routePath,
        builder: (context, state) => const LoginWidget(),
      ),
      GoRoute(
        name: PhoneLoginWidget.routeName,
        path: PhoneLoginWidget.routePath,
        builder: (context, state) => const PhoneLoginWidget(),
      ),
      GoRoute(
        name: SignUpWidget.routeName,
        path: SignUpWidget.routePath,
        builder: (context, state) => const SignUpWidget(),
      ),
      GoRoute(
        name: HomeDashboardWidget.routeName,
        path: HomeDashboardWidget.routePath,
        builder: (context, state) => const HomeDashboardWidget(),
      ),
      GoRoute(
        name: DailyReportFormWidget.routeName,
        path: DailyReportFormWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final DailyReport? report = extra?['initialReport'];
          return DailyReportFormWidget(initialReport: report);
        },
      ),
      GoRoute(
        name: ReportsDashboardWidget.routeName,
        path: ReportsDashboardWidget.routePath,
        builder: (context, state) => const ReportsDashboardWidget(),
      ),
      GoRoute(
        name: ReportHistoryWidget.routeName,
        path: ReportHistoryWidget.routePath,
        builder: (context, state) => const ReportHistoryWidget(),
      ),
      GoRoute(
        name: AttendanceTrackerWidget.routeName,
        path: AttendanceTrackerWidget.routePath,
        builder: (context, state) => const AttendanceTrackerWidget(),
      ),
      GoRoute(
        name: AttendanceDashboardWidget.routeName,
        path: AttendanceDashboardWidget.routePath,
        builder: (context, state) => const AttendanceDashboardWidget(),
      ),
      GoRoute(
        name: AttendanceHistoryWidget.routeName,
        path: AttendanceHistoryWidget.routePath,
        builder: (context, state) => const AttendanceHistoryWidget(),
      ),
      GoRoute(
        name: MonthlyReportWidget.routeName,
        path: MonthlyReportWidget.routePath,
        builder: (context, state) => const MonthlyReportWidget(),
      ),
      GoRoute(
        name: StudentListWidget.routeName,
        path: StudentListWidget.routePath,
        builder: (context, state) => const StudentListWidget(),
      ),
      GoRoute(
        name: EditStudentWidget.routeName,
        path: EditStudentWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final Student? student = extra?['student'];
          return EditStudentWidget(student: student);
        },
      ),
      GoRoute(
        name: HomeworkAssignmentWidget.routeName,
        path: HomeworkAssignmentWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final Homework? initialHomework = extra?['initialHomework'];
          return HomeworkAssignmentWidget(initialHomework: initialHomework);
        },
      ),
      GoRoute(
        name: HomeworkHistoryWidget.routeName,
        path: HomeworkHistoryWidget.routePath,
        builder: (context, state) => const HomeworkHistoryWidget(),
      ),
      GoRoute(
        name: AnnouncementsFeedWidget.routeName,
        path: AnnouncementsFeedWidget.routePath,
        builder: (context, state) => const AnnouncementsFeedWidget(),
      ),
      GoRoute(
        name: TeacherProfileWidget.routeName,
        path: TeacherProfileWidget.routePath,
        builder: (context, state) => const TeacherProfileWidget(),
      ),
      GoRoute(
        name: EditProfileWidget.routeName,
        path: EditProfileWidget.routePath,
        builder: (context, state) => const EditProfileWidget(),
      ),
      GoRoute(
        name: NotificationsWidget.routeName,
        path: NotificationsWidget.routePath,
        builder: (context, state) => const NotificationsWidget(),
      ),
      GoRoute(
        name: SettingsWidget.routeName,
        path: SettingsWidget.routePath,
        builder: (context, state) => const SettingsWidget(),
      ),
      GoRoute(
        name: AboutDeshmukhWidget.routeName,
        path: AboutDeshmukhWidget.routePath,
        builder: (context, state) => const AboutDeshmukhWidget(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
