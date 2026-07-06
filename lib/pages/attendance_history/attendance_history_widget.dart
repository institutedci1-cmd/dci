import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_history_model.dart';
export 'attendance_history_model.dart';

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
            child: StreamBuilder<List<StudentAttendance>>(
              stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final records = snapshot.data!;
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
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
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
                          'Class: ${record.className} • ${dateTimeFormat('yMMMd', record.date)}',
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
                    );
                  },
                );
              },
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
