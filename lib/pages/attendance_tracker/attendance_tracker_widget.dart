import '/backend/services/app_constants.dart';
import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_tracker_model.dart';
export 'attendance_tracker_model.dart';

class AttendanceTrackerWidget extends ConsumerStatefulWidget {
  const AttendanceTrackerWidget({super.key});

  static String routeName = 'AttendanceTracker';
  static String routePath = '/attendanceTracker';

  @override
  ConsumerState<AttendanceTrackerWidget> createState() =>
      _AttendanceTrackerWidgetState();
}

class _AttendanceTrackerWidgetState extends ConsumerState<AttendanceTrackerWidget> {
  late AttendanceTrackerModel _model;
  bool _isLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttendanceTrackerModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents(String? className) async {
    if (className == null) return;
    
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(studentRepositoryProvider);
      final students = await repository.getStudentsByClass(className);
      if (!mounted) return;
      
      setState(() {
        _model.students = students.map((s) => s.toFirestore()).toList(); // Keep compatible with model for now or update model
        _model.attendanceMap = {
          for (var s in students) s.studentId: 'Present'
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching students: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_model.selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class.')),
      );
      return;
    }

    if (_model.students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students to mark attendance for.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final attendanceRepository = ref.read(attendanceRepositoryProvider);
      final now = DateTime.now();
      
      final attendanceList = _model.students.map((s) {
        final studentId = s['student_id'] as String;
        return StudentAttendance(
          id: '', // Generated
          studentId: studentId,
          studentName: s['name'] as String,
          className: _model.selectedClass!,
          status: _model.attendanceMap[studentId] ?? 'Present',
          date: now,
          markedBy: user.uid,
        );
      }).toList();

      await attendanceRepository.recordStudentAttendance(attendanceList);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class attendance recorded successfully.')),
      );
      context.goNamed(AttendanceDashboardWidget.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving attendance: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            _buildHeader(context),
            _buildClassSelector(context),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_model.selectedClass == null)
              Expanded(
                child: Center(
                  child: Text(
                    'Select a class to mark attendance',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              )
            else if (_model.students.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No students found in this class.',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              )
            else
              _buildStudentList(context),
            if (_model.selectedClass != null && _model.students.isNotEmpty)
              _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return wrapWithModel(
      model: createModel(context, () => HeaderSectionModel()),
      updateCallback: () => safeSetState(() {}),
      child: HeaderSectionWidget(
        title: 'Class Attendance',
        subtitle: dateTimeFormat('MMMMEEEEd', getCurrentTimestamp),
        onBackPressed: () async =>
            context.goNamed(AttendanceDashboardWidget.routeName),
        actionIcon: Icon(
          Icons.history_rounded,
          color: FlutterFlowTheme.of(context).onPrimary,
          size: 24.0,
        ),
        onActionPressed: () async =>
            context.pushNamed(AttendanceHistoryWidget.routeName),
      ),
    );
  }

  Widget _buildClassSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Class',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
          const SizedBox(height: 8),
          FlutterFlowDropDown<String>(
            controller: _model.classDropdownController ??=
                FormFieldController<String>(_model.selectedClass),
            options: AppConstants.classOptions,
            onChanged: (val) {
              setState(() => _model.selectedClass = val);
              _fetchStudents(val);
            },
            width: double.infinity,
            height: 48.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            hintText: 'Choose class...',
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 1.0,
            borderRadius: 12.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            hidesUnderline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _model.students.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final student = _model.students[index];
          final studentId = student['student_id'] as String;
          final currentStatus = _model.attendanceMap[studentId] ?? 'Present';

          return Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] ?? 'Unknown',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('ID: $studentId', style: FlutterFlowTheme.of(context).labelSmall),
                      ],
                    ),
                  ),
                  _buildAttendanceToggle(studentId, currentStatus),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceToggle(String studentId, String currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(studentId, 'Present', Icons.check_circle_rounded, Colors.green, currentStatus == 'Present'),
        const SizedBox(width: 8),
        _buildStatusButton(studentId, 'Absent', Icons.cancel_rounded, Colors.red, currentStatus == 'Absent'),
        const SizedBox(width: 8),
        _buildStatusButton(studentId, 'Leave', Icons.pause_circle_rounded, Colors.orange, currentStatus == 'Leave'),
      ],
    );
  }

  Widget _buildStatusButton(String studentId, String status, IconData icon, Color color, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _model.attendanceMap[studentId] = status),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha((0.1 * 255).toInt()) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : FlutterFlowTheme.of(context).alternate),
        ),
        child: Icon(
          icon,
          color: isSelected ? color : FlutterFlowTheme.of(context).secondaryText,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: wrapWithModel(
          model: _model.buttonModel,
          updateCallback: () => safeSetState(() {}),
          child: ButtonWidget(
            content: 'Submit Attendance',
            variant: 'primary',
            size: 'large',
            fullWidth: true,
            onPressed: () => _saveAttendance(),
          ),
        ),
      ),
    );
  }
}
