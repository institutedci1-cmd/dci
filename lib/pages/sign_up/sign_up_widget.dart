import '/backend/providers/repository_providers.dart';
import '/backend/services/validation_service.dart';
import '/components/auth_header/auth_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up_model.dart';
export 'sign_up_model.dart';

class SignUpWidget extends ConsumerStatefulWidget {
  const SignUpWidget({super.key});

  static String routeName = 'SignUp';
  static String routePath = '/signUp';

  @override
  ConsumerState<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends ConsumerState<SignUpWidget> {
  late SignUpModel _model;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignUpModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = _model.textFieldModel2.inputTextController!.text;
    final confirmPassword = _model.textFieldModel3.inputTextController!.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final credential = await authRepository.signUpWithEmail(
        _model.textFieldModel1.inputTextController!.text.trim(),
        password,
      );

      if (credential.user != null) {
        await authRepository.createUserDoc(credential.user!);
      }

      if (!mounted) return;
      context.goNamed(HomeDashboardWidget.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const SizedBox(height: 40.0),
                wrapWithModel(
                  model: _model.authHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const AuthHeaderWidget(),
                ),
                const SizedBox(height: 32.0),
                _buildSignUpCard(context),
                const SizedBox(height: 32.0),
                _buildFooterLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildSignUpTitle(context),
            const SizedBox(height: 24.0),
            _buildInputFields(context),
            const SizedBox(height: 24.0),
            _buildSignUpButton(context),
            const SizedBox(height: 16.0),
            _buildDivider(context),
            const SizedBox(height: 16.0),
            _buildGoogleSignUp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: FlutterFlowTheme.of(context).titleLarge.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Join Deshmukh Coaching Institute',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields(BuildContext context) {
    return Column(
      children: [
        wrapWithModel(
          model: _model.textFieldModel1,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Email Address',
            hint: 'teacher@deshmukhcoaching.com',
            leadingIcon: Icon(Icons.email_outlined),
            validator: ValidationService.validateEmail,
          ),
        ),
        const SizedBox(height: 16.0),
        wrapWithModel(
          model: _model.textFieldModel2,
          updateCallback: () => safeSetState(() {}),
          child: const TextFieldWidget(
            label: 'Password',
            hint: 'Enter your password',
            leadingIcon: Icon(Icons.lock_outlined),
            trailingIcon: Icon(Icons.visibility_off_outlined),
            trailingIconPresent: true,
            validator: ValidationService.validatePassword,
          ),
        ),
        const SizedBox(height: 16.0),
        wrapWithModel(
          model: _model.textFieldModel3,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            leadingIcon: const Icon(Icons.lock_reset_outlined),
            trailingIcon: const Icon(Icons.visibility_off_outlined),
            trailingIconPresent: true,
            validator: (val) => ValidationService.validateRequired(val, 'Confirm Password'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return wrapWithModel(
      model: _model.buttonModel1,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        content: 'Sign Up',
        variant: 'primary',
        size: 'large',
        fullWidth: true,
        loading: _isLoading,
        onPressed: _handleSignUp,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('OR', style: FlutterFlowTheme.of(context).labelSmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleSignUp(BuildContext context) {
    return wrapWithModel(
      model: _model.buttonModel2,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        content: 'Sign up with Google',
        variant: 'outline',
        fullWidth: true,
        iconEndPresent: true,
        iconEnd: const Icon(Icons.login_rounded),
        onPressed: () async {
          // Implement Google Sign Up
        },
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Need help?', style: FlutterFlowTheme.of(context).bodySmall),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => launchURL('mailto:admin@deshmukhcoaching.com'),
              child: Text(
                'Contact Admin',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account?', style: FlutterFlowTheme.of(context).bodySmall),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => context.goNamed(LoginWidget.routeName),
              child: Text(
                'Sign In',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Version 1.0.4 (Stable)', style: FlutterFlowTheme.of(context).labelSmall),
      ],
    );
  }
}
