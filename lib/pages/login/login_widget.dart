import '/backend/services/error_handler.dart';
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
export 'login_model.dart';

class LoginWidget extends ConsumerStatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  ConsumerState<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends ConsumerState<LoginWidget> {
  late LoginModel _model;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _model.textFieldModel1.inputTextController!.text.trim();
      final password = _model.textFieldModel2.inputTextController!.text;
      
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithEmail(email, password);

      if (!mounted) return;
      context.goNamed(HomeDashboardWidget.routeName);
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _model.textFieldModel1.inputTextController?.text.trim() ?? '';
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password.')),
      );
      return;
    }

    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
                _buildLoginCard(context),
                const SizedBox(height: 32.0),
                _buildFooterLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      padding: const EdgeInsets.all(32.0),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLoginTitle(context),
              const SizedBox(height: 24.0),
              _buildInputFields(context),
              const SizedBox(height: 24.0),
              _buildLoginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: FlutterFlowTheme.of(context).titleLarge.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Sign in to manage your classes',
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
            hint: 'teacher@dciteachers.com',
            leadingIcon: Icon(Icons.email_outlined, size: 20),
            leadingIconPresent: true,
            keyboardType: TextInputType.emailAddress,
            validator: ValidationService.validateEmail,
            autofillHints: [AutofillHints.email],
          ),
        ),
        const SizedBox(height: 16.0),
        wrapWithModel(
          model: _model.textFieldModel2,
          updateCallback: () => safeSetState(() {}),
          child: TextFieldWidget(
            label: 'Password',
            hint: 'Enter your password',
            leadingIcon: const Icon(Icons.lock_outlined, size: 20),
            leadingIconPresent: true,
            obscureText: true,
            validator: (val) => ValidationService.validateRequired(val, 'Password'),
            autofillHints: const [AutofillHints.password],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleResetPassword,
            child: Text(
              'Forgot Password?',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return wrapWithModel(
      model: _model.buttonModel2,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        content: 'Login to Dashboard',
        variant: 'primary',
        size: 'large',
        fullWidth: true,
        loading: _isLoading,
        onPressed: _handleLogin,
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text('Version 1.0.2 (Stable)', style: FlutterFlowTheme.of(context).labelSmall),
      ],
    );
  }
}
