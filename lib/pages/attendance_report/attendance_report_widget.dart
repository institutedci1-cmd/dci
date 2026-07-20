import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/excel_service/excel_service.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_drop_down.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/pages/attendance_report/attendance_report_model.dart';

class AttendanceReportWidget extends ConsumerStatefulWidget {
  const AttendanceReportWidget({super.key});

  static String routeName = 'AttendanceReport';
  static String routePath = '/attendanceReport';

  @override
  ConsumerState<AttendanceReportWidget> createState() => _AttendanceReportWidgetState();
}

class _AttendanceReportWidgetState extends ConsumerState<AttendanceReportWidget> {
  late AttendanceReportModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttendanceReportModel());
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: studentsAsync.when(
        data: (allStudents) {
          final dynamicClassOptions = allStudents
              .map((s) => s.className)
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          return Column(
            children: [
              _buildHeader(context),
              _buildFilters(context, dynamicClassOptions),
              _buildReportContent(context),
            ],
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error loading student data: $err'))),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return wrapWithModel(
      model: createModel(context, () => HeaderSectionModel()),
      updateCallback: () => safeSetState(() {}),
      child: HeaderSectionWidget(
        title: 'Attendance Report',
        subtitle: 'Daily analysis per student',
        onBackPressed: () async => context.safePop(),
        actionIcon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 24.0),
        onActionPressed: () async {
          if (_model.selectedClass == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a class first.')));
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          final reportData = ref.read(dailyAttendanceReportProvider((
            className: _model.selectedClass!,
            date: _model.selectedDate ?? DateTime.now(),
          ))).value;

          if (reportData != null && reportData.students.isNotEmpty) {
            final success = await ExcelService.exportAttendanceReport(
              reportData.students,
              reportData.attendance,
              _model.selectedClass!,
              _model.selectedDate ?? DateTime.now(),
            );
            if (!mounted) return;
            if (success) {
              messenger.showSnackBar(const SnackBar(content: Text('Report exported successfully.')));
            }
          } else {
            if (mounted) {
              messenger.showSnackBar(const SnackBar(content: Text('No data to export.')));
            }
          }
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    if (_model.selectedClass == null) {
      return Expanded(
        child: Center(
          child: Text('Select Class & Date to view report', style: FlutterFlowTheme.of(context).bodyMedium),
        ),
      );
    }

    final reportAsync = ref.watch(dailyAttendanceReportProvider((
      className: _model.selectedClass!,
      date: _model.selectedDate ?? DateTime.now(),
    )));

    return reportAsync.when(
      data: (data) {
        if (data.students.isEmpty) {
          return Expanded(
            child: Center(
              child: Text('No records found for this class.', style: FlutterFlowTheme.of(context).bodyMedium),
            ),
          );
        }
        return _buildReportList(context, data.students, data.attendance);
      },
      loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Expanded(child: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildFilters(BuildContext context, List<String> classOptions) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: FlutterFlowDropDown<String>(
              controller: _model.classDropdownController!,
              options: classOptions.isEmpty ? ['No Classes'] : classOptions,
              onChanged: (val) {
                if (val == 'No Classes') return;
                setState(() => _model.selectedClass = val);
              },
              height: 48,
              hintText: 'Class',
              fillColor: theme.secondaryBackground,
              borderRadius: AppRadius.md,
              borderWidth: 1,
              borderColor: theme.alternate,
              hidesUnderline: true,
              textStyle: AppTypography.body,
              elevation: 0,
              margin: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _model.selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _model.selectedDate = picked);
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: theme.alternate),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _model.selectedDate == null ? 'Select Date' : DateFormat('yMMMd').format(_model.selectedDate!),
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(BuildContext context, List<Student> students, List<StudentAttendance> attendance) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final student = students[index];
          final logs = attendance.where((l) => l.studentId == student.studentId).toList();
          final status = logs.isNotEmpty ? logs.first.status : 'Not Marked';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
              boxShadow: AppShadows.low,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roll ${student.rollNo} • ${student.name}',
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student ID: ${student.studentId}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(status),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'Present': color = Colors.green; break;
      case 'Absent': color = Colors.red; break;
      case 'Leave': color = Colors.orange; break;
      default: color = Colors.grey;
    }
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha((0.5 * 255).toInt())),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
