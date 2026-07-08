import '/components/shared/app_section_header.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/app_constants.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (mounted) {
      setState(() => _currentUser = userData);
    }
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
        const SnackBar(content: Text('Student ID, Name, and Class are required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(studentRepositoryProvider);
      final updatedStudent = _model.toStudent(docId, existing: widget.student);

      await repository.updateStudent(updatedStudent);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student saved successfully!')),
      );
      context.safePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteStudent() async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only Admins can delete students.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(studentRepositoryProvider);
      await repository.deleteStudent(widget.student!.id);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully.')),
      );
      context.safePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _callParent() {
    final phone = _model.parentPhoneModel.inputTextController?.text;
    if (phone != null && phone.isNotEmpty) {
      launchURL('tel:$phone');
    }
  }

  void _whatsappParent() {
    final phone = _model.parentPhoneModel.inputTextController?.text;
    if (phone != null && phone.isNotEmpty) {
      // Basic WhatsApp chat link
      launchURL('https://wa.me/$phone');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      if (widget.student != null) _buildQuickActions(),
                      
                      _buildProfileSection(),
                      const SizedBox(height: AppSpacing.xl),
                      
                      const AppSectionHeader(title: 'Basic Information', icon: Icons.person_outline_rounded),
                      _buildBasicInfo(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      const AppSectionHeader(title: 'Parent Information', icon: Icons.family_restroom_rounded),
                      _buildParentInfo(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      const AppSectionHeader(title: 'Address Details', icon: Icons.location_on_outlined),
                      _buildAddressInfo(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      const AppSectionHeader(title: 'Academic Information', icon: Icons.school_outlined),
                      _buildAcademicInfo(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      _buildActionButtons(),
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

  Widget _buildActionButtons() {
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
            loading: _isSaving,
            onPressed: _saveStudent,
          ),
        ),
        if (widget.student != null && _isAdmin) ...[
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Call Parent', Icons.call_rounded, Colors.blue, _callParent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'WhatsApp', Icons.chat_rounded, Colors.green, _whatsappParent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((0.2 * 255).toInt())),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _model.photoUrl != null && _model.photoUrl!.isNotEmpty
                      ? Image.network(_model.photoUrl!, fit: BoxFit.cover)
                      : Icon(Icons.person_rounded, size: 60, color: FlutterFlowTheme.of(context).secondaryText),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () async {
                    final url = await _showPhotoUrlDialog();
                    if (url != null) {
                      setState(() => _model.photoUrl = url);
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.student?.name ?? 'New Student',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'Student ID: ${widget.student?.studentId ?? 'TBD'}',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ],
      ),
    );
  }

  Future<String?> _showPhotoUrlDialog() async {
    String? url = _model.photoUrl;
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

  Widget _buildBasicInfo() {
    return Column(
      children: [
        wrapWithModel(
          model: _model.nameModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Full Name',
            hint: 'Enter student name',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.studentIdModel,
                updateCallback: () => safeSetState(() {}),
                child: TextFieldWidget(
                  label: 'Student ID',
                  hint: 'e.g. DCI-001',
                  variant: 'outlined',
                  readOnly: widget.student != null && !_isAdmin,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: wrapWithModel(
                model: _model.rollNoModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Roll No',
                  hint: 'e.g. 1',
                  variant: 'outlined',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Class', style: FlutterFlowTheme.of(context).labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  FlutterFlowDropDown<String>(
                    controller: _model.classDropdownController ??=
                        FormFieldController<String>(_model.selectedClass),
                    options: AppConstants.classOptions,
                    onChanged: (val) =>
                        setState(() => _model.selectedClass = val),
                    width: double.infinity,
                    height: 48.0,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium,
                    hintText: 'Select Class',
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    elevation: 2.0,
                    borderColor: FlutterFlowTheme.of(context).alternate,
                    borderWidth: 1.0,
                    borderRadius: AppRadius.md,
                    margin: const EdgeInsetsDirectional.fromSTEB(
                        12.0, 0.0, 12.0, 0.0),
                    hidesUnderline: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: wrapWithModel(
                model: _model.sectionModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Section',
                  hint: 'e.g. A',
                  variant: 'outlined',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.genderModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Gender',
                  hint: 'Male/Female',
                  variant: 'outlined',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: wrapWithModel(
                model: _model.dobModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Date of Birth',
                  hint: 'DD/MM/YYYY',
                  variant: 'outlined',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParentInfo() {
    return Column(
      children: [
        wrapWithModel(
          model: _model.parentNameModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Parent Name',
            hint: 'Father/Mother/Guardian name',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.parentPhoneModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Parent Phone',
            hint: '10-digit number',
            variant: 'outlined',
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.altPhoneModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Alternate Phone',
                  hint: 'Optional',
                  variant: 'outlined',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: wrapWithModel(
                model: _model.emailModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Email Address',
                  hint: 'Optional',
                  variant: 'outlined',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.villageCityModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Village/City',
                  hint: 'e.g. Mumbai',
                  variant: 'outlined',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: wrapWithModel(
                model: _model.pinCodeModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'PIN Code',
                  hint: 'e.g. 400001',
                  variant: 'outlined',
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.addressModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Full Address',
            hint: 'Street, House No, etc.',
            variant: 'outlined',
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.admissionDateModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Admission Date',
                  hint: 'DD/MM/YYYY',
                  variant: 'outlined',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: wrapWithModel(
                model: _model.batchModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Batch',
                  hint: 'e.g. 2024-25',
                  variant: 'outlined',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.subjectsModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Subjects',
            hint: 'Math, Science, etc. (Comma separated)',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.feesStatusModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Fees Status',
            hint: 'Paid/Pending/Partial',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: _model.notesModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Additional Notes',
            hint: 'Health issues, interests, etc.',
            variant: 'outlined',
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
