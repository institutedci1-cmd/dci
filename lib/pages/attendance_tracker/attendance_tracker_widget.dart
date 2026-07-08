import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/shared/app_search_bar.dart';
import '/components/shared/attendance_student_card.dart';
import '/components/shared/app_primary_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../index.dart';
import 'sections/attendance_selection_section.dart';
import 'sections/attendance_summary_footer.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppSearchBar(
        controller: _model.searchFieldModel.inputTextController,
        hintText: 'Search Roll No, Phone, Name...',
        onChanged: (val) => _filterStudents(val),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'All Present', Icons.check_circle_rounded, AppColors.success,
              () => setState(() {
                for (var s in _allStudents) {
                  _model.attendanceMap[s.studentId] = 'Present';
                }
              }),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildActionButton(
              'All Absent', Icons.cancel_rounded, AppColors.error,
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

  Widget _buildWhatsAppToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
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

  Future<void> _fetchStudents() async {
    if (_model.selectedClass == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(studentRepositoryProvider);
      final students = await repository.getStudentsByClass(_model.selectedClass!);
      
      final subjectText = _model.subjectFieldModel.inputTextController?.text.trim() ?? '';

      // Check if already submitted
      if (_model.selectedDate != null && subjectText.isNotEmpty) {
        final exists = await ref.read(attendanceRepositoryProvider).checkAttendanceExists(
          _model.selectedClass!, 
          subjectText, 
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
      final q = (query ?? '').trim().toLowerCase();
      _model.searchQuery = q;
      if (q.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((s) {
          return s.name.toLowerCase().contains(q) || 
                 s.studentId.toLowerCase().contains(q) ||
                 s.rollNo.contains(q) ||
                 (s.parentPhone?.contains(q) ?? false) ||
                 (s.parentName?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _saveAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final subjectText = _model.subjectFieldModel.inputTextController?.text.trim() ?? '';

    if (_model.selectedClass == null || _model.selectedDate == null || subjectText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select class, date and enter subject.')));
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
          subject: subjectText,
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
        bottomNavigationBar: _allStudents.isNotEmpty 
            ? AttendanceSummaryFooter(
                presentCount: presentCount,
                absentCount: absentCount,
                percentage: percentage,
                isLoading: _isLoading,
                isAlreadySubmitted: _isAlreadySubmitted,
                onSubmit: _saveAttendance,
              )
            : null,
        body: StreamBuilder<List<Student>>(
          stream: ref.watch(studentRepositoryProvider).getAllStudentsStream(),
          builder: (context, snapshot) {
            final allStudentsInDb = snapshot.data ?? [];
            final dynamicClassOptions = allStudentsInDb
                .map((s) => s.className)
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            return Column(
              children: [
                _buildHeader(context),
                AttendanceSelectionSection(
                  model: _model,
                  classOptions: dynamicClassOptions,
                  onClassChanged: _fetchStudents,
                  onDateChanged: () async {
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
                  onSubjectChanged: _fetchStudents,
                ),
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
                        AppPrimaryButton(
                          onPressed: () => _fetchStudents(),
                          text: 'Retry',
                          width: 120.0,
                        ),
                      ],
                    ),
                  )
                else if (_allStudents.isEmpty && _model.selectedClass != null)
                  Expanded(child: Center(child: Text('No students found in this class.', style: FlutterFlowTheme.of(context).bodyMedium)))
                else if (_model.selectedClass == null)
                  Expanded(child: Center(child: Text('Select Class & Enter Subject', style: FlutterFlowTheme.of(context).bodyMedium)))
                else
                  _buildStudentList(context),
                if (_allStudents.isNotEmpty) _buildWhatsAppToggle(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: _filteredStudents.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final student = _filteredStudents[index];
          final status = _model.attendanceMap[student.studentId] ?? 'Present';

          return AttendanceStudentCard(
            name: student.name,
            rollNo: student.rollNo,
            status: status,
            onTap: () {
              setState(() {
                _model.attendanceMap[student.studentId] = 
                    status == 'Present' ? 'Absent' : 'Present';
              });
            },
          );
        },
      ),
    );
  }
}
