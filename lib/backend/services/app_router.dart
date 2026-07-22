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
    debugLogDiagnostics: true,
    refreshListenable: _AuthListenable(authRepository.authStateChanges),
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final loggedIn = user != null;
      final isLoggingIn = state.matchedLocation == LoginWidget.routePath;

      if (!loggedIn && !isLoggingIn) return LoginWidget.routePath;
      if (loggedIn && isLoggingIn) return '/';
      if (state.matchedLocation == '/') return '/';

      if (loggedIn) {
        final access = ref.read(accessControlProvider);

        final adminOnlyRoutes = [
          AddUserWidget.routePath,
          FacultyListWidget.routePath,
          InstituteSettingsWidget.routePath,
        ];

        final staffOnlyRoutes = [
          DailyReportFormWidget.routePath,
          ReportsDashboardWidget.routePath,
          AttendanceTrackerWidget.routePath,
          AttendanceDashboardWidget.routePath,
          ExamsDashboardWidget.routePath,
          ResultsDashboardWidget.routePath,
          StudentListWidget.routePath,
        ];

        if (adminOnlyRoutes.contains(state.matchedLocation) && !access.canManageTeachers) {
          return '/';
        }

        if (state.matchedLocation == DailyReportFormWidget.routePath && !access.canSubmitDailyReport) {
          return '/';
        }

        if (staffOnlyRoutes.contains(state.matchedLocation) && access.isStudent) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RootDashboardWidget(),
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
        name: StudentDashboardWidget.routeName,
        path: StudentDashboardWidget.routePath,
        builder: (context, state) => const StudentDashboardWidget(),
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
        name: TodayAttendanceWidget.routeName,
        path: TodayAttendanceWidget.routePath,
        builder: (context, state) => const TodayAttendanceWidget(),
      ),
      GoRoute(
        name: AbsentListWidget.routeName,
        path: AbsentListWidget.routePath,
        builder: (context, state) => const AbsentListWidget(),
      ),
      GoRoute(
        name: MonthlyAttendanceWidget.routeName,
        path: MonthlyAttendanceWidget.routePath,
        builder: (context, state) => const MonthlyAttendanceWidget(),
      ),
      GoRoute(
        name: AttendanceHistoryWidget.routeName,
        path: AttendanceHistoryWidget.routePath,
        builder: (context, state) => const AttendanceHistoryWidget(),
      ),
      GoRoute(
        name: MyAttendanceHistoryWidget.routeName,
        path: MyAttendanceHistoryWidget.routePath,
        builder: (context, state) => const MyAttendanceHistoryWidget(),
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
        name: ResultsDashboardWidget.routeName,
        path: ResultsDashboardWidget.routePath,
        builder: (context, state) => const ResultsDashboardWidget(),
      ),
      GoRoute(
        name: MyResultsWidget.routeName,
        path: MyResultsWidget.routePath,
        builder: (context, state) => const MyResultsWidget(),
      ),
      GoRoute(
        name: MyProfileWidget.routeName,
        path: MyProfileWidget.routePath,
        builder: (context, state) => const MyProfileWidget(),
      ),
      GoRoute(
        name: AIChatWidget.routeName,
        path: AIChatWidget.routePath,
        builder: (context, state) => const AIChatWidget(),
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
        name: HomeworkDashboardWidget.routeName,
        path: HomeworkDashboardWidget.routePath,
        builder: (context, state) => const HomeworkDashboardWidget(),
      ),
      GoRoute(
        name: MyHomeworkWidget.routeName,
        path: MyHomeworkWidget.routePath,
        builder: (context, state) => const MyHomeworkWidget(),
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
      GoRoute(
        name: InstituteSettingsWidget.routeName,
        path: InstituteSettingsWidget.routePath,
        builder: (context, state) => const InstituteSettingsWidget(),
      ),
      GoRoute(
        name: AuditLogsWidget.routeName,
        path: AuditLogsWidget.routePath,
        builder: (context, state) => const AuditLogsWidget(),
      ),
      GoRoute(
        name: StaffAnalyticsWidget.routeName,
        path: StaffAnalyticsWidget.routePath,
        builder: (context, state) => const StaffAnalyticsWidget(),
      ),
      GoRoute(
        name: ComparativeResultsWidget.routeName,
        path: ComparativeResultsWidget.routePath,
        builder: (context, state) => const ComparativeResultsWidget(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

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
