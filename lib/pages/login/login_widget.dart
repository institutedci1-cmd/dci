import '/backend/services/error_handler.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/validation_service.dart';
import '/components/auth_header/auth_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadRememberedUser();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      safeSetState(() {
        _model.textFieldModel1.inputTextController?.text = savedEmail;
        _model.rememberMe = true;
      });
    }
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

      final prefs = await SharedPreferences.getInstance();
      if (_model.rememberMe) {
        await prefs.setString('remembered_email', email);
      } else {
        await prefs.remove('remembered_email');
      }

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
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                wrapWithModel(
                  model: _model.authHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const AuthHeaderWidget(),
                ),
                const SizedBox(height: 32.0),
                _buildLoginCard(context),
                const SizedBox(height: 24.0),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildLoginTitle(context),
            const SizedBox(height: 24.0),
            _buildInputFields(context),
            const SizedBox(height: 24.0),
            _buildLoginButton(context),
            const SizedBox(height: 16.0),
            _buildPhoneLoginButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          'Teacher Portal',
          style: AppTypography.h1.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Login to manage your dashboard',
          style: AppTypography.secondaryText,
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
            leadingIcon: Icon(Icons.email_outlined, size: 20),
            leadingIconPresent: true,
            keyboardType: TextInputType.emailAddress,
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
            leadingIcon: Icon(Icons.lock_outlined, size: 20),
            leadingIconPresent: true,
            obscureText: true,
            validator: ValidationService.validatePassword,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => setState(() => _model.rememberMe = !_model.rememberMe),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _model.rememberMe,
                      onChanged: (val) => setState(() => _model.rememberMe = val ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Remember Me', style: AppTypography.caption),
                ],
              ),
            ),
            TextButton(
              onPressed: _handleResetPassword,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(
                'Forgot Password?',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return wrapWithModel(
      model: _model.buttonModel2,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        content: 'Sign In',
        variant: 'primary',
        size: 'large',
        fullWidth: true,
        loading: _isLoading,
        onPressed: _handleLogin,
      ),
    );
  }

  Widget _buildPhoneLoginButton(BuildContext context) {
    return wrapWithModel(
      model: _model.buttonModel3,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        icon: const Icon(Icons.phone_android_rounded, size: 20),
        iconPresent: true,
        content: 'Sign in with Phone',
        variant: 'outline',
        size: 'large',
        fullWidth: true,
        onPressed: () => context.pushNamed(PhoneLoginWidget.routeName),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Don\'t have an account?', style: AppTypography.caption),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => context.pushNamed(SignUpWidget.routeName),
              child: Text(
                'Sign Up',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Version 1.0.6 (Enterprise)', style: AppTypography.caption),
      ],
    );
  }
}
