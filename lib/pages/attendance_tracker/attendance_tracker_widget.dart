import '/backend/services/app_constants.dart';
import '/backend/models/student_attendance.dart';
import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../index.dart';
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
  bool _isAlreadySubmitted = false;
  bool _sendWhatsAppAlerts = false;
  String? _errorMessage;
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];

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

  Future<void> _fetchStudents() async {
    if (_model.selectedClass == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(studentRepositoryProvider);
      final students = await repository.getStudentsByClass(_model.selectedClass!);
      
      // Check if already submitted
      if (_model.selectedSubject != null && _model.selectedDate != null) {
        final exists = await ref.read(attendanceRepositoryProvider).checkAttendanceExists(
          _model.selectedClass!, 
          _model.selectedSubject!, 
          _model.selectedDate!
        );
        _isAlreadySubmitted = exists;
      }

      if (!mounted) return;
      
      setState(() {
        _allStudents = students;
        _filteredStudents = students;
        // Default all to Present
        for (var s in students) {
          if (!_model.attendanceMap.containsKey(s.studentId)) {
            _model.attendanceMap[s.studentId] = 'Present';
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load students. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String? query) {
    setState(() {
      final q = query ?? '';
      _model.searchQuery = q;
      if (q.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((s) => 
          s.name.toLowerCase().contains(q.toLowerCase()) || 
          s.studentId.toLowerCase().contains(q.toLowerCase()) ||
          s.rollNo.contains(q)
        ).toList();
      }
    });
  }

  Future<void> _saveAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_model.selectedClass == null || _model.selectedSubject == null || _model.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final attendanceRepository = ref.read(attendanceRepositoryProvider);
      final whatsappService = ref.read(whatsappServiceProvider);
      
      final attendanceList = _allStudents.map((s) {
        return StudentAttendance(
          id: '',
          studentId: s.studentId,
          studentName: s.name,
          className: _model.selectedClass!,
          subject: _model.selectedSubject!,
          status: _model.attendanceMap[s.studentId] ?? 'Present',
          date: _model.selectedDate!,
          markedBy: user.uid,
        );
      }).toList();

      await attendanceRepository.recordStudentAttendance(attendanceList);

      if (_sendWhatsAppAlerts) {
        for (var s in _allStudents) {
          final status = _model.attendanceMap[s.studentId] ?? 'Present';
          if (status == 'Absent' && s.parentPhone != null && s.parentPhone!.isNotEmpty) {
            await whatsappService.sendTemplateMessage(
              to: s.parentPhone!,
              templateName: 'student_absent_alert',
              parameters: [s.name, dateTimeFormat('yMMMd', _model.selectedDate!)],
            );
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance recorded successfully.')));
      context.goNamed(AttendanceDashboardWidget.routeName);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _allStudents.where((s) => _model.attendanceMap[s.studentId] == 'Present').length;
    int absentCount = _allStudents.length - presentCount;
    double percentage = _allStudents.isEmpty ? 0 : (presentCount / _allStudents.length) * 100;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            _buildHeader(context),
            _buildSelectionRow(context),
            if (_isAlreadySubmitted) _buildAlreadySubmittedWarning(context),
            _buildSearchBox(context),
            _buildQuickActions(context),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ButtonWidget(
                      onPressed: _fetchStudents,
                      content: 'Retry',
                      variant: 'primary',
                      size: 'small',
                    ),
                  ],
                ),
              )
            else if (_allStudents.isEmpty && _model.selectedClass != null)
              Expanded(child: Center(child: Text('No students found.', style: FlutterFlowTheme.of(context).bodyMedium)))
            else if (_model.selectedClass == null)
              Expanded(child: Center(child: Text('Select Class & Subject', style: FlutterFlowTheme.of(context).bodyMedium)))
            else
              _buildStudentList(context),
            if (_allStudents.isNotEmpty) _buildWhatsAppToggle(context),
            if (_allStudents.isNotEmpty) _buildSummary(presentCount, absentCount, percentage),
            if (_model.selectedClass != null && _allStudents.isNotEmpty)
              _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: SwitchListTile.adaptive(
          value: _sendWhatsAppAlerts,
          onChanged: (val) => setState(() => _sendWhatsAppAlerts = val),
          title: Text(
            'WhatsApp Alerts',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            'Notify parents of absent students',
            style: FlutterFlowTheme.of(context).labelSmall,
          ),
          activeTrackColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return wrapWithModel(
      model: createModel(context, () => HeaderSectionModel()),
      updateCallback: () => safeSetState(() {}),
      child: HeaderSectionWidget(
        title: 'Student Attendance',
        subtitle: 'Tick & Submit Flow',
        onBackPressed: () async => context.goNamed(AttendanceDashboardWidget.routeName),
        showActionIcon: false,
      ),
    );
  }

  Widget _buildSelectionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
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
                      _fetchStudents();
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
                        Icon(Icons.calendar_today_rounded, size: 18, color: FlutterFlowTheme.of(context).primary),
                        const SizedBox(width: 8),
                        Text(dateTimeFormat('yMMMd', _model.selectedDate)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FlutterFlowDropDown<String>(
                  controller: _model.classDropdownController ??= FormFieldController<String>(_model.selectedClass),
                  options: AppConstants.classOptions,
                  onChanged: (val) {
                    setState(() => _model.selectedClass = val);
                    _fetchStudents();
                  },
                  height: 48,
                  hintText: 'Class',
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
            ],
          ),
          const SizedBox(height: 12),
          FlutterFlowDropDown<String>(
            controller: _model.subjectDropdownController ??= FormFieldController<String>(_model.selectedSubject),
            options: AppConstants.subjectOptions,
            onChanged: (val) {
              setState(() => _model.selectedSubject = val);
              _fetchStudents();
            },
            width: double.infinity,
            height: 48,
            hintText: 'Select Subject',
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: 12,
            borderWidth: 1,
            borderColor: FlutterFlowTheme.of(context).alternate,
            hidesUnderline: true,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            elevation: 2.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadySubmittedWarning(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).warning.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).warning),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: FlutterFlowTheme.of(context).warning),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Attendance already submitted for this class/subject/date. Submitting will update existing records.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: wrapWithModel(
        model: _model.searchFieldModel,
        updateCallback: () => safeSetState(() {}),
        child: TextFieldWidget(
          label: '',
          labelPresent: false,
          hint: 'Search by Roll No, Name or ID...',
          leadingIcon: const Icon(Icons.search_rounded),
          leadingIconPresent: true,
          variant: 'outlined',
          onChange: (val) => _filterStudents(val),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'All Present', Icons.check_circle_rounded, Colors.green,
              () => setState(() {
                for (var s in _allStudents) {
                  _model.attendanceMap[s.studentId] = 'Present';
                }
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'All Absent', Icons.cancel_rounded, Colors.red,
              () => setState(() {
                for (var s in _allStudents) {
                  _model.attendanceMap[s.studentId] = 'Absent';
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha((0.5 * 255).toInt())),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredStudents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final student = _filteredStudents[index];
          final isPresent = _model.attendanceMap[student.studentId] == 'Present';

          return InkWell(
            onTap: () {
              setState(() {
                _model.attendanceMap[student.studentId] = isPresent ? 'Absent' : 'Present';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPresent 
                    ? Colors.green.withAlpha((0.3 * 255).toInt()) 
                    : Colors.red.withAlpha((0.3 * 255).toInt()),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isPresent,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _model.attendanceMap[student.studentId] = (val ?? false) ? 'Present' : 'Absent';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
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
                        Text('ID: ${student.studentId}', style: FlutterFlowTheme.of(context).labelSmall),
                      ],
                    ),
                  ),
                  Text(
                    isPresent ? 'PRESENT' : 'ABSENT',
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(int present, int absent, double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border(top: BorderSide(color: FlutterFlowTheme.of(context).alternate)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total', '${present + absent}', Colors.blue),
              _buildSummaryItem('Present', '$present', Colors.green),
              _buildSummaryItem('Absent', '$absent', Colors.red),
              _buildSummaryItem('Rate', '${percentage.toStringAsFixed(1)}%', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: FlutterFlowTheme.of(context).labelSmall),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground),
      child: wrapWithModel(
        model: _model.buttonModel,
        updateCallback: () => safeSetState(() {}),
        child: ButtonWidget(
          content: _isAlreadySubmitted ? 'Update Attendance' : 'Submit Attendance',
          variant: 'primary',
          size: 'large',
          fullWidth: true,
          loading: _isLoading,
          onPressed: _saveAttendance,
        ),
      ),
    );
  }
}
