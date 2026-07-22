import 'package:d_c_i_teacher_app/features/exams/application/marks_entry_notifier.dart';
import 'package:d_c_i_teacher_app/backend/models/exam.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enter_marks_model.dart';

class EnterMarksWidget extends ConsumerStatefulWidget {
  const EnterMarksWidget({super.key, required this.exam});

  final Exam exam;

  static String routeName = 'EnterMarks';
  static String routePath = '/enterMarks';

  @override
  ConsumerState<EnterMarksWidget> createState() => _EnterMarksWidgetState();
}

class _EnterMarksWidgetState extends ConsumerState<EnterMarksWidget> {
  late EnterMarksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EnterMarksModel());
    _model.searchController ??= TextEditingController();
    
    // Pre-fill existing results if any
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final existingResults = await ref.read(resultRepositoryProvider).getExamResultsStream(widget.exam.id).first;
      for (var result in existingResults) {
        _model.getMarksController(result.studentId).text = result.marksObtained.toString();
        _model.getRemarksController(result.studentId).text = result.remarks;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveResults(List<Student> students, MarksEntryNotifier notifier) async {
    final entries = students.map((s) {
      final marksText = _model.getMarksController(s.id).text;
      final marks = double.tryParse(marksText) ?? 0.0;
      return (
        studentId: s.id,
        studentName: s.name,
        className: s.className,
        marks: marks,
        remarks: _model.getRemarksController(s.id).text,
      );
    }).where((e) => _model.getMarksController(e.studentId).text.isNotEmpty).toList();

    if (entries.isEmpty) return;

    final success = await notifier.saveResults(
      examId: widget.exam.id,
      subject: widget.exam.subject,
      totalMarks: widget.exam.totalMarks,
      passingMarks: widget.exam.passingMarks,
      entries: entries,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks saved successfully!')));
      context.safePop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving marks.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final studentsAsync = ref.watch(studentsStreamProvider);
    final marksEntryStateAsync = ref.watch(marksEntryNotifierProvider);
    final marksEntryNotifier = ref.read(marksEntryNotifierProvider.notifier);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Enter Marks',
            subtitle: '${widget.exam.subject} - ${widget.exam.className}',
            description: 'Enter student marks for ${widget.exam.subject} examination.',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: studentsAsync.when(
              data: (allStudents) {
                final classStudents = allStudents.where((s) => s.className == widget.exam.className).toList();
                if (classStudents.isEmpty) {
                  return const Center(child: Text('No students found for this class.'));
                }

                final filteredStudents = classStudents.where((s) {
                  final query = _searchQuery.toLowerCase();
                  return s.name.toLowerCase().contains(query) || s.rollNo.toLowerCase().contains(query);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: AppSearchBar(
                        controller: _model.searchController,
                        hintText: 'Search student...',
                        onChanged: (val) => setState(() => _searchQuery = val),
                        onClear: () => setState(() {
                          _model.searchController?.clear();
                          _searchQuery = '';
                        }),
                      ),
                    ),
                    Expanded(
                      child: filteredStudents.isEmpty
                          ? const Center(child: Text('No matching students found.'))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredStudents.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: theme.alternate),
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(student.name, 
                                              style: AppTypography.label.copyWith(
                                                fontWeight: FontWeight.bold, 
                                                fontSize: 14,
                                                color: AppColors.textPrimary
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text('Roll: ${student.rollNo}', style: AppTypography.caption.copyWith(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: TextFieldWidget(
                                          controller: _model.getMarksController(student.id),
                                          hint: '/${widget.exam.totalMarks}',
                                          labelPresent: false,
                                          variant: 'outlined',
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: TextFieldWidget(
                                          controller: _model.getRemarksController(student.id),
                                          hint: 'Remarks',
                                          labelPresent: false,
                                          variant: 'outlined',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: marksEntryStateAsync.when(
                        data: (state) => AppPrimaryButton(
                          text: state.isSaving ? 'Saving...' : 'Save All Results',
                          height: 44,
                          isLoading: state.isSaving,
                          onPressed: state.isSaving ? null : () => _saveResults(classStudents, marksEntryNotifier),
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (err, _) => Text('Error: $err'),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading students: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
