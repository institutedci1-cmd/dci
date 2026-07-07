import '/components/auth_header/auth_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'phone_login_widget.dart' show PhoneLoginWidget;
import 'package:flutter/material.dart';

class PhoneLoginModel extends FlutterFlowModel<PhoneLoginWidget> {
  // Model for AuthHeader.
  late AuthHeaderModel authHeaderModel;
  // Model for Phone Number TextField.
  late TextFieldModel phoneTextFieldModel;
  // Model for OTP TextField.
  late TextFieldModel otpTextFieldModel;
  // Model for Send OTP Button.
  late ButtonModel sendOtpButtonModel;
  // Model for Verify OTP Button.
  late ButtonModel verifyOtpButtonModel;

  String? verificationId;

  @override
  void initState(BuildContext context) {
    authHeaderModel = createModel(context, () => AuthHeaderModel());
    phoneTextFieldModel = createModel(context, () => TextFieldModel());
    otpTextFieldModel = createModel(context, () => TextFieldModel());
    sendOtpButtonModel = createModel(context, () => ButtonModel());
    verifyOtpButtonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    authHeaderModel.dispose();
    phoneTextFieldModel.dispose();
    otpTextFieldModel.dispose();
    sendOtpButtonModel.dispose();
    verifyOtpButtonModel.dispose();
  }
}
