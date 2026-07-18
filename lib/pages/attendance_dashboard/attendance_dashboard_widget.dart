import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/shared/app_stat_card.dart';
import '/components/shared/app_quick_action_button.dart';
import '/components/shared/app_bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Direct imports for the page and its model
import 'attendance_dashboard_model.dart';


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
    final attendanceLogsAsync = ref.watch(studentAttendanceLogsProvider);

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
                  _buildStatsRow(context, attendanceLogsAsync),
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
                        child: AppQuickActionButton(
                          title: 'Mark Attendance',
                          icon: Icons.check_box_rounded,
                          color: FlutterFlowTheme.of(context).secondary,
                          onTap: () => context.pushNamed(AttendanceTrackerWidget.routeName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppQuickActionButton(
                          title: 'History',
                          icon: Icons.history_toggle_off_rounded,
                          color: FlutterFlowTheme.of(context).secondary,
                          onTap: () => context.pushNamed(AttendanceHistoryWidget.routeName),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppQuickActionButton(
                    title: 'Attendance Reports',
                    icon: Icons.assessment_outlined,
                    color: FlutterFlowTheme.of(context).secondary,
                    onTap: () => context.pushNamed(AttendanceReportWidget.routeName),
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
                  attendanceLogsAsync.when(
                    data: (records) {
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
                            child: Material(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
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
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          final routes = [
            HomeDashboardWidget.routeName,
            ReportsDashboardWidget.routeName,
            AttendanceDashboardWidget.routeName,
            TeacherProfileWidget.routeName,
          ];
          if (index != 2) {
            context.goNamed(routes[index]);
          }
        },
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AsyncValue<List<StudentAttendance>> logsAsync) {
    return logsAsync.when(
      data: (records) {
        final totalMarked = records.length;
        final presentCount = records.where((doc) => doc.status == 'Present').length;
        final attendanceRate = totalMarked == 0 ? 0 : ((presentCount / totalMarked) * 100).toInt();

        return Row(
          children: [
            Expanded(
              child: AppStatCard(
                title: 'Total Marks',
                value: totalMarked.toString(),
                icon: Icons.people_rounded,
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppStatCard(
                title: 'Avg. Present',
                value: '$attendanceRate%',
                icon: Icons.trending_up_rounded,
                color: FlutterFlowTheme.of(context).success,
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Expanded(child: Container(height: 100, decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(12)))),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 100, decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(12)))),
        ],
      ),
      error: (err, stack) => const SizedBox(),
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
