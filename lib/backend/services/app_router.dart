import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/index.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return GoRouter(
    // Removed hardcoded initialLocation to allow Web to use the actual URL in the address bar
    debugLogDiagnostics: true,
    refreshListenable: _AuthListenable(authRepository.authStateChanges),
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final loggedIn = user != null;
      
      // Determine if we are on the login page
      final isLoggingIn = state.matchedLocation == LoginWidget.routePath;

      // 1. If not logged in and not on login page, go to login
      if (!loggedIn && !isLoggingIn) {
        return LoginWidget.routePath;
      }

      // 2. If logged in and trying to go to login, go to home
      if (loggedIn && isLoggingIn) {
        return HomeDashboardWidget.routePath;
      }

      // 3. If on root '/', go to home
      if (state.matchedLocation == '/') {
        return HomeDashboardWidget.routePath;
      }

      // 4. Otherwise, stay where you are (this allows URLs like /reportsDashboard to work)
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => HomeDashboardWidget.routePath,
      ),
      GoRoute(
        name: LoginWidget.routeName,
        path: LoginWidget.routePath,
        builder: (context, state) => const LoginWidget(),
      ),
      GoRoute(
        name: HomeDashboardWidget.routeName,
        path: HomeDashboardWidget.routePath,
        builder: (context, state) => const HomeDashboardWidget(),
      ),
      GoRoute(
        name: DailyReportFormWidget.routeName,
        path: DailyReportFormWidget.routePath,
        builder: (context, state) => const DailyReportFormWidget(),
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
        name: ExamsWidget.routeName,
        path: ExamsWidget.routePath,
        builder: (context, state) => const ExamsWidget(),
      ),
      GoRoute(
        name: AddExamWidget.routeName,
        path: AddExamWidget.routePath,
        builder: (context, state) => const AddExamWidget(),
      ),
      GoRoute(
        name: ExamsDashboardWidget.routeName,
        path: ExamsDashboardWidget.routePath,
        builder: (context, state) => const ExamsDashboardWidget(),
      ),
      GoRoute(
        name: EnterMarksWidget.routeName,
        path: EnterMarksWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EnterMarksWidget(exam: extra!['exam'] as Exam);
        },
      ),
      GoRoute(
        name: MeritListWidget.routeName,
        path: MeritListWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MeritListWidget(exam: extra!['exam'] as Exam);
        },
      ),
      GoRoute(
        name: TeacherWiseReportWidget.routeName,
        path: TeacherWiseReportWidget.routePath,
        builder: (context, state) => const TeacherWiseReportWidget(),
      ),
      GoRoute(
        name: DateWiseReportWidget.routeName,
        path: DateWiseReportWidget.routePath,
        builder: (context, state) => const DateWiseReportWidget(),
      ),
      GoRoute(
        name: AttendanceReportWidget.routeName,
        path: AttendanceReportWidget.routePath,
        builder: (context, state) => const AttendanceReportWidget(),
      ),
      GoRoute(
        name: StudentListWidget.routeName,
        path: StudentListWidget.routePath,
        builder: (context, state) => const StudentListWidget(),
      ),
      GoRoute(
        name: StudentProfileWidget.routeName,
        path: StudentProfileWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final Student student = extra!['student'];
          return StudentProfileWidget(student: student);
        },
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
        builder: (context, state) => const HomeworkAssignmentWidget(),
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
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TeacherProfileWidget(initialUserData: extra?['userData'] as Teacher?);
        },
      ),
      GoRoute(
        name: EditProfileWidget.routeName,
        path: EditProfileWidget.routePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EditProfileWidget(userToEdit: extra?['userToEdit'] as Teacher?);
        },
      ),
      GoRoute(
        name: FacultyListWidget.routeName,
        path: FacultyListWidget.routePath,
        builder: (context, state) => const FacultyListWidget(),
      ),
      GoRoute(
        name: AddUserWidget.routeName,
        path: AddUserWidget.routePath,
        builder: (context, state) => const AddUserWidget(),
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
        name: AboutDCIWidget.routeName,
        path: AboutDCIWidget.routePath,
        builder: (context, state) => const AboutDCIWidget(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

/// A simple Listenable that triggers whenever the auth stream emits a value.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Stream<User?> authStream) {
    _subscription = authStream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
