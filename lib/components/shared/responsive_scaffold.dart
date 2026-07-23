import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/core/services/navigation_service.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/index.dart';

class ResponsiveScaffold extends ConsumerWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
    this.showBottomNav = true,
  });

  final Widget body;
  final int currentIndex;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > AppSpacing.tabletBreakpoint;

        return Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Row(
            children: [
              if (isWide) _Sidebar(currentIndex: currentIndex),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                          child: body,
                        ),
                      ),
                    ),
                    if (!isWide && showBottomNav)
                      AppBottomNavBar(
                        currentIndex: currentIndex,
                        onTap: (index) => _onNavTap(context, index, ref),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNavTap(BuildContext context, int index, WidgetRef ref) {
    final access = ref.read(accessControlProvider);
    final routes = [
      access.isStudent ? StudentDashboardWidget.routeName : HomeDashboardWidget.routeName,
      ReportsDashboardWidget.routeName,
      AttendanceDashboardWidget.routeName,
      TeacherProfileWidget.routeName,
    ];
    if (index != currentIndex) {
      context.goNamed(routes[index]);
    }
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final access = ref.watch(accessControlProvider);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(right: BorderSide(color: theme.alternate)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: AppColors.primary, size: 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Deshmukh ERP', style: AppTypography.title.copyWith(fontSize: 20)),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _SidebarItem(
                    title: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    isActive: currentIndex == 0,
                    onTap: () => context.goNamed(access.isStudent ? StudentDashboardWidget.routeName : HomeDashboardWidget.routeName),
                  ),
                  if (!access.isStudent) ...[
                    if (access.canViewDailyReports)
                      _SidebarItem(
                        title: 'Daily Report',
                        icon: Icons.edit_document,
                        isActive: false,
                        onTap: () => NavigationService.navigateToReports(context),
                      ),
                    if (access.canViewAdminReports)
                      _SidebarItem(
                        title: 'Reports',
                        icon: Icons.assessment_rounded,
                        isActive: currentIndex == 1,
                        onTap: () => NavigationService.navigateToReports(context),
                      ),
                    _SidebarItem(
                      title: 'Attendance',
                      icon: Icons.fact_check_rounded,
                      isActive: currentIndex == 2,
                      onTap: () => NavigationService.navigateToAttendanceDashboard(context),
                    ),
                    _SidebarItem(
                      title: 'Homework',
                      icon: Icons.edit_note_rounded,
                      isActive: false,
                      onTap: () => NavigationService.navigateToHomework(context),
                    ),
                    _SidebarItem(
                      title: 'Students',
                      icon: Icons.people_rounded,
                      isActive: false,
                      onTap: () => NavigationService.navigateToStudentList(context),
                    ),
                    _SidebarItem(
                      title: 'Exams',
                      icon: Icons.assignment_rounded,
                      isActive: false,
                      onTap: () => NavigationService.navigateToExamsDashboard(context),
                    ),
                    _SidebarItem(
                      title: 'Results',
                      icon: Icons.grade_rounded,
                      isActive: false,
                      onTap: () => NavigationService.navigateToResults(context),
                    ),
                    _SidebarItem(
                      title: 'Announcements',
                      icon: Icons.campaign_rounded,
                      isActive: false,
                      onTap: () => NavigationService.navigateToAnnouncements(context),
                    ),
                    if (access.canViewFacultyList)
                      _SidebarItem(
                        title: 'Manage Faculty',
                        icon: Icons.people_outline_rounded,
                        isActive: false,
                        onTap: () => context.pushNamed(FacultyListWidget.routeName),
                      ),
                  ],
                  if (access.isStudent) ...[
                     _SidebarItem(
                      title: 'Homework',
                      icon: Icons.book_rounded,
                      isActive: false,
                      onTap: () => context.pushNamed(MyHomeworkWidget.routeName),
                    ),
                    _SidebarItem(
                      title: 'Results',
                      icon: Icons.assessment_rounded,
                      isActive: false,
                      onTap: () => context.pushNamed(MyResultsWidget.routeName),
                    ),
                    _SidebarItem(
                      title: 'Attendance',
                      icon: Icons.fact_check_rounded,
                      isActive: false,
                      onTap: () => context.pushNamed(MyAttendanceHistoryWidget.routeName),
                    ),
                  ],
                  _SidebarItem(
                    title: 'About DCI',
                    icon: Icons.info_rounded,
                    isActive: false,
                    onTap: () => NavigationService.navigateToAbout(context),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          _SidebarItem(
            title: 'My Profile',
            icon: Icons.person_rounded,
            isActive: currentIndex == 3,
            onTap: () => context.goNamed(TeacherProfileWidget.routeName),
          ),
          _SidebarItem(
            title: 'Logout',
            icon: Icons.logout_rounded,
            isActive: false,
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.goNamed(LoginWidget.routeName);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isActive ? theme.primary.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: isActive ? theme.primary : theme.secondaryText, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: AppTypography.body.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? theme.primary : theme.primaryText,
                    fontSize: 14,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
