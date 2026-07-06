import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'report_history_model.dart';
export 'report_history_model.dart';

class ReportHistoryWidget extends ConsumerStatefulWidget {
  const ReportHistoryWidget({super.key});

  static String routeName = 'ReportHistory';
  static String routePath = '/reportHistory';

  @override
  ConsumerState<ReportHistoryWidget> createState() => _ReportHistoryWidgetState();
}

class _ReportHistoryWidgetState extends ConsumerState<ReportHistoryWidget> {
  late ReportHistoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportHistoryModel());
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
              title: 'Report History',
              subtitle: 'Your submitted daily reports',
              description: 'Review and track your previous class activity.',
              onBackPressed: () async => context.goNamed(ReportsDashboardWidget.routeName),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DailyReport>>(
              stream: ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: 50),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snapshot.data!;
                if (reports.isEmpty) {
                  return Center(
                    child: Text(
                      'No reports found.',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          '${report.className} - ${report.subject}',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Topic: ${report.chapter}'),
                            if (report.teacher.isNotEmpty)
                              Text('Teacher: ${report.teacher}',
                                  style: FlutterFlowTheme.of(context).bodySmall),
                            Text(
                              dateTimeFormat('yMMMd', report.createdAt),
                              style: FlutterFlowTheme.of(context).labelSmall,
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          // Could add detailed view here if needed
                        },
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
}
