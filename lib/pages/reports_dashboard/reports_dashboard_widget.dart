import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
export 'reports_dashboard_model.dart';

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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          wrapWithModel(
            model: createModel(context, () => HeaderSectionModel()),
            updateCallback: () => safeSetState(() {}),
            child: HeaderSectionWidget(
              title: 'Reports Dashboard',
              subtitle: 'Class Activity Summary',
              description: 'View and manage all your teaching reports.',
              onBackPressed: () async => context.safePop(),
              actionIcon: Icon(
                Icons.add_chart_rounded,
                color: FlutterFlowTheme.of(context).onPrimary,
                size: 24.0,
              ),
              onActionPressed: () async {
                context.pushNamed(DailyReportFormWidget.routeName);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<List<DailyReport>>(
                    stream: ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: 100),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final reports = snapshot.data!;
                      final totalReports = reports.length;
                      
                      final now = DateTime.now();
                      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                      final reportsThisWeek = reports.where((report) {
                        return report.createdAt != null && report.createdAt!.isAfter(startOfWeek);
                      }).length;

                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Total Reports',
                              totalReports.toString(),
                              Icons.description_rounded,
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'This Week',
                              reportsThisWeek.toString(),
                              Icons.calendar_view_week_rounded,
                              FlutterFlowTheme.of(context).secondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'New Report',
                          Icons.add_circle_outline_rounded,
                          () => context.pushNamed(DailyReportFormWidget.routeName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'History',
                          Icons.history_rounded,
                          () => context.pushNamed(ReportHistoryWidget.routeName),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(context, 'Recent Reports'),
                      TextButton(
                        onPressed: () => context.pushNamed(ReportHistoryWidget.routeName),
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
                  StreamBuilder<List<DailyReport>>(
                    stream: ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: 5),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final reports = snapshot.data!;
                      if (reports.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No reports yet.', textAlign: TextAlign.center),
                        );
                      }
                      return Column(
                        children: reports.map((report) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                              ),
                              child: ListTile(
                                title: Text('${report.className} - ${report.subject}'),
                                subtitle: Text(dateTimeFormat('yMMMd', report.createdAt)),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  // Detail view?
                                },
                              ),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: FlutterFlowTheme.of(context).titleMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
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
            Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 28),
            const SizedBox(height: 8),
            Text(title, style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: FlutterFlowTheme.of(context).primary,
            )),
          ],
        ),
      ),
    );
  }
}
