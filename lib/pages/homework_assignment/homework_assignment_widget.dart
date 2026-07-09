import '/backend/models/homework_assignment.dart';
import '/backend/providers/repository_providers.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/components/shared/app_button.dart';
import '/components/shared/app_section_header.dart';
import '/components/shared/app_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sections/homework_class_details_section.dart';
import 'sections/assignment_details_section.dart';
import 'sections/due_date_section.dart';

export 'homework_assignment_model.dart';

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
    _model.textFieldModel1.inputTextController ??= TextEditingController();
    _model.textFieldModel2.inputTextController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Assign Homework'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => context.pushNamed(HomeworkHistoryWidget.routeName),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionHeader(title: 'Class Selection'),
                const SizedBox(height: AppSpacing.md),
                HomeworkClassDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                const SizedBox(height: AppSpacing.xl),
                const AppSectionHeader(title: 'Assignment Content'),
                const SizedBox(height: AppSpacing.md),
                AssignmentDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                const SizedBox(height: AppSpacing.xl),
                const AppSectionHeader(title: 'Deadline & Files'),
                const SizedBox(height: AppSpacing.md),
                DueDateSection(model: _model, onChanged: () => safeSetState(() {})),
                const SizedBox(height: AppSpacing.md),
                _buildAttachmentsSection(),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Save Draft',
                        variant: AppButtonVariant.outline,
                        onPressed: () => _saveHomework('draft'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        text: 'Publish',
                        onPressed: () => _saveHomework('published'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attachments', style: Theme.of(context).textTheme.labelLarge),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Add File'),
                onPressed: _pickFile,
              ),
            ],
          ),
          if (_model.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _model.attachmentUrls.map((url) => _buildFileBadge(url)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileBadge(String url) {
    final fileName = url.split('%2F').last.split('?').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName.length > 15 ? '${fileName.substring(0, 12)}...' : fileName,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() => _model.attachmentUrls.remove(url));
              ref.read(storageServiceProvider).deleteAttachment(url);
            },
            child: const Icon(Icons.close_rounded, color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() => _model.isDataUploading = true);
      try {
        final url = await ref.read(storageServiceProvider).uploadHomeworkAttachment(File(result.files.single.path!));
        if (url != null) setState(() => _model.attachmentUrls.add(url));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      } finally {
        if (mounted) setState(() => _model.isDataUploading = false);
      }
    }
  }

  Future<void> _saveHomework(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_formKey.currentState!.validate()) return;

    try {
      final assignment = HomeworkAssignment(
        id: '',
        className: _model.dropdownValue1 ?? '',
        subject: _model.dropdownValue2 ?? '',
        teacher: _model.dropdownValue3 ?? '',
        title: _model.textFieldModel1.inputTextController!.text,
        description: _model.textFieldModel2.inputTextController!.text,
        dueDate: _model.dueDate != null ? dateTimeFormat('yMMMd', _model.dueDate) : 'No Due Date',
        status: status,
        attachments: _model.attachmentUrls,
        createdBy: user.uid,
        createdByEmail: user.email ?? '',
      );

      await ref.read(homeworkRepositoryProvider).saveHomework(assignment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'published' ? 'Homework published.' : 'Draft saved.')));
      if (status == 'published') context.goNamed(HomeDashboardWidget.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
