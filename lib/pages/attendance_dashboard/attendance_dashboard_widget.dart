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
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Attendance Control', style: AppTypography.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: AppColors.primary, size: 22),
            onPressed: () => context.pushNamed(AttendanceTrackerWidget.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatsSection(isDesktop),
                const SizedBox(height: AppSpacing.lg),
                const AppSectionHeader(title: 'Quick Actions'),
                const SizedBox(height: AppSpacing.sm),
                _buildActionsRow(isDesktop),
                const SizedBox(height: AppSpacing.xl),
                AppSectionHeader(
                  title: 'Recent Activity',
                  action: TextButton(
                    onPressed: () => context.pushNamed(AttendanceHistoryWidget.routeName),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('View All', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildRecentLogs(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isDesktop) {
    return StreamBuilder<List<StudentAttendance>>(
      stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(limit: 100),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final totalMarked = records.length;
        final presentCount = records.where((doc) => doc.status == 'Present').length;
        final attendanceRate = totalMarked == 0 ? 0 : ((presentCount / totalMarked) * 100).toInt();

        final children = [
          Expanded(
            child: _buildStatCard(
              'Total Logs',
              totalMarked.toString(),
              Icons.assignment_ind_rounded,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              'Avg. Present',
              '$attendanceRate%',
              Icons.trending_up_rounded,
              AppColors.success,
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Today\'s Marked',
                records.where((r) {
                  final now = DateTime.now();
                  return r.date.year == now.year && r.date.month == now.month && r.date.day == now.day;
                }).length.toString(),
                Icons.today_rounded,
                AppColors.warning,
              ),
            ),
          ],
        ];

        return Row(children: children);
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.h1.copyWith(fontSize: 22)),
          Text(title, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildActionsRow(bool isDesktop) {
    final children = [
      Expanded(
        child: AppButton(
          text: 'Mark New Attendance',
          icon: Icons.check_box_rounded,
          onPressed: () => context.pushNamed(AttendanceTrackerWidget.routeName),
          height: 48,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: AppButton(
          text: 'History & Reports',
          variant: AppButtonVariant.outline,
          icon: Icons.history_rounded,
          onPressed: () => context.pushNamed(AttendanceHistoryWidget.routeName),
          height: 48,
        ),
      ),
    ];

    if (isDesktop) {
      return Row(children: [
        ...children,
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppButton(
            text: 'Student Database',
            variant: AppButtonVariant.ghost,
            icon: Icons.people_rounded,
            onPressed: () => context.pushNamed('StudentList'),
            height: 48,
          ),
        ),
      ]);
    }

    return Row(children: children);
  }

  Widget _buildRecentLogs(bool isDesktop) {
    return StreamBuilder<List<StudentAttendance>>(
      stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(limit: 12),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: CircularProgressIndicator()));
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text('No recent activity found.', style: AppTypography.caption),
            ),
          );
        }

        if (isDesktop) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: records.length,
            itemBuilder: (context, index) => _buildRecentLogItem(records[index]),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) => _buildRecentLogItem(records[index]),
        );
      },
    );
  }

  Widget _buildRecentLogItem(StudentAttendance record) {
    final color = _getStatusColor(record.status);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(record.status), color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.studentName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('${record.className} • ${dateTimeFormat('yMMMd', record.date)}', style: AppTypography.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              record.status.toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
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
