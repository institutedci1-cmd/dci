import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:d_c_i_teacher_app/components/shared/responsive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Direct imports for the page and its model
import 'package:d_c_i_teacher_app/pages/attendance_dashboard/attendance_dashboard_model.dart';


class AttendanceDashboardWidget extends ConsumerStatefulWidget {
  const AttendanceDashboardWidget({super.key});

  static String routeName = 'AttendanceDashboard';
  static String routePath = '/attendanceDashboard';

  @override
  ConsumerState<AttendanceDashboardWidget> createState() =>
      _AttendanceDashboardWidgetState();
}

class _AttendanceDashboardWidgetState extends ConsumerState<AttendanceDashboardWidget> {
  late AttendanceDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttendanceDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final attendanceLogsAsync = ref.watch(studentAttendanceLogsProvider);

    return ResponsiveScaffold(
      currentIndex: 2,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Attendance Dashboard',
            subtitle: 'Student Presence Tracking',
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
                  attendanceLogsAsync.when(
                    data: (records) {
                      final totalMarked = records.length;
                      final presentCount = records.where((doc) => doc.status == 'Present').length;
                      final attendanceRate = totalMarked == 0 ? 0 : ((presentCount / totalMarked) * 100).toInt();

                      return Row(
                        children: [
                          _buildMicroStat(context, 'Marked', totalMarked.toString(), Icons.people_rounded, theme.primary),
                          const SizedBox(width: 8),
                          _buildMicroStat(context, 'Rate', '$attendanceRate%', Icons.trending_up_rounded, theme.success),
                          const SizedBox(width: 8),
                          _buildMicroStat(context, 'Absent', (totalMarked - presentCount).toString(), Icons.person_off_rounded, theme.error),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Error: $err', style: const TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(height: 12),

                  // Quick Actions Grid
                  Text('QUICK ACTIONS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildActionBtn(context, 'Mark Now', Icons.check_box_rounded, theme.primary, () => context.pushNamed(AttendanceTrackerWidget.routeName)),
                      const SizedBox(width: 8),
                      _buildActionBtn(context, 'Today', Icons.today_rounded, AppColors.secondary, () => context.pushNamed(TodayAttendanceWidget.routeName)),
                      const SizedBox(width: 8),
                      _buildActionBtn(context, 'Absents', Icons.person_off_rounded, AppColors.error, () => context.pushNamed(AbsentListWidget.routeName)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionBtn(context, 'Monthly', Icons.calendar_month_rounded, AppColors.info, () => context.pushNamed(MonthlyAttendanceWidget.routeName)),
                      const SizedBox(width: 8),
                      _buildActionBtn(context, 'History', Icons.history_toggle_off_rounded, AppColors.primary, () => context.pushNamed(AttendanceHistoryWidget.routeName)),
                      const SizedBox(width: 8),
                      _buildActionBtn(context, 'Reports', Icons.assessment_outlined, theme.success, () => context.pushNamed(AttendanceReportWidget.routeName)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recent Logs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RECENT LOGS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
                      TextButton(
                        onPressed: () => context.pushNamed(AttendanceHistoryWidget.routeName),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 20), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: const Text('View All', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  attendanceLogsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No student logs found.', style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                        );
                      }
                      final recentRecords = records.take(2).toList();
                      return Column(
                        children: recentRecords.map((record) => _buildMiniLogCard(context, record, theme)).toList(),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (err, stack) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroStat(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(height: 4),
              Text(value, style: AppTypography.label.copyWith(fontSize: 14, color: theme.primaryText, fontWeight: FontWeight.bold)),
              Text(label, style: AppTypography.caption.copyWith(fontSize: 9, color: theme.secondaryText), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 6),
                Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11, color: theme.primaryText)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniLogCard(BuildContext context, StudentAttendance record, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.alternate),
      ),
      child: Material(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getStatusColor(record.status, theme).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(record.status), color: _getStatusColor(record.status, theme), size: 14),
          ),
          title: Text(record.studentName, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: theme.primaryText)),
          subtitle: Text('${record.className} • ${dateTimeFormat('yMMMd', record.date)}', style: AppTypography.caption.copyWith(fontSize: 11)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(record.status, theme).withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(record.status, theme).withAlpha(40)),
            ),
            child: Text(
              record.status.toUpperCase(), 
              style: TextStyle(color: _getStatusColor(record.status, theme), fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          onTap: () {
            // Log detail
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status, FlutterFlowTheme theme) {
    switch (status) {
      case 'Present': return theme.success;
      case 'Absent': return theme.error;
      case 'Leave': return theme.warning;
      default: return theme.secondaryText;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present': return Icons.check_circle_rounded;
      case 'Absent': return Icons.cancel_rounded;
      case 'Leave': return Icons.pause_circle_rounded;
      default: return Icons.help_rounded;
    }
  }
}
