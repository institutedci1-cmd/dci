import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/pdf_service.dart';
import '/backend/services/excel_service/excel_service.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_card.dart';
import '../../components/shared/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

export 'report_history_model.dart';

class ReportHistoryWidget extends ConsumerStatefulWidget {
  const ReportHistoryWidget({super.key});

  static String routeName = 'ReportHistory';
  static String routePath = '/reportHistory';

  @override
  ConsumerState<ReportHistoryWidget> createState() => _ReportHistoryWidgetState();
}

class _ReportHistoryWidgetState extends ConsumerState<ReportHistoryWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportReports,
          ),
        ],
      ),
      body: _buildReportsList(),
    );
  }

  Widget _buildReportsList() {
    return StreamBuilder<List<DailyReport>>(
      stream: ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Text('No reports found.', style: Theme.of(context).textTheme.bodyMedium),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(DailyReport report) {
    final theme = Theme.of(context);
    
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${report.className} • ${report.subject}',
                style: theme.textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              Text(
                dateTimeFormat('yMMMd', report.createdAt),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            report.chapter,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (report.teacher.isNotEmpty)
            Text(
              'Teacher: ${report.teacher}',
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildMiniStat('Present', report.presentCount.toString(), AppColors.success),
              const SizedBox(width: AppSpacing.md),
              _buildMiniStat('Absent', report.absentCount.toString(), AppColors.error),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.success),
                onPressed: () => _shareReport(report),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20, color: AppColors.accent),
                onPressed: () => PdfService.exportDailyReport(report),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: ', style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Future<void> _exportReports() async {
    final reports = await ref.read(dailyReportRepositoryProvider).getReports(limit: 100);
    if (reports.isEmpty) return;
    await ExcelService.exportDailyReports(reports);
  }

  void _shareReport(DailyReport report) {
    ref.read(whatsappServiceProvider).sendTextMessage(
      to: 'YOUR_ADMIN_PHONE_NUMBER',
      message: 'Daily Report: ${report.className} - ${report.subject}. Chapter: ${report.chapter}. Present: ${report.presentCount}, Absent: ${report.absentCount}.',
    );
  }
}
