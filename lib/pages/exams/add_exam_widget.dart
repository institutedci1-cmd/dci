import 'package:d_c_i_teacher_app/auth/firebase_auth/auth_util.dart';
import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/exams/add_exam_model.dart';

class AddExamWidget extends ConsumerStatefulWidget {
  const AddExamWidget({super.key});

  static String routeName = 'AddExam';
  static String routePath = '/addExam';

  @override
  ConsumerState<AddExamWidget> createState() => _AddExamWidgetState();
}

class _AddExamWidgetState extends ConsumerState<AddExamWidget> {
  late AddExamModel _model;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddExamModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate() || _model.selectedClass == null || _model.selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final exam = Exam(
        id: '',
        className: _model.selectedClass!,
        subject: _model.selectedSubject!,
        date: _model.selectedDate!,
        startTime: _model.startTime!.format(context),
        endTime: _model.endTime!.format(context),
        totalMarks: int.tryParse(_model.totalMarksModel.inputTextController?.text ?? '100') ?? 100,
        passingMarks: int.tryParse(_model.passingMarksModel.inputTextController?.text ?? '35') ?? 35,
        venue: _model.venueModel.inputTextController?.text ?? '',
        description: _model.descriptionModel.inputTextController?.text ?? '',
        createdBy: currentUserUid,
      );

      await ref.read(examServiceProvider).scheduleExam(exam);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam scheduled successfully!')));
        context.safePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: Column(
          children: [
            wrapWithModel(
              model: _model.headerSectionModel,
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Schedule Exam',
                subtitle: 'Add new test or examination',
                onBackPressed: () async => context.safePop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.pagePadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Class and Subject
                      ResponsiveUtils.responsiveRow(context, [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text('Class', style: AppTypography.label.copyWith(color: theme.secondaryText)),
                            ),
                            studentsAsync.when(
                              data: (students) {
                                final options = students
                                    .map((s) => s.className)
                                    .where((c) => c.isNotEmpty)
                                    .toSet()
                                    .toList()..sort();
                                
                                return DropDownWidget(
                                  label: 'Class',
                                  labelPresent: false,
                                  controller: _model.classDropdownController!,
                                  options: options.isEmpty ? ['No Classes'] : options,
                                  onChanged: (val) => setState(() => _model.selectedClass = val),
                                  height: 48.0,
                                  hint: 'Select...',
                                );
                              },
                              loading: () => const SizedBox(
                                height: 48.0,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              error: (_, __) => const Text('Error', style: TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 6),
                              child: Text('Subject', style: AppTypography.label.copyWith(color: theme.secondaryText)),
                            ),
                            subjectsAsync.when(
                              data: (subjects) {
                                final options = {
                                  'English', 'Marathi', 'Math', 'Science',
                                  ...subjects,
                                }.toList()..sort();

                                return DropDownWidget(
                                  label: 'Subject',
                                  labelPresent: false,
                                  controller: _model.subjectDropdownController!,
                                  options: options,
                                  onChanged: (val) => setState(() => _model.selectedSubject = val),
                                  height: 48.0,
                                  hint: 'Select...',
                                );
                              },
                              loading: () => const SizedBox(
                                height: 48.0,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              error: (_, __) => const Text('Error', style: TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.lg),
                      // Date Picker
                      _buildSelectorTile(
                        context,
                        label: 'Exam Date',
                        value: dateTimeFormat('yMMMd', _model.selectedDate),
                        icon: Icons.calendar_today_rounded,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _model.selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _model.selectedDate = picked);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Time Pickers
                      ResponsiveUtils.responsiveRow(context, [
                        _buildSelectorTile(
                          context,
                          label: 'Start Time',
                          value: _model.startTime!.format(context),
                          icon: Icons.access_time_rounded,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _model.startTime!);
                            if (picked != null) setState(() => _model.startTime = picked);
                          },
                        ),
                        _buildSelectorTile(
                          context,
                          label: 'End Time',
                          value: _model.endTime!.format(context),
                          icon: Icons.access_time_filled_rounded,
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _model.endTime!);
                            if (picked != null) setState(() => _model.endTime = picked);
                          },
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.lg),
                      // Marks
                      ResponsiveUtils.responsiveRow(context, [
                        wrapWithModel(
                          model: _model.totalMarksModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const TextFieldWidget(
                            label: 'Total Marks',
                            hint: '100',
                            keyboardType: TextInputType.number,
                            variant: 'outlined',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.passingMarksModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const TextFieldWidget(
                            label: 'Passing Marks',
                            hint: '35',
                            keyboardType: TextInputType.number,
                            variant: 'outlined',
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.lg),
                      // Venue
                      wrapWithModel(
                        model: _model.venueModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Venue',
                          hint: 'Examination Hall A',
                          variant: 'outlined',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Description
                      wrapWithModel(
                        model: _model.descriptionModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Description / Instructions',
                          hint: 'Students must bring their own stationery...',
                          maxLines: 4,
                          variant: 'outlined',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Save Button
                      AppPrimaryButton(
                        text: 'Schedule Exam',
                        isLoading: _isSaving,
                        onPressed: _saveExam,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTile(BuildContext context, {required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.alternate, width: 1.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.label.copyWith(color: theme.secondaryText, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primary, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
