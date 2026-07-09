import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/components/shared/app_search_bar.dart';
import '/components/shared/attendance_student_card.dart';
import '/components/shared/app_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    int presentCount = _allStudents.where((s) => _model.attendanceMap[s.studentId] == 'Present').length;
    int absentCount = _allStudents.length - presentCount;
    double percentage = _allStudents.isEmpty ? 0 : (presentCount / _allStudents.length) * 100;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          title: Text('Mark Attendance', style: AppTypography.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.safePop(),
          ),
        ),
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
                AttendanceSelectionSection(
                  model: _model,
                  classOptions: dynamicClassOptions,
                  onClassChanged: _fetchStudents,
                  onDateChanged: _pickDate,
                  onSubjectChanged: _fetchStudents,
                ),
                if (_isAlreadySubmitted) _buildAlreadySubmittedWarning(),
                _buildSearchAndActions(),
                Expanded(
                  child: _buildMainContent(),
                ),
                if (_allStudents.isNotEmpty) _buildWhatsAppToggle(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlreadySubmittedWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Attendance already submitted. Submitting again will update records.',
              style: AppTypography.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        children: [
          AppSearchBar(
            controller: _model.searchFieldModel.inputTextController,
            hintText: 'Search student by name or roll...',
            onChanged: _filterStudents,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'All Present',
                  variant: AppButtonVariant.outline,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => _bulkMark('Present'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  text: 'All Absent',
                  variant: AppButtonVariant.outline,
                  icon: Icons.cancel_outlined,
                  onPressed: () => _bulkMark('Absent'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: SwitchListTile.adaptive(
        value: _sendWhatsAppAlerts,
        onChanged: (val) => setState(() => _sendWhatsAppAlerts = val),
        title: Text('WhatsApp Alerts', style: AppTypography.label),
        subtitle: Text('Notify parents of absences', style: AppTypography.caption),
        activeColor: AppColors.accent,
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return _buildErrorState();
    if (_allStudents.isEmpty) return _buildEmptyState();
    
    return _buildStudentList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _model.selectedClass == null ? 'Select Class & Subject' : 'No students found',
            style: AppTypography.section.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ensure the class selection is correct.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(_errorMessage!, style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Retry', 
            onPressed: _fetchStudents, 
            width: 140, 
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      itemCount: _filteredStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
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
    );
  }

  void _bulkMark(String status) {
    setState(() {
      for (var s in _allStudents) {
        _model.attendanceMap[s.studentId] = status;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _model.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _model.selectedDate = picked);
      _fetchStudents();
    }
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
        _errorMessage = 'Failed to load students.';
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String? query) {
    setState(() {
      final q = (query ?? '').trim().toLowerCase();
      if (q.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((s) {
          return s.name.toLowerCase().contains(q) || s.rollNo.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _saveAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final subjectText = _model.subjectFieldModel.inputTextController?.text.trim() ?? '';

    if (_model.selectedClass == null || _model.selectedDate == null || subjectText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all class and subject details.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
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

      await ref.read(attendanceRepositoryProvider).recordStudentAttendance(attendanceList);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance recorded successfully.')));
      context.goNamed(AttendanceDashboardWidget.routeName);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
