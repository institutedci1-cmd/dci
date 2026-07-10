import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/backend/providers/attendance_tracker_provider.dart';
import '/backend/providers/repository_providers.dart';
import '/components/shared/app_button.dart';
import '/components/shared/app_card.dart';
import '/components/shared/app_search_bar.dart';
import '/components/shared/attendance_student_card.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared/app_colors.dart';
import '/shared/app_style.dart';
import 'sections/attendance_selection_section.dart';
import 'sections/attendance_summary_footer.dart';

export 'attendance_tracker_model.dart';

class AttendanceTrackerWidget extends ConsumerStatefulWidget {
  const AttendanceTrackerWidget({super.key});

  static String routeName = 'AttendanceTracker';
  static String routePath = '/attendanceTracker';

  @override
  ConsumerState<AttendanceTrackerWidget> createState() => _AttendanceTrackerWidgetState();
}

class _AttendanceTrackerWidgetState extends ConsumerState<AttendanceTrackerWidget> {
  late AttendanceTrackerModel _model;
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
    final trackerState = ref.watch(attendanceTrackerProvider);
    final trackerNotifier = ref.read(attendanceTrackerProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    int presentCount = trackerState.allStudents.where((s) => trackerState.attendanceMap[s.studentId] == 'Present').length;
    int absentCount = trackerState.allStudents.length - presentCount;
    double percentage = trackerState.allStudents.isEmpty ? 0 : (presentCount / trackerState.allStudents.length) * 100;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Mark Attendance', style: AppTypography.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.safePop(),
          ),
        ),
        bottomNavigationBar: trackerState.allStudents.isNotEmpty
            ? AttendanceSummaryFooter(
                presentCount: presentCount,
                absentCount: absentCount,
                percentage: percentage,
                isLoading: trackerState.isLoading || _model.isSaving,
                isAlreadySubmitted: _model.isAlreadySubmitted,
                onSubmit: () => _saveAttendance(trackerState),
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
                  onDateChanged: _pickDate,
                  onClassChanged: (val) {
                    setState(() {
                      _model.selectedClass = val;
                      _checkIfAlreadySubmitted();
                    });
                  },
                  onSubjectChanged: (_) => _checkIfAlreadySubmitted(),
                  onFetchStudents: () {
                    if (_model.selectedClass != null) {
                      trackerNotifier.loadStudents(_model.selectedClass!);
                      _checkIfAlreadySubmitted();
                    }
                  },
                  isLoading: trackerState.isLoading,
                ),
                if (trackerState.allStudents.isNotEmpty) ...[
                  if (_model.isAlreadySubmitted) _buildAlreadySubmittedWarning(),
                  _buildSearchAndActions(trackerState, trackerNotifier),
                  Expanded(
                    child: _buildStudentDisplay(trackerState, trackerNotifier, isDesktop),
                  ),
                  _buildWhatsAppToggle(),
                ] else if (!trackerState.isLoading) ...[
                  const Spacer(),
                  if (trackerState.errorMessage != null)
                    _buildErrorDisplay(trackerState.errorMessage!)
                  else
                    _buildInitialPrompt(),
                  const Spacer(),
                ] else ...[
                  const Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudentDisplay(AttendanceTrackerState state, AttendanceTrackerNotifier notifier, bool isDesktop) {
    if (isDesktop) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3.5,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: state.filteredStudents.length,
        itemBuilder: (context, index) => _buildStudentCard(state, notifier, index),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: state.filteredStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) => _buildStudentCard(state, notifier, index),
    );
  }

  Widget _buildStudentCard(AttendanceTrackerState state, AttendanceTrackerNotifier notifier, int index) {
    final student = state.filteredStudents[index];
    final status = state.attendanceMap[student.studentId] ?? 'Present';

    return AttendanceStudentCard(
      name: student.name,
      rollNo: student.rollNo,
      status: status,
      onTap: () {
        HapticFeedback.lightImpact();
        notifier.toggleAttendance(student.studentId);
      },
    );
  }

  Widget _buildInitialPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.assignment_ind_outlined, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text(
          'Fill details and load students\nto start marking attendance.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 16),
        Text(
          error,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ],
    );
  }

  Widget _buildAlreadySubmittedWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Attendance already exists for this class/subject today. Submitting will update existing records.',
              style: AppTypography.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions(AttendanceTrackerState state, AttendanceTrackerNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          AppSearchBar(
            controller: _model.searchFieldModel.inputTextController,
            hintText: 'Search student...',
            onChanged: (val) => notifier.updateSearch(val),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildBulkMarkButton('All Present', Icons.check_circle_outline_rounded, 'Present', notifier),
              const SizedBox(width: AppSpacing.sm),
              _buildBulkMarkButton('All Absent', Icons.cancel_outlined, 'Absent', notifier),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkMarkButton(String text, IconData icon, String status, AttendanceTrackerNotifier notifier) {
    return Expanded(
      child: AppButton(
        text: text,
        variant: AppButtonVariant.outline,
        icon: icon,
        onPressed: () {
          HapticFeedback.mediumImpact();
          notifier.bulkMark(status);
        },
        height: 36,
      ),
    );
  }

  Widget _buildWhatsAppToggle() {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      padding: EdgeInsets.zero,
      child: SwitchListTile.adaptive(
        visualDensity: VisualDensity.compact,
        value: _model.sendWhatsAppAlerts,
        onChanged: (val) => setState(() => _model.sendWhatsAppAlerts = val),
        title: Text('WhatsApp Alerts', style: AppTypography.bodyMedium),
        subtitle: Text('Notify parents of absences', style: AppTypography.caption),
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _model.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _model.selectedDate = picked;
        _checkIfAlreadySubmitted();
      });
    }
  }

  Future<void> _checkIfAlreadySubmitted() async {
    final subjectText = _model.subjectFieldModel.inputTextController?.text.trim() ?? '';
    if (_model.selectedClass != null && _model.selectedDate != null && subjectText.isNotEmpty) {
      try {
        final exists = await ref.read(attendanceRepositoryProvider).checkAttendanceExists(
              _model.selectedClass!,
              subjectText,
              _model.selectedDate!,
            );
        if (mounted) {
          setState(() => _model.isAlreadySubmitted = exists);
        }
      } catch (_) {}
    } else {
      if (mounted) {
        setState(() => _model.isAlreadySubmitted = false);
      }
    }
  }

  Future<void> _saveAttendance(AttendanceTrackerState trackerState) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final subjectText = _model.subjectFieldModel.inputTextController?.text.trim() ?? '';
    if (_model.selectedClass == null || _model.selectedDate == null || subjectText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missing details.')));
      return;
    }

    setState(() => _model.isSaving = true);
    try {
      final attendanceList = trackerState.allStudents.map((s) {
        return StudentAttendance(
          id: '',
          studentId: s.studentId,
          studentName: s.name,
          className: _model.selectedClass!,
          subject: subjectText,
          status: trackerState.attendanceMap[s.studentId] ?? 'Present',
          date: _model.selectedDate!,
          markedBy: user.uid,
        );
      }).toList();

      await ref.read(attendanceRepositoryProvider).recordStudentAttendance(attendanceList);

      if (_model.sendWhatsAppAlerts) {
        final absentStudents = trackerState.allStudents
            .where((s) => trackerState.attendanceMap[s.studentId] == 'Absent')
            .toList();

        if (absentStudents.isNotEmpty) {
          final whatsappService = ref.read(whatsappServiceProvider);
          for (var s in absentStudents) {
            if (s.parentPhone != null && s.parentPhone!.isNotEmpty) {
              await whatsappService.sendTemplateMessage(
                to: s.parentPhone!,
                templateName: 'student_absence_alert',
                parameters: [s.name, subjectText, dateTimeFormat('yMMMd', _model.selectedDate)],
              );
            }
          }
        }
      }

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Attendance recorded successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.goNamed(AttendanceDashboardWidget.routeName);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _model.isSaving = false);
      }
    }
  }
}
