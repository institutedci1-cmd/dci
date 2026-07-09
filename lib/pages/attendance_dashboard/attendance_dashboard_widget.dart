import '/backend/models/student_attendance.dart';
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
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: AppColors.accent),
            onPressed: () => context.pushNamed(AttendanceTrackerWidget.routeName),
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
              title: 'Recent Logs',
              action: TextButton(
                onPressed: () => context.pushNamed(AttendanceHistoryWidget.routeName),
                child: const Text('View All'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRecentLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<List<StudentAttendance>>(
      stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final totalMarked = records.length;
        final presentCount = records.where((doc) => doc.status == 'Present').length;
        final attendanceRate = totalMarked == 0 ? 0 : ((presentCount / totalMarked) * 100).toInt();

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Marks',
                totalMarked.toString(),
                Icons.people_rounded,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Avg. Present',
                '$attendanceRate%',
                Icons.trending_up_rounded,
                AppColors.success,
              ),
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
            text: 'Mark New',
            icon: Icons.check_box_rounded,
            onPressed: () => context.pushNamed(AttendanceTrackerWidget.routeName),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            text: 'History',
            variant: AppButtonVariant.secondary,
            icon: Icons.history_rounded,
            onPressed: () => context.pushNamed(AttendanceHistoryWidget.routeName),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLogs() {
    return StreamBuilder<List<StudentAttendance>>(
      stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return Center(
            child: Text('No logs found.', style: Theme.of(context).textTheme.bodySmall),
          );
        }
        return Column(
          children: records.take(10).map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getStatusColor(record.status).withOpacity(0.1),
                      child: Icon(_getStatusIcon(record.status), color: _getStatusColor(record.status), size: 16),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.studentName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('${record.className} • ${dateTimeFormat('yMMMd', record.date)}', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                    Text(
                      record.status,
                      style: TextStyle(
                        color: _getStatusColor(record.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'Present' => AppColors.success,
      'Absent' => AppColors.error,
      'Leave' => AppColors.warning,
      _ => AppColors.textTertiary,
    };
  }

  IconData _getStatusIcon(String status) {
    return switch (status) {
      'Present' => Icons.check_circle_rounded,
      'Absent' => Icons.cancel_rounded,
      'Leave' => Icons.pause_circle_rounded,
      _ => Icons.help_rounded,
    };
  }
}
