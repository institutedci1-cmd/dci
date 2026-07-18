import '/auth/firebase_auth/auth_util.dart';
import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/components/dashboard_card/dashboard_card_widget.dart';
import '/components/recent_activity_item/recent_activity_item_widget.dart';
import '/components/shared/app_bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_dashboard_model.dart';
import '../../index.dart';

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Management Modules',
                      style: AppTypography.section.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildModulesGrid(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildRecentActivitySection(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildAIHelpSection(context),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            AppBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                final routes = [
                  HomeDashboardWidget.routeName,
                  ReportsDashboardWidget.routeName,
                  AttendanceDashboardWidget.routeName,
                  TeacherProfileWidget.routeName,
                ];
                if (index != 0) {
                  context.goNamed(routes[index]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final userAsync = ref.watch(userStreamProvider);
    
    return userAsync.when(
      data: (userData) {
        final displayName = userData?['display_name'] ?? 
            (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'DCI Faculty');

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primary, theme.tertiary],
              begin: const AlignmentDirectional(0.0, -1.0),
              end: const AlignmentDirectional(0, 1.0),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32.0),
              bottomRight: Radius.circular(32.0),
            ),
            boxShadow: AppShadows.low,
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 44.0, 16.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: theme.onBackground80,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleMedium.override(
                            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            color: theme.onBackground,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderActions(context),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: theme.onBackground, size: AppSize.iconSm),
                  const SizedBox(width: 8),
                  Text(
                    dateTimeFormat('MMMMEEEEd', getCurrentTimestamp),
                    style: theme.labelSmall.override(
                      font: GoogleFonts.inter(),
                      color: theme.onBackground,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.primary, theme.tertiary]),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32.0), bottomRight: Radius.circular(32.0)),
        ),
      ),
      error: (err, stack) => Text('Error: $err'),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: const AlignmentDirectional(1.0, -1.0),
          children: [
            FlutterFlowIconButton(
              borderRadius: 12.0,
              buttonSize: 36.0,
              fillColor: theme.onPrimary15,
              icon: Icon(Icons.notifications_none_rounded, color: theme.onPrimary, size: 20.0),
              onPressed: () => context.pushNamed(NotificationsWidget.routeName),
            ),
            _buildNotificationBadge(context),
          ],
        ),
        const SizedBox(width: 8),
        FlutterFlowIconButton(
          borderRadius: 12.0,
          buttonSize: 36.0,
          fillColor: theme.onPrimary15,
          icon: Icon(Icons.logout_rounded, color: theme.onPrimary, size: 20.0),
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (!context.mounted) return;
            context.goNamed(LoginWidget.routeName);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    final countAsync = ref.watch(unreadNotificationsCountProvider);
    return countAsync.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).error,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            count > 9 ? '9+' : count.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildModulesGrid(BuildContext context) {
    final modules = [
      {'target': 'DailyReport', 'title': 'Daily Report', 'icon': Icons.assessment_rounded},
      {'target': 'Attendance', 'title': 'Attendance', 'icon': Icons.fact_check_rounded},
      {'target': 'Homework', 'title': 'Homework', 'icon': Icons.edit_note_rounded},
      {'target': 'TeacherProfile', 'title': 'Profile', 'icon': Icons.person_rounded},
      {'target': 'Announcements', 'title': 'Announcements', 'icon': Icons.campaign_rounded},
      {'target': 'Students', 'title': 'Students', 'icon': Icons.people_rounded},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: modules.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final module = modules[index];
            return DashboardCardWidget(
              target: module['target'] as String,
              title: module['title'] as String,
              icon: Icon(module['icon'] as IconData),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTypography.section.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        ref.watch(recentReportsProvider(3)).when(
          data: (reportsData) {
            final reports = (reportsData as List).cast<DailyReport>();
            if (reports.isEmpty) {
              return Text('No recent activity found.', style: AppTypography.caption);
            }
            return Column(
              children: reports.map((report) => RecentActivityItemWidget(
                title: '${report.className} - ${report.subject}',
                subtitle: 'Topic: ${report.chapter}\n${dateTimeFormat('yMMMd', report.createdAt)}',
                onTap: () => context.pushNamed(ReportHistoryWidget.routeName),
              )).toList(),
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: CircularProgressIndicator(),
          )),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildAIHelpSection(BuildContext context) {
    final instituteAsync = ref.watch(instituteInfoStreamProvider);
    return instituteAsync.when(
      data: (config) {
        return InkWell(
          onTap: () async {
            if (config?['ai_help_url'] != null) {
              await launchURL(config!['ai_help_url']);
            }
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
              boxShadow: AppShadows.low,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: AppSize.avatarMd,
                  height: AppSize.avatarMd,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20.0),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config?['ai_title'] ?? 'DCI AI Assistant',
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Text(
                        config?['ai_description'] ?? 'Help with lesson planning or data.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 20.0),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
