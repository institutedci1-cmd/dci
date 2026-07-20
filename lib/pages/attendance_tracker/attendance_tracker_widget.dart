import 'package:d_c_i_teacher_app/features/attendance/application/attendance_tracker_notifier.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/error_handler.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/attendance_student_card.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';

import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/attendance_dashboard/attendance_dashboard_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

// Model and sections imports
import 'package:d_c_i_teacher_app/pages/attendance_tracker/attendance_tracker_model.dart';
import 'package:d_c_i_teacher_app/pages/attendance_tracker/sections/attendance_selection_section.dart';
import 'package:d_c_i_teacher_app/pages/attendance_tracker/sections/attendance_summary_footer.dart';

class AttendanceTrackerWidget extends ConsumerStatefulWidget {
  const AttendanceTrackerWidget({super.key});

  static String routeName = 'AttendanceTracker';
  static String routePath = '/attendanceTracker';

  @override
  ConsumerState<AttendanceTrackerWidget> createState() => _AttendanceTrackerWidgetState();
}

class _AttendanceTrackerWidgetState extends ConsumerState<AttendanceTrackerWidget> {
  late AttendanceTrackerModel _model;
  bool _sendWhatsAppAlerts = false;

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
    final attendanceStateAsync = ref.watch(attendanceTrackerNotifierProvider);
    final notifier = ref.read(attendanceTrackerNotifierProvider.notifier);

    return attendanceStateAsync.when(
      data: (state) => _buildScaffold(context, state, notifier),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildScaffold(BuildContext context, AttendanceTrackerState state, AttendanceTrackerNotifier notifier) {
    int presentCount = state.students.where((s) => state.attendanceMap[s.id] == 'Present').length;
    int absentCount = state.students.length - presentCount;
    double percentage = state.students.isEmpty ? 0 : (presentCount / state.students.length) * 100;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        bottomNavigationBar: state.students.isNotEmpty 
            ? AttendanceSummaryFooter(
                presentCount: presentCount,
                absentCount: absentCount,
                percentage: percentage,
                isLoading: state.isSaving,
                isAlreadySubmitted: state.isAlreadySubmitted,
                onSubmit: () => _saveAttendance(state, notifier),
                onShare: () => _shareAttendanceSummary(state),
              )
            : null,
        body: Column(
          children: [
            wrapWithModel(
              model: createModel(context, () => HeaderSectionModel()),
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Daily Attendance',
                subtitle: 'Student Log',
                onBackPressed: () async => context.goNamed(AttendanceDashboardWidget.routeName),
                showActionIcon: false,
              ),
            ),
            _buildSelectionArea(context, state, notifier),
            if (state.students.isNotEmpty) _buildSearchBar(notifier),
            if (state.isAlreadySubmitted && state.students.isNotEmpty) _buildAlreadySubmittedWarning(),
            if (state.students.isNotEmpty) _buildQuickActions(notifier),
            Expanded(
              child: _buildMainContent(state, notifier),
            ),
            if (state.students.isNotEmpty) _buildWhatsAppToggle(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAttendance(AttendanceTrackerState state, AttendanceTrackerNotifier notifier) async {
    if (state.selectedClass == null || state.selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Class and Subject.')),
      );
      return;
    }

    final success = await notifier.saveAttendance(sendWhatsApp: _sendWhatsAppAlerts);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance recorded successfully.')),
      );
      context.goNamed(AttendanceDashboardWidget.routeName);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to record attendance.')),
      );
    }
  }

  Future<void> _shareAttendanceSummary(AttendanceTrackerState state) async {
    if (state.students.isEmpty) return;

    final presentCount = state.students.where((s) => state.attendanceMap[s.id] == 'Present').length;
    final absentCount = state.students.length - presentCount;
    final date = dateTimeFormat('yMMMd', state.selectedDate);

    final message = '''
📊 *Attendance Summary*
Class: ${state.selectedClass ?? 'N/A'}
Subject: ${state.selectedSubject ?? 'N/A'}
Date: $date

✅ Present: $presentCount
❌ Absent: $absentCount
📈 Rate: ${(state.students.isEmpty ? 0 : (presentCount / state.students.length) * 100).toStringAsFixed(0)}%

Total Students: ${state.students.length}
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: message, subject: 'Attendance Summary - ${state.selectedClass}'),
      );
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    }
  }

  Widget _buildMainContent(AttendanceTrackerState state, AttendanceTrackerNotifier notifier) {
    final filteredStudents = state.students.where((student) {
      if (state.searchQuery.isEmpty) return true;
      final query = state.searchQuery.toLowerCase();
      return student.name.toLowerCase().contains(query) || 
             student.rollNo.toLowerCase().contains(query);
    }).toList();

    if (state.students.isEmpty) {
      if (state.selectedClass == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, size: 40, color: FlutterFlowTheme.of(context).primary.withAlpha(50)),
              const SizedBox(height: 12),
              Text(
                'Select Class & Subject to begin',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }
      return const Center(child: Text('No students found.', style: TextStyle(fontSize: 12)));
    }

    if (filteredStudents.isEmpty) {
      return const Center(child: Text('No matches found.', style: TextStyle(fontSize: 12)));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      itemCount: filteredStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final status = state.attendanceMap[student.id] ?? 'Present';
        return AttendanceStudentCard(
          key: ValueKey('student_${student.id}'),
          name: student.name,
          rollNo: student.rollNo,
          status: status,
          onTap: () => notifier.toggleAttendance(student.id),
        );
      },
    );
  }

  Widget _buildSearchBar(AttendanceTrackerNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(
        height: 40,
        child: AppSearchBar(
          controller: _model.searchFieldModel.inputTextController,
          hintText: 'Search students...',
          onChanged: notifier.updateSearchQuery,
          onClear: () {
            _model.searchFieldModel.inputTextController?.clear();
            notifier.updateSearchQuery('');
          },
        ),
      ),
    );
  }

  Widget _buildAlreadySubmittedWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text('Attendance already marked. Updates allowed.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AttendanceTrackerNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 8),
      child: Row(
        children: [
          Expanded(child: _buildActionButton('All Present', Icons.check_circle_rounded, FlutterFlowTheme.of(context).primary, () => notifier.setAllStatus('Present'))),
          const SizedBox(width: 12),
          Expanded(child: _buildActionButton('All Absent', Icons.cancel_rounded, AppColors.secondary, () => notifier.setAllStatus('Absent'))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(icon, color: color, size: 18), 
            const SizedBox(width: 8), 
            Text(
              label, 
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SwitchListTile.adaptive(
            dense: true,
            visualDensity: VisualDensity.compact,
            value: _sendWhatsAppAlerts,
            onChanged: (val) => setState(() => _sendWhatsAppAlerts = val),
            title: Text('WhatsApp Alerts for Absentees', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
            activeTrackColor: FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionArea(BuildContext context, AttendanceTrackerState state, AttendanceTrackerNotifier notifier) {
    final allStudentsAsync = ref.watch(studentsStreamProvider);
    
    return allStudentsAsync.when(
      data: (allStudents) {
        final dynamicClassOptions = allStudents.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList()..sort();
        
        return AttendanceSelectionSection(
          model: _model,
          classOptions: dynamicClassOptions,
          subjectOptions: state.subjectOptions,
          onClassChanged: () => notifier.setClass(_model.selectedClass),
          onDateChanged: () async {
            final picked = await showDatePicker(context: context, initialDate: state.selectedDate, firstDate: DateTime(2024), lastDate: DateTime.now());
            if (picked != null) { 
              notifier.setDate(picked);
            }
          },
          onSubjectChanged: () => notifier.setSubject(_model.selectedSubject),
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
