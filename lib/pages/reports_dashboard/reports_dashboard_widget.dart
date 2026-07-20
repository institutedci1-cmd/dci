import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
export 'package:d_c_i_teacher_app/pages/reports_dashboard/reports_dashboard_model.dart';

class ReportsDashboardWidget extends ConsumerStatefulWidget {
  const ReportsDashboardWidget({super.key});

  static String routeName = 'ReportsDashboard';
  static String routePath = '/reportsDashboard';

  @override
  ConsumerState<ReportsDashboardWidget> createState() => _ReportsDashboardWidgetState();
}

class _ReportsDashboardWidgetState extends ConsumerState<ReportsDashboardWidget> {
  late ReportsDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportsDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final reportsStream = ref.read(dailyReportRepositoryProvider).getRecentReports(limit: 100);
    final recentReportsStream = ref.read(dailyReportRepositoryProvider).getRecentReports(limit: 2);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Reports Dashboard',
            subtitle: 'Class Activity Summary',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Statistics Section
                  Text('STATISTICS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                  const SizedBox(height: 4),
                  StreamBuilder<List<DailyReport>>(
                    stream: reportsStream,
                    builder: (context, snapshot) {
                      final reports = snapshot.data ?? [];
                      final totalReports = reports.length;
                      final now = DateTime.now();
                      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                      final reportsThisWeek = reports.where((report) => report.createdAt != null && report.createdAt!.isAfter(startOfWeek)).length;

                      return Row(
                        children: [
                          _buildMicroStat(context, 'Total', totalReports.toString(), Icons.description_rounded, theme.primary),
                          const SizedBox(width: 8),
                          _buildMicroStat(context, 'This Week', reportsThisWeek.toString(), Icons.calendar_view_week_rounded, AppColors.success),
                          const SizedBox(width: 8),
                          _buildMicroStat(context, 'Pending', '0', Icons.pending_actions_rounded, AppColors.warning),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Quick Actions Grid
                  Text('QUICK ACTIONS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildActionBtn(context, 'New Report', Icons.add_circle_outline_rounded, theme.primary, () => context.pushNamed(DailyReportFormWidget.routeName)),
                      const SizedBox(width: 8),
                      _buildActionBtn(context, 'History', Icons.history_rounded, AppColors.info, () => context.pushNamed(ReportHistoryWidget.routeName)),
                      const SizedBox(width: 8),
                      _buildActionBtn(context, 'Analytics', Icons.bar_chart_rounded, AppColors.success, () {}),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Recent Reports
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RECENT REPORTS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                      TextButton(
                        onPressed: () => context.pushNamed(ReportHistoryWidget.routeName),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 20), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text('View All', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  StreamBuilder<List<DailyReport>>(
                    stream: recentReportsStream,
                    builder: (context, snapshot) {
                      final reports = snapshot.data ?? [];
                      if (reports.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No reports yet.', style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                        );
                      }
                      return Column(
                        children: reports.map((report) => _buildMiniReportCard(context, report, theme)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          final routes = [
            HomeDashboardWidget.routeName,
            ReportsDashboardWidget.routeName,
            AttendanceDashboardWidget.routeName,
            TeacherProfileWidget.routeName,
          ];
          if (index != 1) {
            context.goNamed(routes[index]);
          }
        },
      ),
    );
  }

  Widget _buildMicroStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.alternate),
          boxShadow: AppShadows.low,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(height: 6),
            Text(value, style: AppTypography.title.copyWith(fontSize: 18, height: 1.1)),
            Text(label, style: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withAlpha(40)),
            boxShadow: AppShadows.low,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 6),
              Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniReportCard(BuildContext context, DailyReport report, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.description_rounded, color: theme.primary, size: 16),
          ),
          title: Text('${report.className} - ${report.subject}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          subtitle: Text(dateTimeFormat('yMMMd', report.createdAt), style: AppTypography.caption.copyWith(fontSize: 11)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
          onTap: () {
            // Detail view
          },
        ),
      ),
    );
  }
}
