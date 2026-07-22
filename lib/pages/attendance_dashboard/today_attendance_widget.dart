import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'today_attendance_model.dart';

class TodayAttendanceWidget extends ConsumerStatefulWidget {
  const TodayAttendanceWidget({super.key});

  static String routeName = 'TodayAttendance';
  static String routePath = '/todayAttendance';

  @override
  ConsumerState<TodayAttendanceWidget> createState() => _TodayAttendanceWidgetState();
}

class _TodayAttendanceWidgetState extends ConsumerState<TodayAttendanceWidget> {
  late TodayAttendanceModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TodayAttendanceModel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final logsAsync = ref.watch(studentAttendanceLogsProvider);
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: "Today's Attendance",
            subtitle: dateTimeFormat('yMMMd', DateTime.now()),
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              children: [
                AppSearchBar(
                  hintText: 'Search student...',
                  onChanged: (val) => setState(() => _model.searchQuery = val),
                ),
                const SizedBox(height: 8),
                studentsAsync.when(
                  data: (students) {
                    final classes = students.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList()..sort();
                    return DropDownWidget(
                      label: 'Class Filter',
                      labelPresent: false,
                      options: ['All Classes', ...classes],
                      onChanged: (val) => setState(() => _model.selectedClass = val == 'All Classes' ? null : val),
                      hint: 'All Classes',
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final today = DateTime.now();
                final todayLogs = logs.where((l) => 
                  l.date.year == today.year && 
                  l.date.month == today.month && 
                  l.date.day == today.day
                ).toList();

                var filtered = todayLogs.where((l) {
                  final matchesClass = _model.selectedClass == null || l.className == _model.selectedClass;
                  final matchesSearch = l.studentName.toLowerCase().contains(_model.searchQuery.toLowerCase());
                  return matchesClass && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 48, color: theme.secondaryText),
                        const SizedBox(height: 12),
                        Text('No records found for today.', style: theme.labelSmall),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    return _buildLogTile(context, log);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile(BuildContext context, StudentAttendance log) {
    final theme = FlutterFlowTheme.of(context);
    final color = _getStatusColor(log.status, theme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
            child: Icon(_getStatusIcon(log.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.studentName, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${log.className} • ${log.subject}', style: AppTypography.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Text(
              log.status.toUpperCase(),
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, FlutterFlowTheme theme) {
    switch (status) {
      case 'Present': return theme.success;
      case 'Absent': return theme.error;
      case 'Leave': return theme.warning;
      default: return theme.secondaryText;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present': return Icons.check_circle_rounded;
      case 'Absent': return Icons.cancel_rounded;
      case 'Leave': return Icons.pause_circle_rounded;
      default: return Icons.help_rounded;
    }
  }
}
