import 'package:file_picker/file_picker.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

class EditProfileWidget extends ConsumerStatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  ConsumerState<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends ConsumerState<EditProfileWidget> {
  late EditProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  String? _currentPhotoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    try {
      final repository = ref.read(userRepositoryProvider);
      final userData = await repository.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _currentPhotoUrl = userData['photo_url'];
          _model.textFieldModel1.inputTextController?.text =
              userData['display_name'] ?? '';
          _model.textFieldModel2.inputTextController?.text =
              userData['designation'] ?? '';
          _model.textFieldModel3.inputTextController?.text =
              userData['phone_number'] ?? '';
          _model.textFieldModel4.inputTextController?.text =
              userData['qualification'] ?? '';
          _model.textFieldModel5.inputTextController?.text =
              userData['subject_expertise'] ?? '';
          _model.textFieldModel6.inputTextController?.text =
              userData['experience'] ?? '';
          _model.textFieldModel7.inputTextController?.text =
              userData['employee_id'] ?? '';
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() => _isUploading = true);
      try {
        final repository = ref.read(userRepositoryProvider);
        final file = result.files.single;
        final extension = file.extension != null ? '.${file.extension}' : '.jpg';
        final newUrl = await repository.uploadProfilePicture(file.bytes!, extension);
        
        if (newUrl != null && mounted) {
          setState(() {
            _currentPhotoUrl = newUrl;
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.updateProfile(
        displayName: _model.textFieldModel1.inputTextController?.text ?? '',
        designation: _model.textFieldModel2.inputTextController?.text ?? '',
        phoneNumber: _model.textFieldModel3.inputTextController?.text ?? '',
        qualification: _model.textFieldModel4.inputTextController?.text ?? '',
        subjectExpertise: _model.textFieldModel5.inputTextController?.text ?? '',
        experience: _model.textFieldModel6.inputTextController?.text ?? '',
        employeeId: _model.textFieldModel7.inputTextController?.text ?? '',
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Profile updated successfully!'),
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildPhotoUploadSection(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: _isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : Image.network(
                        _currentPhotoUrl ??
                            'https://dimg.dreamflow.cloud/v1/image/professional%20teacher%20portrait',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Change Profile Picture',
          style: FlutterFlowTheme.of(context).labelSmall,
        ),
      ],
    );
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
                title: 'Edit Profile',
                subtitle: 'Update your professional details',
                description: 'Keep your contact and expertise info current.',
                onBackPressed: () async => context.safePop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildPhotoUploadSection(context),
                      const SizedBox(height: 24),
                      wrapWithModel(
                        model: _model.textFieldModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Full Name',
                          hint: 'Enter your name',
                          variant: 'outlined',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Designation',
                          hint: 'e.g. Senior Physics Faculty',
                          variant: 'outlined',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel3,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Phone Number',
                          hint: 'e.g. +91 98765 43210',
                          variant: 'outlined',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel4,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Qualification',
                          hint: 'e.g. M.Sc., B.Ed.',
                          variant: 'outlined',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel5,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Subject Expertise',
                          hint: 'e.g. Mathematics, Physics',
                          variant: 'outlined',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel6,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Experience',
                          hint: 'e.g. 10 Years',
                          variant: 'outlined',
                        ),
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel7,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Employee ID',
                          hint: 'e.g. DCI-2024-001',
                          variant: 'outlined',
                        ),
                      ),
                      const SizedBox(height: 24),
                      wrapWithModel(
                        model: _model.buttonModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonWidget(
                          content: 'Save Changes',
                          variant: 'primary',
                          size: 'large',
                          fullWidth: true,
                          onPressed: _saveProfile,
                        ),
                      ),
                    ].divide(const SizedBox(height: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
