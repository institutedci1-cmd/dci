
import '/backend/models/student_attendance.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/error_handler.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/shared/attendance_student_card.dart';
import '/components/shared/app_primary_button.dart';
import '/components/shared/app_search_bar.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../index.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

// Model and sections imports
import 'attendance_tracker_model.dart';
import 'sections/attendance_selection_section.dart';
import 'sections/attendance_summary_footer.dart';

// Direct imports for navigation targets to avoid circular dependency


class AttendanceTrackerWidget extends ConsumerStatefulWidget {
  const AttendanceTrackerWidget({super.key});

  static String routeName = 'AttendanceTracker';
  static String routePath = '/attendanceTracker';

  @override
  ConsumerState<AttendanceTrackerWidget> createState() => _AttendanceTrackerWidgetState();
}

class _AttendanceTrackerWidgetState extends ConsumerState<AttendanceTrackerWidget> {
  late AttendanceTrackerModel _model;
  bool _isLoading = false;
  bool _isAlreadySubmitted = false;
  bool _sendWhatsAppAlerts = false;
  String? _errorMessage;
  String? _initErrorMessage;
  List<Student> _allStudents = [];
  bool _isDataLoading = true;
  Stream<List<Student>>? _studentsStream;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AttendanceTrackerModel());
    _initializeFormData();
  }

  Future<void> _initializeFormData() async {
    if (!mounted) return;
    setState(() {
      _isDataLoading = true;
      _initErrorMessage = null;
    });
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final studentRepo = ref.read(studentRepositoryProvider);
      
      // Initialize the stream once
      _studentsStream ??= studentRepo.getAllStudentsStream();
      
      final teachers = await userRepo.getTeachers();

      final subjects = teachers
          .map((t) => t['subject_expertise'] as String?)
          .where((s) => s != null && s.isNotEmpty)
          .expand((s) => s!.split(',').map((e) => e.trim()))
          .toSet()
          .toList();

      if (mounted) {
        setState(() {
          _model.subjectOptions = subjects..sort();
          _isDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
          _initErrorMessage = 'Failed to initialize tracker data.';
        });
        ErrorHandler.show(context, e);
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    if (_model.selectedClass == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(studentRepositoryProvider);
      final students = await repository.getStudentsByClass(_model.selectedClass!);

      if (!mounted) return;
      
      setState(() {
        _allStudents = students;
        for (final s in students) {
          if (!_model.attendanceMap.containsKey(s.id)) {
            _model.attendanceMap[s.id] = 'Present';
          }
        }
        _isLoading = false;
      });
      
      _checkExistingAttendance();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load students. Please try again.';
        _isLoading = false;
      });
      ErrorHandler.show(context, e);
    }
  }

  Future<void> _checkExistingAttendance() async {
    final className = _model.selectedClass;
    final subject = _model.selectedSubject;
    final date = _model.selectedDate;

    if (className == null || subject == null || date == null) {
      if (mounted) setState(() => _isAlreadySubmitted = false);
      return;
    }

    try {
      final exists = await ref.read(attendanceRepositoryProvider).checkAttendanceExists(
        className, 
        subject, 
        date
      );
      if (mounted) setState(() => _isAlreadySubmitted = exists);
    } catch (e) {
      debugPrint('Check existing error: $e');
      if (mounted) setState(() => _isAlreadySubmitted = false);
    }
  }

  Future<void> _saveAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final subjectText = _model.selectedSubject ?? '';

    if (_model.selectedClass == null || _model.selectedDate == null || subjectText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Class, Subject and Date.')));
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
          status: _model.attendanceMap[s.id] ?? 'Present',
          date: _model.selectedDate!,
          markedBy: user.uid,
        );
      }).toList();

      await attendanceRepository.recordStudentAttendance(attendanceList);

      if (_sendWhatsAppAlerts) {
        final absentStudents = _allStudents.where((s) => (_model.attendanceMap[s.id] ?? 'Present') == 'Absent').toList();
        
        if (absentStudents.isNotEmpty) {
          final alertFutures = absentStudents
              .where((s) => s.parentPhone != null && s.parentPhone!.isNotEmpty)
              .map((s) => whatsappService.sendTemplateMessage(
                    to: s.parentPhone!,
                    templateName: 'student_absent_alert',
                    parameters: [s.name, dateTimeFormat('yMMMd', _model.selectedDate!)],
                  ));
          
          // Send alerts in parallel to avoid blocking
          await Future.wait(alertFutures).catchError((e) {
            debugPrint('WhatsApp alerts error: $e');
            return <bool>[];
          });
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance recorded successfully.')));
      context.goNamed(AttendanceDashboardWidget.routeName);
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareAttendanceSummary() async {
    if (_allStudents.isEmpty) return;

    final presentCount = _allStudents.where((s) => _model.attendanceMap[s.id] == 'Present').length;
    final absentCount = _allStudents.length - presentCount;
    final className = _model.selectedClass ?? 'N/A';
    final subject = _model.selectedSubject ?? 'N/A';
    final date = dateTimeFormat('yMMMd', _model.selectedDate ?? DateTime.now());

    final message = '''
📊 *Attendance Summary*
Class: $className
Subject: $subject
Date: $date

✅ Present: $presentCount
❌ Absent: $absentCount
📈 Rate: ${(_allStudents.isEmpty ? 0 : (presentCount / _allStudents.length) * 100).toStringAsFixed(0)}%

Total Students: ${_allStudents.length}
''';

    try {
      await SharePlus.share(message, subject: 'Attendance Summary - $className');
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_initErrorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(_initErrorMessage!, style: AppTypography.body),
              const SizedBox(height: 24),
              AppPrimaryButton(onPressed: _initializeFormData, text: 'Retry Loading', width: 160.0),
            ],
          ),
        ),
      );
    }

    int presentCount = _allStudents.where((s) => _model.attendanceMap[s.id] == 'Present').length;
    int absentCount = _allStudents.length - presentCount;
    double percentage = _allStudents.isEmpty ? 0 : (presentCount / _allStudents.length) * 100;

    final List<String> combinedSubjects = {
      'English',
      'Marathi',
      'Math',
      'Science',
      ..._model.subjectOptions,
    }.toList().where((s) => s.isNotEmpty).toList()..sort();

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
                onShare: _shareAttendanceSummary,
              )
            : null,
        body: Column(
          children: [
            wrapWithModel(
              model: createModel(context, () => HeaderSectionModel()),
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Attendance Tracker',
                subtitle: 'Daily Student Log',
                onBackPressed: () async => context.goNamed(AttendanceDashboardWidget.routeName),
                showActionIcon: false,
              ),
            ),
            _buildSelectionArea(context, combinedSubjects),
            if (_allStudents.isNotEmpty) _buildSearchBar(),
            if (_isAlreadySubmitted && _allStudents.isNotEmpty) _buildAlreadySubmittedWarning(),
            if (_allStudents.isNotEmpty) _buildQuickActions(),
            Expanded(
              child: _buildMainContent(),
            ),
            if (_allStudents.isNotEmpty) _buildWhatsAppToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage!, style: AppTypography.body),
          const SizedBox(height: 16),
          AppPrimaryButton(onPressed: _loadStudents, text: 'Retry', width: 120.0),
        ],
      );
    }

    final filteredStudents = _allStudents.where((student) {
      if (_model.searchQuery.isEmpty) return true;
      final query = _model.searchQuery.toLowerCase();
      return student.name.toLowerCase().contains(query) || 
             student.rollNo.toLowerCase().contains(query);
    }).toList();

    if (_allStudents.isEmpty) {
      if (_model.selectedClass == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, size: 48, color: AppColors.primary.withAlpha(50)),
              const SizedBox(height: 16),
              Text(
                'Select a Class to load students',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }
      return const Center(child: Text('No students found in this class.'));
    }

    if (filteredStudents.isEmpty) {
      return const Center(child: Text('No students match your search.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      itemCount: filteredStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final status = _model.attendanceMap[student.id] ?? 'Present';
        return AttendanceStudentCard(
          key: ValueKey('student_${student.id}'),
          name: student.name,
          rollNo: student.rollNo,
          status: status,
          onTap: () {
            setState(() {
              _model.attendanceMap[student.id] = status == 'Present' ? 'Absent' : 'Present';
            });
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: AppSearchBar(
        controller: _model.searchFieldModel.inputTextController,
        hintText: 'Search by name or roll number...',
        onChanged: (val) {
          setState(() {
            _model.searchQuery = val;
          });
        },
        onClear: () {
          setState(() {
            _model.searchQuery = '';
          });
        },
      ),
    );
  }

  Widget _buildAlreadySubmittedWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(50)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text('Attendance already marked for this subject today. Submitting will update records.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 8),
      child: Row(
        children: [
          Expanded(child: _buildActionButton('All Present', Icons.check_circle_rounded, AppColors.success, () {
            setState(() { for (final s in _allStudents) _model.attendanceMap[s.id] = 'Present'; });
          })),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildActionButton('All Absent', Icons.cancel_rounded, AppColors.error, () {
            setState(() { for (final s in _allStudents) _model.attendanceMap[s.id] = 'Absent'; });
          })),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withAlpha(50))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(icon, color: color, size: 18), 
            const SizedBox(width: 6), 
            Flexible(
              child: Text(
                label, 
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: FlutterFlowTheme.of(context).alternate)),
        child: SwitchListTile.adaptive(
          dense: true,
          value: _sendWhatsAppAlerts,
          onChanged: (val) => setState(() => _sendWhatsAppAlerts = val),
          title: Text('WhatsApp Alerts for Absentees', style: AppTypography.label.copyWith(color: AppColors.textPrimary, fontSize: 13)),
          activeTrackColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSelectionArea(BuildContext context, List<String> subjects) {
    return StreamBuilder<List<Student>>(
      stream: _studentsStream,
      builder: (context, studentSnapshot) {
        final allStudentsInDb = studentSnapshot.data ?? [];
        final dynamicClassOptions = allStudentsInDb.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList()..sort();
        
        return AttendanceSelectionSection(
          model: _model,
          classOptions: dynamicClassOptions,
          subjectOptions: subjects,
          onClassChanged: _loadStudents,
          onDateChanged: () async {
            final picked = await showDatePicker(context: context, initialDate: _model.selectedDate ?? DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime.now());
            if (picked != null) { 
              setState(() => _model.selectedDate = picked); 
              _checkExistingAttendance(); 
            }
          },
          onSubjectChanged: _checkExistingAttendance,
        );
      },
    );
  }
}
