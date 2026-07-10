import '/components/shared/app_section_header.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/app_constants.dart';
import '/components/shared/app_button.dart';
import '/components/shared/app_text_field.dart';
import '/components/shared/app_dropdown.dart';
import '/components/shared/app_card.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_student_model.dart';

export 'edit_student_model.dart';

class EditStudentWidget extends ConsumerStatefulWidget {
  const EditStudentWidget({
    super.key,
    this.student,
  });

  final Student? student;

  static String routeName = 'EditStudent';
  static String routePath = '/editStudent';

  @override
  ConsumerState<EditStudentWidget> createState() => _EditStudentWidgetState();
}

class _EditStudentWidgetState extends ConsumerState<EditStudentWidget> {
  late EditStudentModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditStudentModel());
    _loadUserData();

    if (widget.student != null) {
      _model.setFromStudent(widget.student!);
    }
  }

  Future<void> _loadUserData() async {
    final userData = await ref.read(userRepositoryProvider).getUserData();
    if (mounted) setState(() => _currentUser = userData);
  }

  bool get _isAdmin => _currentUser?['role'] == 'Admin';

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    final docId = widget.student?.id ?? _model.studentIdModel.inputTextController?.text.trim() ?? '';
    final name = _model.nameModel.inputTextController?.text.trim() ?? '';
    
    if (docId.isEmpty || name.isEmpty || _model.selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing required fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedStudent = _model.toStudent(docId, existing: widget.student);
      await ref.read(studentRepositoryProvider).updateStudent(updatedStudent);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(widget.student == null ? 'Student added successfully!' : 'Student details updated!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.safePop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
          actions: [
            if (widget.student != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: _handleDelete,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPhotoHeader(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(title: 'Basic Info'),
              const SizedBox(height: AppSpacing.md),
              _buildBasicInfoForm(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(title: 'Parent & Contact'),
              const SizedBox(height: AppSpacing.md),
              _buildContactForm(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(title: 'Academic & Other'),
              const SizedBox(height: AppSpacing.md),
              _buildAcademicForm(),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: widget.student == null ? 'Create Student' : 'Save Changes',
                isLoading: _isSaving,
                onPressed: _saveStudent,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoHeader() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: _model.photoUrl != null && _model.photoUrl!.isNotEmpty
                  ? Image.network(_model.photoUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.person_rounded, size: 50, color: AppColors.textTertiary),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _updatePhoto,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent,
                child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            label: 'Full Name',
            controller: _model.nameModel.inputTextController,
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Student ID',
                  controller: _model.studentIdModel.inputTextController,
                  readOnly: widget.student != null && !_isAdmin,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Roll No',
                  controller: _model.rollNoModel.inputTextController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown(
            label: 'Class',
            hintText: 'Select Class',
            options: AppConstants.classOptions,
            value: _model.selectedClass,
            onChanged: (val) => setState(() => _model.selectedClass = val),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            label: 'Parent Name',
            controller: _model.parentNameModel.inputTextController,
            prefixIcon: Icons.family_restroom_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Parent Phone',
            controller: _model.parentPhoneModel.inputTextController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Email (Optional)',
            controller: _model.emailModel.inputTextController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicForm() {
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            label: 'Subjects',
            hintText: 'e.g. Math, Science',
            controller: _model.subjectsModel.inputTextController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Fees Status',
            controller: _model.feesStatusModel.inputTextController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Notes',
            controller: _model.notesModel.inputTextController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhoto() async {
    // Basic URL entry for now
    String? url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Photo'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Enter image URL'),
          controller: TextEditingController(text: _model.photoUrl),
          onSubmitted: (val) => Navigator.pop(context, val),
        ),
      ),
    );
    if (url != null) setState(() => _model.photoUrl = url);
  }

  Future<void> _handleDelete() async {
    if (!_isAdmin) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    ) ?? false;
    if (confirm) {
      await ref.read(studentRepositoryProvider).deleteStudent(widget.student!.id);
      if (mounted) context.safePop();
    }
  }
}
