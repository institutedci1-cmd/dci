import 'package:d_c_i_teacher_app/features/student/application/edit_student_notifier.dart';
import 'package:d_c_i_teacher_app/components/shared/app_section_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Sections
import 'package:d_c_i_teacher_app/pages/edit_student/sections/basic_info_section.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/sections/parent_info_section.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/sections/address_info_section.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/sections/academic_info_section.dart';

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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditStudentModel());
    
    if (widget.student != null) {
      _model.setFromStudent(widget.student!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editStudentNotifierProvider.notifier).initialize().then((_) {
        if (widget.student != null) {
          ref.read(editStudentNotifierProvider.notifier).setPhotoUrl(widget.student!.photoUrl);
        }
      });
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    final notifier = ref.read(editStudentNotifierProvider.notifier);
    
    final name = _model.nameModel.inputTextController?.text.trim() ?? '';
    if (name.isEmpty || _model.selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Class are required.')),
      );
      return;
    }

    final student = _model.toStudent(widget.student?.id ?? '', existing: widget.student);
    final success = await notifier.saveStudent(student, isNew: widget.student == null);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student saved successfully!')));
      context.safePop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save student.')));
    }
  }

  Future<void> _deleteStudent() async {
    final notifier = ref.read(editStudentNotifierProvider.notifier);
    if (!notifier.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only Admins can delete students.')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: FlutterFlowTheme.of(context).error))),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await notifier.deleteStudent(widget.student!.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted successfully.')));
      context.safePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final state = ref.watch(editStudentNotifierProvider);
    final isAdmin = state.currentUser?.role == 'Admin';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            wrapWithModel(
              model: _model.headerSectionModel,
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: widget.student == null ? 'Add Student' : 'Student Details',
                subtitle: widget.student?.name ?? 'New Entry',
                onBackPressed: () async => context.safePop(),
              ),
            ),
            Expanded(
              child: state.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          if (widget.student != null) _buildQuickActions(theme),
                          
                          _buildProfileSection(state, theme),
                          const SizedBox(height: AppSpacing.lg),
                          
                          const AppSectionHeader(title: 'Basic Information', icon: Icons.person_outline_rounded),
                          BasicInfoSection(model: _model, isAdmin: isAdmin, onChanged: () => safeSetState(() {})),
                          
                          const SizedBox(height: AppSpacing.lg),
                          const AppSectionHeader(title: 'Parent Information', icon: Icons.family_restroom_rounded),
                          ParentInfoSection(model: _model, onChanged: () => safeSetState(() {})),
                          
                          const SizedBox(height: AppSpacing.lg),
                          const AppSectionHeader(title: 'Address Details', icon: Icons.location_on_outlined),
                          AddressInfoSection(model: _model, onChanged: () => safeSetState(() {})),
                          
                          const SizedBox(height: AppSpacing.lg),
                          const AppSectionHeader(title: 'Academic Information', icon: Icons.school_outlined),
                          AcademicInfoSection(model: _model, onChanged: () => safeSetState(() {})),
                          
                          const SizedBox(height: AppSpacing.xl),
                          _buildActionButtons(state, isAdmin),
                          const SizedBox(height: AppSpacing.xl),
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

  Widget _buildActionButtons(EditStudentState state, bool isAdmin) {
    return Column(
      children: [
        wrapWithModel(
          model: _model.saveButtonModel,
          updateCallback: () => safeSetState(() {}),
          child: ButtonWidget(
            content: widget.student == null ? 'Add Student' : 'Save Changes',
            variant: 'primary',
            size: 'large',
            fullWidth: true,
            loading: state.isSaving,
            onPressed: _saveStudent,
          ),
        ),
        if (widget.student != null && isAdmin) ...[
          const SizedBox(height: AppSpacing.md),
          wrapWithModel(
            model: _model.deleteButtonModel,
            updateCallback: () => safeSetState(() {}),
            child: ButtonWidget(
              content: 'Delete Student',
              variant: 'outline',
              size: 'large',
              fullWidth: true,
              onPressed: _deleteStudent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions(FlutterFlowTheme theme) {
    final phone = _model.parentPhoneModel.inputTextController?.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Call Parent', Icons.call_rounded, theme.primary, 
              () => phone != null && phone.isNotEmpty ? launchURL('tel:$phone') : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'WhatsApp', Icons.chat_rounded, theme.success, 
              () => phone != null && phone.isNotEmpty ? launchURL('https://wa.me/$phone') : null,
            ),
          ),
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
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(EditStudentState state, FlutterFlowTheme theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primary, width: 2),
                  boxShadow: AppShadows.low,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(55),
                    child: state.photoUrl != null && state.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: state.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.person, size: 60),
                          )
                        : Icon(Icons.person_rounded, size: 60, color: theme.secondaryText),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    final url = await _showPhotoUrlDialog(state.photoUrl);
                    if (url != null) {
                      ref.read(editStudentNotifierProvider.notifier).setPhotoUrl(url);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.student?.name ?? 'New Student',
            style: AppTypography.title.copyWith(fontSize: 22),
          ),
          Text(
            'Student ID: ${widget.student?.studentId ?? 'TBD'}',
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPhotoUrlDialog(String? currentUrl) async {
    String? url = currentUrl;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Student Photo URL'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Enter photo URL'),
          onChanged: (val) => url = val,
          controller: TextEditingController(text: url),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, url), child: const Text('OK')),
        ],
      ),
    );
  }
}
