import 'package:d_c_i_teacher_app/features/homework/application/homework_assignment_notifier.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/homework_assignment/sections/homework_class_details_section.dart';
import 'package:d_c_i_teacher_app/pages/homework_assignment/sections/assignment_details_section.dart';
import 'package:d_c_i_teacher_app/pages/homework_assignment/sections/due_date_section.dart';

export 'package:d_c_i_teacher_app/pages/homework_assignment/homework_assignment_model.dart';

class HomeworkAssignmentWidget extends ConsumerStatefulWidget {
  const HomeworkAssignmentWidget({super.key});

  static String routeName = 'HomeworkAssignment';
  static String routePath = '/homeworkAssignment';

  @override
  ConsumerState<HomeworkAssignmentWidget> createState() =>
      _HomeworkAssignmentWidgetState();
}

class _HomeworkAssignmentWidgetState extends ConsumerState<HomeworkAssignmentWidget> {
  late HomeworkAssignmentModel _model;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkAssignmentModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickFile(HomeworkAssignmentNotifier notifier) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      notifier.setUploading(true);
      try {
        final file = File(result.files.single.path!);
        final storageService = ref.read(storageServiceProvider);
        final url = await storageService.uploadHomeworkAttachment(file);

        if (url != null && mounted) {
          notifier.addAttachment(url);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        notifier.setUploading(false);
      }
    }
  }

  Future<void> _saveHomework(String status, HomeworkAssignmentNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await notifier.saveHomework(
      className: _model.dropdownValue1 ?? '',
      subject: _model.dropdownValue2 ?? '',
      teacher: _model.dropdownValue3 ?? '',
      title: _model.textFieldModel1.inputTextController!.text,
      description: _model.textFieldModel2.inputTextController!.text,
      dueDate: _model.dueDate,
      status: status,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'published' ? 'Homework published.' : 'Draft saved.')));
      if (status == 'published') context.goNamed(HomeDashboardWidget.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving homework.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeworkStateAsync = ref.watch(homeworkAssignmentNotifierProvider);
    final notifier = ref.read(homeworkAssignmentNotifierProvider.notifier);

    return homeworkStateAsync.when(
      data: (state) => _buildScaffold(context, state, notifier),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildScaffold(BuildContext context, HomeworkAssignmentState state, HomeworkAssignmentNotifier notifier) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildForm(context, state, notifier),
            ),
            _buildHomeworkFooter(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return wrapWithModel(
      model: _model.headerSectionModel,
      updateCallback: () => safeSetState(() {}),
      child: HeaderSectionWidget(
        title: 'Assign Homework',
        onBackPressed: () async => context.safePop(),
        actionIcon:
            const Icon(Icons.history_rounded, color: Colors.white, size: 24.0),
        onActionPressed: () async =>
            context.pushNamed(HomeworkHistoryWidget.routeName),
      ),
    );
  }

  Widget _buildForm(BuildContext context, HomeworkAssignmentState state, HomeworkAssignmentNotifier notifier) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final subjectsAsync = ref.watch(subjectsStreamProvider);
    final allUsersAsync = ref.watch(allUsersStreamProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            Builder(builder: (context) {
              final classOptions = studentsAsync.maybeWhen(
                data: (students) => students.map((s) => s.className).where((c) => c.isNotEmpty).toSet().toList()..sort(),
                orElse: () => <String>[],
              );
              final subjectOptions = subjectsAsync.maybeWhen(
                data: (subjects) => {'English', 'Marathi', 'Math', 'Science', ...subjects}.toList()..sort(),
                orElse: () => ['English', 'Marathi', 'Math', 'Science'],
              );
              final teacherOptions = allUsersAsync.maybeWhen(
                data: (users) => users.map((u) => u.displayName).toSet().toList()..sort(),
                orElse: () => <String>[],
              );

              return HomeworkClassDetailsSection(
                model: _model,
                onChanged: () => safeSetState(() {}),
                classOptions: classOptions,
                subjectOptions: subjectOptions,
                teacherOptions: teacherOptions,
              );
            }),
            AssignmentDetailsSection(
                model: _model, onChanged: () => safeSetState(() {})),
            _buildAttachmentsSection(context, state, notifier),
            DueDateSection(model: _model, onChanged: () => safeSetState(() {})),
            _buildInfoNote(context),
          ].divide(const SizedBox(height: 12.0)),
        ),
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.info.withAlpha(30)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: AppColors.info, size: 20.0),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'This assignment will be visible to all students in the selected class immediately after submission.',
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, HomeworkAssignmentState state, HomeworkAssignmentNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (state.isUploading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              InkWell(
                onTap: () => _pickFile(notifier),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: FlutterFlowTheme.of(context).primary, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Add File',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (state.attachmentUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.attachmentUrls.map((url) => _buildFileBadge(url, notifier)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFileBadge(String url, HomeworkAssignmentNotifier notifier) {
    final fileName = url.split('%2F').last.split('?').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent4,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName.length > 15 ? '${fileName.substring(0, 12)}...' : fileName,
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              notifier.removeAttachment(url);
              ref.read(storageServiceProvider).deleteAttachment(url);
            },
            child: Icon(Icons.close_rounded,
                color: FlutterFlowTheme.of(context).error, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkFooter(BuildContext context, HomeworkAssignmentState state, HomeworkAssignmentNotifier notifier) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(top: BorderSide(color: theme.alternate)),
        boxShadow: AppShadows.low,
      ),
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          Expanded(
            child: AppPrimaryButton(
              text: 'Save Draft',
              variant: 'outline',
              isLoading: state.isSaving,
              onPressed: state.isSaving ? null : () => _saveHomework('draft', notifier),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppPrimaryButton(
              text: 'Publish',
              isLoading: state.isSaving,
              onPressed: state.isSaving ? null : () => _saveHomework('published', notifier),
            ),
          ),
        ],
      ),
    );
  }
}
