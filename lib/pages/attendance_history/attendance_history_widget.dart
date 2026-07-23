
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Direct imports for the page and its model
import 'package:d_c_i_teacher_app/pages/attendance_history/attendance_history_model.dart';
import 'package:d_c_i_teacher_app/pages/attendance_dashboard/attendance_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/pages/attendance_tracker/attendance_tracker_widget.dart';

class AttendanceHistoryWidget extends ConsumerStatefulWidget {
  const AttendanceHistoryWidget({super.key});

  static String routeName = 'AttendanceHistory';
  static String routePath = '/attendanceHistory';

  @override
  ConsumerState<AttendanceHistoryWidget> createState() =>
      _AttendanceHistoryWidgetState();
}

class _AttendanceHistoryWidgetState extends ConsumerState<AttendanceHistoryWidget> {
  late AttendanceHistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttendanceHistoryModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          wrapWithModel(
            model: _model.headerSectionModel,
            updateCallback: () => safeSetState(() {}),
            child: HeaderSectionWidget(
              title: 'Student Attendance Logs',
              subtitle: 'Track record of classes',
              description: 'View individual student attendance records marked by you.',
              onBackPressed: () async => context.goNamed(AttendanceDashboardWidget.routeName),
              showActionIcon: false,
            ),
          ),
          Expanded(
            child: ref.watch(studentAttendanceLogsProvider).when(
              data: (records) {
                if (records.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.fact_check_rounded,
                    title: 'No records found',
                    description: 'Your marked attendance logs will appear here.',
                    actionLabel: 'Mark Attendance',
                    onActionPressed: () => context.pushNamed(AttendanceTrackerWidget.routeName),
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.pagePadding,
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final color = _getStatusColor(record.status, theme);
                    
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        boxShadow: AppShadows.low,
                      ),
                      child: Material(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(record.status),
                              color: color,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            record.studentName,
                            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Class: ${record.className} • Subject: ${record.subject}',
                                  style: AppTypography.caption.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dateTimeFormat('yMMMd', record.date),
                                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color.withAlpha(50)),
                            ),
                            child: Text(
                              record.status.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, color: theme.error, size: 48),
                      const SizedBox(height: 16),
                      Text('Error Loading Data', style: AppTypography.section),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: 24),
                      AppPrimaryButton(
                        text: 'Try Again',
                        width: 150,
                        onPressed: () => ref.invalidate(studentAttendanceLogsProvider),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
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
