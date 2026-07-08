import '/backend/services/app_constants.dart';
import '/backend/models/student_attendance.dart';
import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'monthly_report_model.dart';
export 'monthly_report_model.dart';

class MonthlyReportWidget extends ConsumerStatefulWidget {
  const MonthlyReportWidget({super.key});

  static String routeName = 'MonthlyReport';
  static String routePath = '/monthlyReport';

  @override
  ConsumerState<MonthlyReportWidget> createState() => _MonthlyReportWidgetState();
}

class _MonthlyReportWidgetState extends ConsumerState<MonthlyReportWidget> {
  late MonthlyReportModel _model;
  bool _isLoading = false;
  List<Student> _students = [];
  Map<String, List<StudentAttendance>> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MonthlyReportModel());
  }

  Future<void> _fetchReport() async {
    if (_model.selectedClass == null || _model.selectedMonth == null) return;

    setState(() => _isLoading = true);
    try {
      final studentRepo = ref.read(studentRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      final students = await studentRepo.getStudentsByClass(_model.selectedClass!);
      final attendance = await attendanceRepo.getMonthlyAttendance(
        _model.selectedClass!, 
        _model.selectedMonth!
      );

      final grouped = <String, List<StudentAttendance>>{};
      for (var record in attendance) {
        grouped.putIfAbsent(record.studentId, () => []).add(record);
      }

      if (!mounted) return;
      setState(() {
        _students = students;
        _attendanceData = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          wrapWithModel(
            model: createModel(context, () => HeaderSectionModel()),
            updateCallback: () => safeSetState(() {}),
            child: HeaderSectionWidget(
              title: 'Monthly Attendance',
              subtitle: 'Attendance analysis per student',
              onBackPressed: () async => context.safePop(),
              showActionIcon: false,
            ),
          ),
          _buildFilters(context),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_students.isEmpty && _model.selectedClass != null)
            Expanded(child: Center(child: Text('No records found.', style: FlutterFlowTheme.of(context).bodyMedium)))
          else if (_model.selectedClass == null)
            Expanded(child: Center(child: Text('Select Class & Month', style: FlutterFlowTheme.of(context).bodyMedium)))
          else
            _buildReportList(context),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: FlutterFlowDropDown<String>(
              controller: _model.classDropdownController ??= FormFieldController<String>(_model.selectedClass),
              options: AppConstants.classOptions,
              onChanged: (val) {
                setState(() => _model.selectedClass = val);
                _fetchReport();
              },
              height: 48,
              hintText: 'Select Class',
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: 12,
              borderWidth: 1,
              borderColor: FlutterFlowTheme.of(context).alternate,
              hidesUnderline: true,
              textStyle: FlutterFlowTheme.of(context).bodyMedium,
              elevation: 2.0,
              margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () async {
                // Simplified month picker - in a real app you'd want a specialized month picker
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _model.selectedMonth ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                  helpText: 'SELECT MONTH',
                );
                if (picked != null) {
                  setState(() => _model.selectedMonth = DateTime(picked.year, picked.month));
                  _fetchReport();
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 18, color: FlutterFlowTheme.of(context).primary),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM yyyy').format(_model.selectedMonth!)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final student = _students[index];
          final logs = _attendanceData[student.studentId] ?? [];
          final presentCount = logs.where((l) => l.status == 'Present').length;
          final totalDays = logs.length;
          final percentage = totalDays == 0 ? 0.0 : (presentCount / totalDays) * 100;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roll ${student.rollNo} • ${student.name}',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Present: $presentCount / $totalDays days',
                        style: FlutterFlowTheme.of(context).labelSmall,
                      ),
                    ],
                  ),
                ),
                _buildPercentageIndicator(percentage),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPercentageIndicator(double percentage) {
    final color = percentage >= 90 
        ? Colors.green 
        : (percentage >= 75 ? Colors.orange : Colors.red);
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha((0.5 * 255).toInt())),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
