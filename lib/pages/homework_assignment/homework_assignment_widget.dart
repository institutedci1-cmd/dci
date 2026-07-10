import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../backend/models/homework.dart';
import '../../backend/providers/repository_providers.dart';
import '../../shared/app_style.dart';
import '../../shared/app_colors.dart';
import '../../components/shared/app_button.dart';
import '../../components/shared/app_section_header.dart';
import '../../components/shared/app_card.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../index.dart';
import 'sections/homework_class_details_section.dart';
import 'sections/assignment_details_section.dart';
import 'sections/due_date_section.dart';

export 'homework_assignment_model.dart';

class HomeworkAssignmentWidget extends ConsumerStatefulWidget {
  const HomeworkAssignmentWidget({super.key, this.initialHomework});

  final Homework? initialHomework;

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeworkAssignmentModel());
    
    // Prefill data if in edit mode
    if (widget.initialHomework != null) {
      _model.dropdownValue1 = widget.initialHomework!.className;
      _model.dropdownValue2 = widget.initialHomework!.subject;
      _model.dropdownValue3 = widget.initialHomework!.teacherName;
      _model.textFieldModel1.inputTextController?.text = widget.initialHomework!.chapter;
      _model.textFieldModel2.inputTextController?.text = widget.initialHomework!.homework;
      _model.dueDate = widget.initialHomework!.assignedDate;
      _model.attachmentUrls = List.from(widget.initialHomework!.attachments);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialHomework != null && widget.initialHomework!.id.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Homework' : 'Assign Homework'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.safePop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionHeader(title: 'Class Selection'),
                const SizedBox(height: AppSpacing.sm),
                HomeworkClassDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                const SizedBox(height: AppSpacing.lg),
                const AppSectionHeader(title: 'Assignment Content'),
                const SizedBox(height: AppSpacing.sm),
                AssignmentDetailsSection(model: _model, onChanged: () => safeSetState(() {})),
                const SizedBox(height: AppSpacing.lg),
                const AppSectionHeader(title: 'Deadline & Files'),
                const SizedBox(height: AppSpacing.sm),
                DueDateSection(model: _model, onChanged: () => safeSetState(() {})),
                const SizedBox(height: AppSpacing.sm),
                _buildAttachmentsSection(),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: isEdit ? 'Update Assignment' : 'Publish Assignment',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
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
              Text(
                'Attachments (Optional)',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Add File'),
                onPressed: _model.isDataUploading ? null : _pickFile,
              ),
            ],
          ),
          if (_model.isDataUploading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Uploading...', style: AppTypography.caption),
                  ],
                ),
              ),
            ),
          if (_model.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName.length > 12 ? '${fileName.substring(0, 9)}...' : fileName,
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              setState(() => _model.attachmentUrls.remove(url));
              // In production, also delete from storage
            },
            child: const Icon(Icons.close_rounded, color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => _model.isDataUploading = true);
      try {
        final file = result.files.single;
        final extension = file.extension != null ? '.${file.extension}' : '';
        final url = await ref.read(storageServiceProvider).uploadHomeworkAttachment(
              bytes: file.bytes!,
              extension: extension,
            );
        if (url != null) {
          setState(() => _model.attachmentUrls.add(url));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File attached successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          throw Exception('Failed to get download URL');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _model.isDataUploading = false);
        }
      }
    }
  }

  Future<void> _handleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final homework = Homework(
        id: widget.initialHomework?.id ?? '',
        teacherId: user.uid,
        teacherName: _model.dropdownValue3 ?? user.displayName ?? 'Teacher',
        className: _model.dropdownValue1 ?? '',
        subject: _model.dropdownValue2 ?? '',
        chapter: _model.textFieldModel1.inputTextController!.text.trim(),
        homework: _model.textFieldModel2.inputTextController!.text.trim(),
        remarks: '',
        assignedDate: _model.dueDate ?? DateTime.now(),
        attachments: _model.attachmentUrls,
      );

      final repository = ref.read(homeworkRepositoryProvider);
      if (homework.id.isEmpty) {
        await repository.addHomework(homework);
      } else {
        await repository.updateHomework(homework);
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Homework published successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.goNamed(HomeworkHistoryWidget.routeName);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
