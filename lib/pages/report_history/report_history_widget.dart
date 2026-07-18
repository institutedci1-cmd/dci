import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/pdf_service/pdf_service.dart';
import '/backend/services/excel_service/excel_service.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
              actionIcon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 24),
              onActionPressed: () async {
                final reports = await ref.read(dailyReportRepositoryProvider).getReports(limit: 100);
                if (reports.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No reports found to export.')),
                    );
                  }
                  return;
                }
                final success = await ExcelService.exportDailyReports(reports);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Reports exported successfully!' 
                        : 'Failed to export reports.'),
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: ref.watch(recentReportsProvider(50)).when(
              data: (reportsData) {
                final reports = (reportsData as List).cast<DailyReport>();
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
                      decoration: const BoxDecoration(),
                      child: Material(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_rounded, color: Colors.green),
                                onPressed: () async {
                                  final whatsappService = ref.read(whatsappServiceProvider);
                                  final message = 'Daily Report Summary: ${report.className} - ${report.subject}. Chapter: ${report.chapter}. Present: ${report.presentCount}, Absent: ${report.absentCount}.';
                                  await whatsappService.launchWhatsapp(message: message);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf_rounded, color: FlutterFlowTheme.of(context).primary),
                                onPressed: () => PdfService.exportDailyReport(report),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                          onTap: () {
                            // Could add detailed view here if needed
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
