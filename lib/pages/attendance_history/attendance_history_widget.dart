
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/shared/app_primary_button.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Direct imports for the page and its model
import 'attendance_history_model.dart';
import '/pages/attendance_dashboard/attendance_dashboard_widget.dart';

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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
                  return Center(
                    child: Text(
                      'No student attendance records found.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Container(
                      decoration: const BoxDecoration(),
                      child: Material(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: _getStatusColor(record.status).withAlpha((0.1 * 255).toInt()),
                            child: Icon(
                              _getStatusIcon(record.status),
                              color: _getStatusColor(record.status),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            record.studentName,
                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            'Class: ${record.className} • Subject: ${record.subject}\n${dateTimeFormat('yMMMd', record.date)}',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(record.status).withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getStatusColor(record.status)),
                            ),
                            child: Text(
                              record.status,
                              style: TextStyle(
                                color: _getStatusColor(record.status),
                                fontSize: 12,
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
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present': return Colors.green;
      case 'Absent': return Colors.red;
      case 'Leave': return Colors.orange;
      default: return Colors.grey;
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
