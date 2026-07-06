import '/auth/firebase_auth/auth_util.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'attendance_dashboard_model.dart';
export 'attendance_dashboard_model.dart';

class AttendanceDashboardWidget extends StatefulWidget {
  const AttendanceDashboardWidget({super.key});

  static String routeName = 'AttendanceDashboard';
  static String routePath = '/attendanceDashboard';

  @override
  State<AttendanceDashboardWidget> createState() =>
      _AttendanceDashboardWidgetState();
}

class _AttendanceDashboardWidgetState extends State<AttendanceDashboardWidget> {
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
              subtitle: 'Staff Presence Overview',
              description: 'Track your attendance records and monthly summary.',
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('attendance_records')
                        .where('createdBy', isEqualTo: currentUserUid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final records = snapshot.data!.docs;
                      final now = DateTime.now();
                      final firstDayOfMonth = DateTime(now.year, now.month, 1);
                      final monthlyRecords = records.where((doc) {
                        final date = (doc.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                        return date != null && date.toDate().isAfter(firstDayOfMonth);
                      }).toList();

                      final presentCount = monthlyRecords.where((doc) => 
                        (doc.data() as Map<String, dynamic>)['status'] == 'Present').length;
                      final workingDays = 26; // Assuming 26 working days
                      final progressPercent = (presentCount / workingDays).clamp(0.0, 1.0);

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Monthly Attendance', 
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                  )),
                                Text('$presentCount/$workingDays Days', 
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                    color: FlutterFlowTheme.of(context).primary,
                                  )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearPercentIndicator(
                              percent: progressPercent,
                              lineHeight: 12.0,
                              animation: true,
                              progressColor: FlutterFlowTheme.of(context).primary,
                              backgroundColor: FlutterFlowTheme.of(context).alternate,
                              barRadius: const Radius.circular(6.0),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 8),
                            Text('${(progressPercent * 100).toInt()}% Achievement', 
                              style: FlutterFlowTheme.of(context).labelSmall),
                          ],
                        ),
                      );
                    },
                  ),
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Logs',
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('attendance_records')
                        .where('createdBy', isEqualTo: currentUserUid)
                        .orderBy('createdAt', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final records = snapshot.data!.docs;
                      if (records.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('No logs found.', textAlign: TextAlign.center),
                        );
                      }
                      return Column(
                        children: records.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final date = (data['createdAt'] as Timestamp?)?.toDate();
                          final status = data['status'] ?? 'Present';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: status == 'Present' ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(status),
                              subtitle: Text(dateTimeFormat('yMMMd', date)),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.pushNamed(AttendanceHistoryWidget.routeName),
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
}
