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
        });
      }
    } catch (e) {
      // Handle error
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
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      context.safePop();
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
