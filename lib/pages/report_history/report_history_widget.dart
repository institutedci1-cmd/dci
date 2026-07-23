import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/pdf_service.dart';
import 'package:d_c_i_teacher_app/backend/services/excel_service/excel_service.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:d_c_i_teacher_app/pages/report_history/report_history_model.dart';

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
                final access = ref.read(accessControlProvider);
                final creatorId = (access.role == UserRole.teacher) ? access.user?.uid : null;
                final reports = await ref.read(dailyReportRepositoryProvider).getReports(limit: 100, creatorId: creatorId);
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
                  return AppEmptyState(
                    icon: Icons.history_rounded,
                    title: 'No reports yet',
                    description: 'Your submitted daily reports will appear here.',
                    actionLabel: 'Submit Report',
                    onActionPressed: () => context.pushNamed(DailyReportFormWidget.routeName),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppShadows.low,
                      ),
                      child: Material(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            // Detail view
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              title: Text(
                                '${report.className} - ${report.subject}',
                                style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: FlutterFlowTheme.of(context).primaryText),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text('Topic: ${report.chapter}', style: AppTypography.caption.copyWith(fontSize: 11)),
                                  if (report.teacher.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('By: ${report.teacher}', style: AppTypography.caption.copyWith(fontSize: 10)),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dateTimeFormat('yMMMd', report.createdAt),
                                    style: AppTypography.caption.copyWith(color: FlutterFlowTheme.of(context).primary, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.share_rounded, color: FlutterFlowTheme.of(context).success, size: 18),
                                    onPressed: () async {
                                      final whatsappService = ref.read(whatsappServiceProvider);
                                      final message = 'Daily Report Summary: ${report.className} - ${report.subject}. Chapter: ${report.chapter}. Present: ${report.presentCount}, Absent: ${report.absentCount}.';
                                      await whatsappService.launchWhatsapp(message: message);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf_rounded, color: FlutterFlowTheme.of(context).info, size: 18),
                                    onPressed: () => PdfService.exportDailyReport(report),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 18),
                                ],
                              ),
                            ),
                          ),
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
