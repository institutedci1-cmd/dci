import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffAnalyticsWidget extends ConsumerStatefulWidget {
  const StaffAnalyticsWidget({super.key});

  static String routeName = 'StaffAnalytics';
  static String routePath = '/staffAnalytics';

  @override
  ConsumerState<StaffAnalyticsWidget> createState() => _StaffAnalyticsWidgetState();
}

class _StaffAnalyticsWidgetState extends ConsumerState<StaffAnalyticsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final reportsAsync = ref.watch(recentReportsProvider(200)); // Larger limit for analytics
    final attendanceLogsAsync = ref.watch(studentAttendanceLogsProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Staff Analytics',
            subtitle: 'Institutional Performance',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Activity Heatmap'),
                  const SizedBox(height: 12),
                  reportsAsync.when(
                    data: (reports) => _buildActivityHeatmap(context, reports),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error loading reports: $err'),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Attendance Consistency'),
                  const SizedBox(height: 12),
                  attendanceLogsAsync.when(
                    data: (logs) => _buildAttendanceConsistency(context, logs),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error loading logs: $err'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.section.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildActivityHeatmap(BuildContext context, List<dynamic> reports) {
    final theme = FlutterFlowTheme.of(context);
    // Group reports by day of week
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var r in reports) {
      if (r.createdAt != null) {
        weekdayCounts[r.createdAt!.weekday] = (weekdayCounts[r.createdAt!.weekday] ?? 0) + 1;
      }
    }

    final maxCount = weekdayCounts.values.fold(0, (max, val) => val > max ? val : max);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final count = weekdayCounts[i + 1] ?? 0;
              final height = maxCount == 0 ? 0.0 : (count / maxCount) * 100.0;
              return Column(
                children: [
                  Text(count.toString(), style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: height.clamp(4.0, 100.0),
                    decoration: BoxDecoration(
                      color: theme.primary.withAlpha(count == 0 ? 20 : 255),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[i], style: AppTypography.caption.copyWith(fontSize: 10)),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('Total Reports: ${reports.length}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAttendanceConsistency(BuildContext context, List<dynamic> logs) {
    final theme = FlutterFlowTheme.of(context);
    // Group by class and calculate %
    final Map<String, List<dynamic>> classLogs = {};
    for (var l in logs) {
      classLogs[l.className] = (classLogs[l.className] ?? [])..add(l);
    }

    final sortedClasses = classLogs.keys.toList()..sort();

    return Column(
      children: sortedClasses.map((className) {
        final logsForClass = classLogs[className]!;
        final presentCount = logsForClass.where((l) => l.status == 'Present').length;
        final percentage = (presentCount / logsForClass.length);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(className, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${(percentage * 100).toInt()}%', style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: theme.alternate,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
