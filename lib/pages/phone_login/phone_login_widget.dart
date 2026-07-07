import 'dart:async';
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
import 'phone_login_model.dart';

class PhoneLoginWidget extends ConsumerStatefulWidget {
  const PhoneLoginWidget({super.key});

  static String routeName = 'PhoneLogin';
  static String routePath = '/phoneLogin';

  @override
  ConsumerState<PhoneLoginWidget> createState() => _PhoneLoginWidgetState();
}

class _PhoneLoginWidgetState extends ConsumerState<PhoneLoginWidget> {
  late PhoneLoginModel _model;
  bool _isLoading = false;
  bool _otpSent = false;
  
  Timer? _timer;
  int _timerSeconds = 60;
  bool _canResend = false;

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneLoginModel());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final phoneNumber = _model.phoneTextFieldModel.inputTextController!.text.trim();
      final authRepository = ref.read(authRepositoryProvider);

      await authRepository.beginPhoneAuth(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, forceResendingToken) {
          setState(() {
            _model.verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully.')),
          );
        },
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          ErrorHandler.show(context, e);
        },
        verificationCompleted: (credential) async {
          if (mounted) {
            context.goNamed(HomeDashboardWidget.routeName);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.show(context, e);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;
    await _handleSendOtp();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _model.otpTextFieldModel.inputTextController!.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.verifyOtp(_model.verificationId!, otp);

      if (!mounted) return;
      context.goNamed(HomeDashboardWidget.routeName);
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
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
                _buildPhoneAuthCard(context),
                const SizedBox(height: 32.0),
                _buildFooterLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneAuthCard(BuildContext context) {
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
            _buildTitle(context),
            const SizedBox(height: 24.0),
            if (!_otpSent) _buildPhoneInput(context) else _buildOtpInput(context),
            const SizedBox(height: 24.0),
            if (!_otpSent) _buildSendOtpButton(context) else _buildVerifyOtpButton(context),
            if (_otpSent) ...[
              const SizedBox(height: 16.0),
              _buildResendSection(context),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  setState(() {
                    _otpSent = false;
                    _timer?.cancel();
                  });
                },
                child: Text(
                  'Change Phone Number',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResendSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _canResend ? "Didn't receive the code? " : "Resend code in ",
          style: FlutterFlowTheme.of(context).bodySmall,
        ),
        if (!_canResend)
          Text(
            '${_timerSeconds}s',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
              color: FlutterFlowTheme.of(context).primary,
            ),
          )
        else
          InkWell(
            onTap: _handleResendOtp,
            child: Text(
              'Resend',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                color: FlutterFlowTheme.of(context).primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          _otpSent ? 'Verify OTP' : 'Phone Login',
          style: FlutterFlowTheme.of(context).titleLarge.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          _otpSent ? 'Enter the code sent to your phone' : 'Secure access for teachers',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(BuildContext context) {
    return wrapWithModel(
      model: _model.phoneTextFieldModel,
      updateCallback: () => safeSetState(() {}),
      child: const TextFieldWidget(
        label: 'Phone Number',
        hint: '+91 98765 43210',
        leadingIcon: Icon(Icons.phone_outlined, size: 20),
        leadingIconPresent: true,
        keyboardType: TextInputType.phone,
        validator: ValidationService.validatePhoneNumber,
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context) {
    return wrapWithModel(
      model: _model.otpTextFieldModel,
      updateCallback: () => safeSetState(() {}),
      child: const TextFieldWidget(
        label: 'OTP Code',
        hint: 'Enter 6-digit OTP',
        leadingIcon: Icon(Icons.lock_clock_outlined, size: 20),
        leadingIconPresent: true,
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildSendOtpButton(BuildContext context) {
    return wrapWithModel(
      model: _model.sendOtpButtonModel,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        content: 'Send OTP',
        variant: 'primary',
        size: 'large',
        fullWidth: true,
        loading: _isLoading,
        onPressed: _handleSendOtp,
      ),
    );
  }

  Widget _buildVerifyOtpButton(BuildContext context) {
    return wrapWithModel(
      model: _model.verifyOtpButtonModel,
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        content: 'Verify & Login',
        variant: 'primary',
        size: 'large',
        fullWidth: true,
        loading: _isLoading,
        onPressed: _handleVerifyOtp,
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.pushNamed(LoginWidget.routeName),
          child: Text(
            'Back to Email Login',
            style: FlutterFlowTheme.of(context).bodySmall.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.bold),
              color: FlutterFlowTheme.of(context).primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Version 1.0.5 (Stable)', style: FlutterFlowTheme.of(context).labelSmall),
      ],
    );
  }
}
