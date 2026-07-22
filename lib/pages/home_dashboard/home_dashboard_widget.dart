import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/auth/firebase_auth/auth_util.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/dashboard_card/dashboard_card_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_icon_button.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/shared/responsive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/pages/home_dashboard/home_dashboard_model.dart';
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/index.dart';

class HomeDashboardWidget extends ConsumerStatefulWidget {
  const HomeDashboardWidget({super.key});

  static String routeName = 'HomeDashboard';
  static String routePath = '/homeDashboard';

  @override
  ConsumerState<HomeDashboardWidget> createState() => _HomeDashboardWidgetState();
}

class _HomeDashboardWidgetState extends ConsumerState<HomeDashboardWidget> {
  late HomeDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentIndex: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > AppSpacing.tabletBreakpoint;

          return Column(
            children: [
              _buildTopHeader(context, isWide),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.pagePadding,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Management Modules',
                            style: AppTypography.section.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildModulesGrid(context, constraints.maxWidth),
                          const SizedBox(height: AppSpacing.xl),
                          _buildAIHelpSection(context),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, bool hideActions) {
    final theme = FlutterFlowTheme.of(context);
    final userAsync = ref.watch(currentUserDataStreamProvider);
    
    return userAsync.when(
      data: (Teacher? userData) {
        final displayName = userData?.displayName ?? 
            (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Deshmukh Faculty');

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primary, theme.primaryDark],
              begin: const AlignmentDirectional(0.0, -1.0),
              end: const AlignmentDirectional(0, 1.0),
            ),
            borderRadius: hideActions ? null : const BorderRadius.only(
              bottomLeft: Radius.circular(32.0),
              bottomRight: Radius.circular(32.0),
            ),
            boxShadow: AppShadows.low,
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 44.0, 24.0, 24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: theme.bodyMedium.override(font: GoogleFonts.inter(), color: theme.onBackground80, fontSize: 13)),
                    Text(displayName, style: theme.titleMedium.override(font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold), color: theme.onBackground, fontSize: 24)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: theme.onBackground, size: 14),
                        const SizedBox(width: 8),
                        Text(dateTimeFormat('MMMMEEEEd', getCurrentTimestamp), style: theme.labelSmall.override(font: GoogleFonts.inter(), color: theme.onBackground, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!hideActions) _buildHeaderActions(context),
            ],
          ),
        );
      },
      loading: () => Container(height: 140, color: theme.primary),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Stack(
          alignment: const AlignmentDirectional(1.0, -1.0),
          children: [
            FlutterFlowIconButton(
              borderRadius: 12.0, buttonSize: 40.0, fillColor: theme.onPrimary15,
              icon: Icon(Icons.notifications_none_rounded, color: theme.onPrimary, size: 24.0),
              onPressed: () => context.pushNamed(NotificationsWidget.routeName),
            ),
            _buildNotificationBadge(context),
          ],
        ),
        const SizedBox(width: 12),
        FlutterFlowIconButton(
          borderRadius: 12.0, buttonSize: 40.0, fillColor: theme.onPrimary15,
          icon: Icon(Icons.logout_rounded, color: theme.onPrimary, size: 24.0),
          onPressed: () async {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) context.goNamed(LoginWidget.routeName);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    final countAsync = ref.watch(unreadNotificationsCountProvider);
    return countAsync.when(
      data: (count) => count == 0 ? const SizedBox.shrink() : Container(
        width: 18, height: 18, decoration: BoxDecoration(color: FlutterFlowTheme.of(context).error, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        alignment: Alignment.center, child: Text(count > 9 ? '9+' : count.toString(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildModulesGrid(BuildContext context, double width) {
    final crossAxisCount = width > 1000 ? 5 : (width > 700 ? 4 : (width > 400 ? 3 : 2));
    final access = ref.watch(accessControlProvider);

    final modules = [
      if (access.canSubmitDailyReport)
        {'target': 'DailyReport', 'title': 'Daily Report', 'icon': Icons.assessment_rounded},
      {'target': 'Attendance', 'title': 'Attendance', 'icon': Icons.fact_check_rounded},
      {'target': 'Homework', 'title': 'Homework', 'icon': Icons.edit_note_rounded},
      {'target': 'Students', 'title': 'Students', 'icon': Icons.people_rounded},
      {'target': 'Exams', 'title': 'Exams', 'icon': Icons.assignment_rounded},
      {'target': 'Results', 'title': 'Results', 'icon': Icons.grade_rounded},
      {'target': 'Announcements', 'title': 'Announcements', 'icon': Icons.campaign_rounded},
      if (access.canViewAdminReports)
        {'target': 'ReportsDashboard', 'title': 'Admin Reports', 'icon': Icons.insights_rounded},
      if (access.canViewFacultyList)
        {'target': 'FacultyList', 'title': 'Faculty', 'icon': Icons.people_outline_rounded},
      {'target': 'TeacherProfile', 'title': 'My Profile', 'icon': Icons.person_rounded},
      {'target': 'AboutDCI', 'title': 'About DCI', 'icon': Icons.info_rounded},
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.2,
      ),
      itemCount: modules.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final module = modules[index];
        return DashboardCardWidget(
          target: module['target'] as String,
          title: module['title'] as String,
          icon: Icon(module['icon'] as IconData),
        );
      },
    );
  }

  Widget _buildAIHelpSection(BuildContext context) {
    final config = ref.watch(instituteInfoStreamProvider).value;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withAlpha(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(config?['ai_title'] ?? 'Deshmukh AI Assistant', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(config?['ai_description'] ?? 'Get instant help with lesson planning, student performance analysis, or any academic queries.', style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          AppPrimaryButton(text: 'Ask AI Assistant', width: double.infinity, onPressed: () {
            context.pushNamed(AIChatWidget.routeName);
          }),
        ],
      ),
    );
  }
}

class ListPadding extends StatelessWidget {
  const ListPadding({super.key, required this.padding, required this.child});
  final EdgeInsets padding;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(padding: padding, child: child);
}
