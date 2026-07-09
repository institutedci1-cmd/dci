import '/backend/models/daily_report.dart';
import '/backend/providers/repository_providers.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_card.dart';
import '../../components/shared/app_button.dart';
import '../../components/shared/app_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

export 'reports_dashboard_model.dart';

class ReportsDashboardWidget extends ConsumerStatefulWidget {
  const ReportsDashboardWidget({super.key});

  static String routeName = 'ReportsDashboard';
  static String routePath = '/reportsDashboard';

  @override
  ConsumerState<ReportsDashboardWidget> createState() => _ReportsDashboardWidgetState();
}

class _ReportsDashboardWidgetState extends ConsumerState<ReportsDashboardWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: AppColors.accent),
            onPressed: () => context.pushNamed(DailyReportFormWidget.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatsSection(),
            const SizedBox(height: AppSpacing.xl),
            const AppSectionHeader(title: 'Quick Actions'),
            const SizedBox(height: AppSpacing.md),
            _buildActionsRow(),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: 'Recent Reports',
              action: TextButton(
                onPressed: () => context.pushNamed(ReportHistoryWidget.routeName),
                child: const Text('View All'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRecentReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<List<DailyReport>>(
      stream: ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: 100),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final totalReports = reports.length;
        
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final reportsThisWeek = reports.where((r) => r.createdAt != null && r.createdAt!.isAfter(startOfWeek)).length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard('Total Reports', totalReports.toString(), Icons.description_rounded, AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard('This Week', reportsThisWeek.toString(), Icons.calendar_today_rounded, AppColors.secondary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'New Report',
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => context.pushNamed(DailyReportFormWidget.routeName),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            text: 'History',
            variant: AppButtonVariant.secondary,
            icon: Icons.history_rounded,
            onPressed: () => context.pushNamed(ReportHistoryWidget.routeName),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReports() {
    return StreamBuilder<List<DailyReport>>(
      stream: ref.watch(dailyReportRepositoryProvider).getRecentReports(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(
            child: Text('No reports found.', style: Theme.of(context).textTheme.bodySmall),
          );
        }
        return Column(
          children: reports.map((report) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => context.pushNamed(ReportHistoryWidget.routeName),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${report.className} • ${report.subject}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text(dateTimeFormat('yMMMd', report.createdAt), style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
