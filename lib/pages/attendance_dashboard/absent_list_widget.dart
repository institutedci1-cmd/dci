import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:collection/collection.dart';
import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'absent_list_model.dart';

class AbsentListWidget extends ConsumerStatefulWidget {
  const AbsentListWidget({super.key});

  static String routeName = 'AbsentList';
  static String routePath = '/absentList';

  @override
  ConsumerState<AbsentListWidget> createState() => _AbsentListWidgetState();
}

class _AbsentListWidgetState extends ConsumerState<AbsentListWidget> {
  late AbsentListModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AbsentListModel());
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
            title: "Absent List",
            subtitle: dateTimeFormat('yMMMd', _model.selectedDate),
            onBackPressed: () async => context.safePop(),
            showActionIcon: true,
            actionIcon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            onActionPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _model.selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _model.selectedDate = picked);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: studentsAsync.when(
              data: (students) {
                final classes = students.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList()..sort();
                return DropDownWidget(
                  label: 'Filter by Class',
                  options: ['All Classes', ...classes],
                  onChanged: (val) => setState(() => _model.selectedClass = val == 'All Classes' ? null : val),
                  hint: 'All Classes',
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final dateLogs = logs.where((l) => 
                  l.date.year == _model.selectedDate.year && 
                  l.date.month == _model.selectedDate.month && 
                  l.date.day == _model.selectedDate.day &&
                  l.status == 'Absent'
                ).toList();

                var filtered = dateLogs.where((l) {
                  return _model.selectedClass == null || l.className == _model.selectedClass;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 48, color: theme.success),
                        const SizedBox(height: 12),
                        Text('No students absent on this day.', style: theme.labelSmall),
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
                    return _buildAbsentTile(context, log, studentsAsync);
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

  Widget _buildAbsentTile(BuildContext context, StudentAttendance log, AsyncValue<List<Student>> studentsAsync) {
    final theme = FlutterFlowTheme.of(context);
    final student = studentsAsync.value?.firstWhereOrNull((s) => s.id == log.studentId);
    final phone = student?.parentPhone ?? 'No Phone';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.error.withAlpha(50)),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: theme.error.withAlpha(20), shape: BoxShape.circle),
            child: Icon(Icons.person_off_rounded, color: theme.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.studentName, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${log.className} • Subject: ${log.subject}', style: AppTypography.caption.copyWith(fontSize: 12)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 12, color: theme.secondaryText),
                    const SizedBox(width: 4),
                    Text(phone, style: AppTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
            onPressed: () async {
              if (student?.parentPhone != null && student!.parentPhone!.isNotEmpty) {
                await launchURL('tel:${student.parentPhone}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parent phone number not available.'))
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
