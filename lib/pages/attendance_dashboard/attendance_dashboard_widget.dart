import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
export 'attendance_dashboard_model.dart';

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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          wrapWithModel(
            model: createModel(context, () => HeaderSectionModel()),
            updateCallback: () => safeSetState(() {}),
            child: HeaderSectionWidget(
              title: 'Attendance Dashboard',
              subtitle: 'Student Presence Tracking',
              description: 'Manage and review student attendance across your classes.',
              onBackPressed: () async => context.safePop(),
              actionIcon: Icon(
                Icons.how_to_reg_rounded,
                color: FlutterFlowTheme.of(context).onPrimary,
                size: 24.0,
              ),
              onActionPressed: () async {
                context.pushNamed(AttendanceTrackerWidget.routeName);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatsRow(context),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Mark Attendance',
                          Icons.check_box_rounded,
                          () => context.pushNamed(AttendanceTrackerWidget.routeName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'History',
                          Icons.history_toggle_off_rounded,
                          () => context.pushNamed(AttendanceHistoryWidget.routeName),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    'Monthly Reports',
                    Icons.assessment_outlined,
                    () => context.pushNamed('MonthlyReport'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Student Logs',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.pushNamed(AttendanceHistoryWidget.routeName),
                        child: Text(
                          'View All',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<List<StudentAttendance>>(
                    stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final records = snapshot.data!;
                      if (records.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No student logs found.', textAlign: TextAlign.center),
                        );
                      }
                      return Column(
                        children: records.take(10).map((record) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: _getStatusColor(record.status).withAlpha((0.1 * 255).toInt()),
                                child: Icon(_getStatusIcon(record.status), color: _getStatusColor(record.status), size: 16),
                              ),
                              title: Text(record.studentName),
                              subtitle: Text('${record.className} • ${dateTimeFormat('yMMMd', record.date)}'),
                              trailing: Text(record.status, style: TextStyle(color: _getStatusColor(record.status), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return StreamBuilder<List<StudentAttendance>>(
      stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final records = snapshot.data!;
        final totalMarked = records.length;
        final presentCount = records.where((doc) => doc.status == 'Present').length;
        final attendanceRate = totalMarked == 0 ? 0 : ((presentCount / totalMarked) * 100).toInt();

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Marks',
                totalMarked.toString(),
                Icons.people_rounded,
                FlutterFlowTheme.of(context).primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg. Present',
                '$attendanceRate%',
                Icons.trending_up_rounded,
                FlutterFlowTheme.of(context).success,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          )),
          Text(title, style: FlutterFlowTheme.of(context).labelSmall),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: FlutterFlowTheme.of(context).secondary, size: 28),
            const SizedBox(height: 8),
            Text(title, style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).secondary,
            )),
          ],
        ),
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
