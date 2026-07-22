import 'package:d_c_i_teacher_app/auth/firebase_auth/auth_util.dart';
import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/backend/models/teacher.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/edit_profile/edit_profile_model.dart';
export 'package:d_c_i_teacher_app/pages/edit_profile/edit_profile_model.dart';

class EditProfileWidget extends ConsumerStatefulWidget {
  const EditProfileWidget({
    super.key,
    this.userToEdit,
  });

  final Teacher? userToEdit;

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
      final currentUser = await ref.read(userRepositoryProvider).getUserData();
      final isAdmin = currentUser?.role == 'Admin' || currentUser?.role == 'Director';

      if (!isAdmin && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access Denied: Only Admins can edit profiles.')),
        );
        context.safePop();
        return;
      }

      Teacher? userData = widget.userToEdit ?? currentUser;

      if (userData != null && mounted) {
        setState(() {
          _currentPhotoUrl = userData.photoUrl;
          _model.textFieldModel1.inputTextController?.text =
              userData.displayName;
          _model.textFieldModel2.inputTextController?.text =
              userData.designation;
          _model.textFieldModel3.inputTextController?.text =
              userData.phoneNumber;
          _model.textFieldModel4.inputTextController?.text =
              userData.qualification ?? '';
          _model.textFieldModel5.inputTextController?.text =
              userData.subjectExpertise ?? '';
          _model.textFieldModel6.inputTextController?.text =
              userData.experience ?? '';
          _model.textFieldModel7.inputTextController?.text =
              userData.employeeId ?? '';
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      try {
        final service = ref.read(teacherServiceProvider);
        final file = File(result.files.single.path!);
        
        await service.updateProfilePicture(
          file, 
          targetUid: widget.userToEdit?.uid,
        );

        // Fetch the updated user data to get the new URL
        final updatedUser = await ref.read(userRepositoryProvider).getUserDataById(widget.userToEdit?.uid ?? currentUserUid);

        if (mounted) {
          setState(() {
            _currentPhotoUrl = updatedUser?.photoUrl;
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
      final service = ref.read(teacherServiceProvider);
      
      Teacher? currentData = widget.userToEdit;
      currentData ??= await repository.getUserData();
      
      if (currentData == null) throw Exception('User data not found');

      final updatedTeacher = currentData.copyWith(
        displayName: _model.textFieldModel1.inputTextController?.text ?? '',
        photoUrl: _currentPhotoUrl ?? currentData.photoUrl,
        designation: _model.textFieldModel2.inputTextController?.text ?? '',
        phoneNumber: _model.textFieldModel3.inputTextController?.text ?? '',
        qualification: _model.textFieldModel4.inputTextController?.text,
        subjectExpertise: _model.textFieldModel5.inputTextController?.text,
        experience: _model.textFieldModel6.inputTextController?.text,
        employeeId: _model.textFieldModel7.inputTextController?.text,
      );

      await service.updateTeacher(updatedTeacher);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      context.safePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
                    : CachedNetworkImage(
                        imageUrl: _currentPhotoUrl ??
                            'https://dimg.dreamflow.cloud/v1/image/professional%20teacher%20portrait',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.person, size: 50),
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
                padding: AppSpacing.pagePadding,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      _buildPhotoUploadSection(context),
                      const SizedBox(height: AppSpacing.xl),
                      wrapWithModel(
                        model: _model.textFieldModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: const TextFieldWidget(
                          label: 'Full Name',
                          hint: 'Enter your name',
                          variant: 'outlined',
                          autofillHints: [AutofillHints.name],
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
                          autofillHints: [AutofillHints.telephoneNumber],
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
                      const SizedBox(height: AppSpacing.xl),
                      AppPrimaryButton(
                        text: 'Save Changes',
                        onPressed: _saveProfile,
                      ),
                    ].divide(const SizedBox(height: AppSpacing.lg)),
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
