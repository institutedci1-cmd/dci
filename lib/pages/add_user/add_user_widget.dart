import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/validation_service.dart';
import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_drop_down.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:d_c_i_teacher_app/pages/add_user/add_user_model.dart';
export 'package:d_c_i_teacher_app/pages/add_user/add_user_model.dart';

class AddUserWidget extends ConsumerStatefulWidget {
  const AddUserWidget({super.key});

  static String routeName = 'AddUser';
  static String routePath = '/addUser';

  @override
  ConsumerState<AddUserWidget> createState() => _AddUserWidgetState();
}

class _AddUserWidgetState extends ConsumerState<AddUserWidget> {
  late AddUserModel _model;
  bool _isSaving = false;
  bool _isAdmin = false;
  bool _checkingRole = true;
  Timer? _debounceTimer;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddUserModel());
    _checkAdminStatus();
    
    // Add listener for email field to check for existing user
    _model.emailModel.inputTextController?.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      final email = _model.emailModel.inputTextController!.text.trim();
      if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _fetchExistingUserData(email);
      }
    });
  }

  Future<void> _fetchExistingUserData(String email) async {
    try {
      final repository = ref.read(userRepositoryProvider);
      final teacher = await repository.findUserByEmail(email);

      if (teacher != null && mounted) {
        setState(() {
          _model.nameModel.inputTextController?.text = teacher.displayName;
          _model.designationModel.inputTextController?.text = teacher.designation;
          _model.phoneModel.inputTextController?.text = teacher.phoneNumber;
          _model.employeeIdModel.inputTextController?.text = teacher.employeeId ?? '';
          _model.subjectExpertiseModel.inputTextController?.text = teacher.subjectExpertise ?? '';
          _model.roleValue = teacher.role;
          _model.roleValueController?.value = teacher.role;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Found existing user profile. Form populated.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
  }

  Future<void> _checkAdminStatus() async {
    final userData = await ref.read(userRepositoryProvider).getUserData();
    if (mounted) {
      setState(() {
        _isAdmin = userData?.role == 'Admin';
        _checkingRole = false;
      });
      if (!_isAdmin) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.safePop();
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _model.emailModel.inputTextController?.removeListener(_onEmailChanged);
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleAddUser() async {
    if (!_formKey.currentState!.validate() || _model.roleValue == null) {
      if (_model.roleValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role.')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(userRepositoryProvider).createNewUser(
        email: _model.emailModel.inputTextController!.text,
        password: _model.passwordModel.inputTextController!.text,
        displayName: _model.nameModel.inputTextController!.text,
        role: _model.roleValue!,
        designation: _model.designationModel.inputTextController!.text,
        phoneNumber: _model.phoneModel.inputTextController!.text,
        employeeId: _model.employeeIdModel.inputTextController!.text,
        subjectExpertise: _model.subjectExpertiseModel.inputTextController!.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile created successfully!')),
      );
      context.safePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingRole) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 64, color: FlutterFlowTheme.of(context).error),
                const SizedBox(height: 24),
                Text(
                  'Access Denied',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You do not have the required permissions to access administrative tools. Redirecting you...',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                title: 'Add New User',
                subtitle: 'Invite faculty to DCI',
                onBackPressed: () async => context.safePop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormCard(context),
                      const SizedBox(height: 32),
                      ButtonWidget(
                        content: 'Create User Profile',
                        variant: 'primary',
                        size: 'large',
                        loading: _isSaving,
                        onPressed: _handleAddUser,
                      ),
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

  Widget _buildFormCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          wrapWithModel(
            model: _model.nameModel,
            updateCallback: () => safeSetState(() {}),
            child: TextFieldWidget(
              label: 'Full Name',
              hint: 'e.g. John Doe',
              leadingIcon: const Icon(Icons.person_outline_rounded),
              leadingIconPresent: true,
              variant: 'outlined',
              validator: (val) => ValidationService.validateRequired(val, 'Full Name'),
            ),
          ),
          const SizedBox(height: 16),
          wrapWithModel(
            model: _model.emailModel,
            updateCallback: () => safeSetState(() {}),
            child: const TextFieldWidget(
              label: 'Email Address',
              hint: 'user@dci.com',
              leadingIcon: Icon(Icons.email_outlined),
              leadingIconPresent: true,
              variant: 'outlined',
              keyboardType: TextInputType.emailAddress,
              validator: ValidationService.validateEmail,
            ),
          ),
          const SizedBox(height: 16),
          wrapWithModel(
            model: _model.passwordModel,
            updateCallback: () => safeSetState(() {}),
            child: const TextFieldWidget(
              label: 'Initial Password',
              hint: 'Set a temporary password',
              leadingIcon: Icon(Icons.lock_outline_rounded),
              leadingIconPresent: true,
              variant: 'outlined',
              obscureText: true,
              validator: ValidationService.validatePassword,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text('User Role', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
              ),
              FlutterFlowDropDown<String>(
                controller: _model.roleValueController!,
                options: const ['Teacher', 'Admin'],
                onChanged: (val) => setState(() => _model.roleValue = val),
                height: 48,
                hintText: 'Select Role',
                fillColor: theme.secondaryBackground,
                borderRadius: AppRadius.md,
                borderWidth: 1,
                borderColor: theme.alternate,
                hidesUnderline: true,
                textStyle: AppTypography.body,
                elevation: 0,
                margin: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          wrapWithModel(
            model: _model.designationModel,
            updateCallback: () => safeSetState(() {}),
            child: const TextFieldWidget(
              label: 'Designation',
              hint: 'e.g. Physics HOD',
              leadingIcon: Icon(Icons.work_outline_rounded),
              leadingIconPresent: true,
              variant: 'outlined',
            ),
          ),
          const SizedBox(height: 16),
          wrapWithModel(
            model: _model.subjectExpertiseModel,
            updateCallback: () => safeSetState(() {}),
            child: const TextFieldWidget(
              label: 'Subject Expertise',
              hint: 'e.g. Math, Physics',
              leadingIcon: Icon(Icons.psychology_rounded),
              leadingIconPresent: true,
              variant: 'outlined',
            ),
          ),
          const SizedBox(height: 16),
          wrapWithModel(
            model: _model.phoneModel,
            updateCallback: () => safeSetState(() {}),
            child: const TextFieldWidget(
              label: 'Phone Number',
              hint: 'e.g. +91 9876543210',
              leadingIcon: Icon(Icons.phone_outlined),
              leadingIconPresent: true,
              variant: 'outlined',
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }
}
