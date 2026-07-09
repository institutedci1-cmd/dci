import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

export 'attendance_history_model.dart';

class AttendanceHistoryWidget extends ConsumerStatefulWidget {
  const AttendanceHistoryWidget({super.key});

  static String routeName = 'AttendanceHistory';
  static String routePath = '/attendanceHistory';

  @override
  ConsumerState<AttendanceHistoryWidget> createState() => _AttendanceHistoryWidgetState();
}

class _AttendanceHistoryWidgetState extends ConsumerState<AttendanceHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Logs'),
      ),
      body: StreamBuilder<List<StudentAttendance>>(
        stream: ref.watch(attendanceRepositoryProvider).getStudentAttendanceLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Text('No attendance records found.', style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildLogCard(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(StudentAttendance record) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(record.status);
    
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(_getStatusIcon(record.status), color: statusColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.studentName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'Class: ${record.className} • Subject: ${record.subject}',
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  dateTimeFormat('yMMMd', record.date),
                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              record.status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
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
