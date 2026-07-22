import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/error_handler.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/validation_service.dart';
import 'package:d_c_i_teacher_app/components/auth_header/auth_header_widget.dart';
import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:d_c_i_teacher_app/pages/login/login_model.dart';

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
      
      await ref.read(authServiceProvider).signInWithEmail(email, password);

      if (!mounted) return;
      context.go('/');
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
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
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
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.medium,
      ),
      padding: const EdgeInsets.all(32.0),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLoginTitle(context),
              const SizedBox(height: 32.0),
              _buildInputFields(context),
              const SizedBox(height: 32.0),
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
          style: AppTypography.title.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Sign in to manage your classes',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
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
            hint: 'teacher@deshmukhinstitute.com',
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
            onSubmit: (_) => _handleLogin(),
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
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
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
        Text('Version 1.0.3 (Stable)', style: FlutterFlowTheme.of(context).labelSmall),
      ],
    );
  }
}
