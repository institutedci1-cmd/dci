import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
      final s = widget.student!;
      _model.nameModel.inputTextController?.text = s.name;
      _model.studentIdModel.inputTextController?.text = s.studentId;
      _model.rollNoModel.inputTextController?.text = s.rollNo;
      _model.classModel.inputTextController?.text = s.className;
      _model.sectionModel.inputTextController?.text = s.section ?? '';
      _model.genderModel.inputTextController?.text = s.gender ?? '';
      _model.dobModel.inputTextController?.text = s.dob ?? '';
      
      _model.parentNameModel.inputTextController?.text = s.parentName ?? '';
      _model.parentPhoneModel.inputTextController?.text = s.parentPhone ?? '';
      _model.altPhoneModel.inputTextController?.text = s.altPhone ?? '';
      _model.emailModel.inputTextController?.text = s.email ?? '';
      
      _model.villageCityModel.inputTextController?.text = s.villageCity ?? '';
      _model.addressModel.inputTextController?.text = s.address ?? '';
      _model.pinCodeModel.inputTextController?.text = s.pinCode ?? '';

      _model.admissionDateModel.inputTextController?.text = s.admissionDate ?? '';
      _model.batchModel.inputTextController?.text = s.batch ?? '';
      _model.subjectsModel.inputTextController?.text = s.subjects?.join(', ') ?? '';
      _model.feesStatusModel.inputTextController?.text = s.feesStatus ?? '';
      
      _model.notesModel.inputTextController?.text = s.notes ?? '';
      _model.photoUrl = s.photoUrl;
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
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(studentRepositoryProvider);
      
      final updatedStudent = Student(
        id: widget.student?.id ?? widget.student?.studentId ?? _model.studentIdModel.inputTextController?.text ?? '',
        name: _model.nameModel.inputTextController?.text ?? '',
        studentId: _model.studentIdModel.inputTextController?.text ?? '',
        rollNo: _model.rollNoModel.inputTextController?.text ?? '',
        className: _model.classModel.inputTextController?.text ?? '',
        section: _model.sectionModel.inputTextController?.text,
        gender: _model.genderModel.inputTextController?.text,
        dob: _model.dobModel.inputTextController?.text,
        
        parentName: _model.parentNameModel.inputTextController?.text,
        parentPhone: _model.parentPhoneModel.inputTextController?.text,
        altPhone: _model.altPhoneModel.inputTextController?.text,
        email: _model.emailModel.inputTextController?.text,
        
        villageCity: _model.villageCityModel.inputTextController?.text,
        address: _model.addressModel.inputTextController?.text,
        pinCode: _model.pinCodeModel.inputTextController?.text,
        
        admissionDate: _model.admissionDateModel.inputTextController?.text,
        batch: _model.batchModel.inputTextController?.text,
        subjects: _model.subjectsModel.inputTextController?.text.split(',').map((e) => e.trim()).toList(),
        feesStatus: _model.feesStatusModel.inputTextController?.text,
        
        notes: _model.notesModel.inputTextController?.text,
        photoUrl: _model.photoUrl,
      );

      await repository.updateStudent(updatedStudent);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student saved successfully!')),
      );
      Navigator.pop(context);
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
      Navigator.pop(context);
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
                onBackPressed: () async => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (widget.student != null) _buildQuickActions(),
                      
                      _buildProfileSection(),
                      const SizedBox(height: 24),
                      
                      _buildSectionHeader('Basic Information'),
                      _buildBasicInfo(),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Parent Information'),
                      _buildParentInfo(),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Address'),
                      _buildAddressInfo(),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Academic Information'),
                      _buildAcademicInfo(),
                      
                      const SizedBox(height: 32),
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
                        const SizedBox(height: 16),
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
                      const SizedBox(height: 48),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
        const SizedBox(height: 16),
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
            const SizedBox(width: 16),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: _model.classModel,
                updateCallback: () => safeSetState(() {}),
                child: const TextFieldWidget(
                  label: 'Class',
                  hint: 'e.g. 10th',
                  variant: 'outlined',
                ),
              ),
            ),
            const SizedBox(width: 16),
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
        const SizedBox(height: 16),
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
            const SizedBox(width: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
            const SizedBox(width: 16),
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
            const SizedBox(width: 16),
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
        const SizedBox(height: 16),
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
            const SizedBox(width: 16),
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
        const SizedBox(height: 16),
        wrapWithModel(
          model: _model.subjectsModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Subjects',
            hint: 'Math, Science, etc. (Comma separated)',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 16),
        wrapWithModel(
          model: _model.feesStatusModel,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Fees Status',
            hint: 'Paid/Pending/Partial',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 16),
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
