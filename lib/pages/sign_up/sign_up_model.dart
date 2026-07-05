import '/components/auth_header/auth_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sign_up_widget.dart' show SignUpWidget;
import 'package:flutter/material.dart';

class SignUpModel extends FlutterFlowModel<SignUpWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AuthHeader.
  late AuthHeaderModel authHeaderModel;
  // Model for TextField (Email).
  late TextFieldModel textFieldModel1;
  // Model for TextField (Password).
  late TextFieldModel textFieldModel2;
  // Model for TextField (Confirm Password).
  late TextFieldModel textFieldModel3;
  // Model for Button (Sign Up).
  late ButtonModel buttonModel1;
  // Model for Button (Google Sign Up).
  late ButtonModel buttonModel2;

  @override
  void initState(BuildContext context) {
    authHeaderModel = createModel(context, () => AuthHeaderModel());

    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());

    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());

    /// Email Validator
    textFieldModel1.inputTextControllerValidator =
        (BuildContext context, String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Email is required';
      }
      final emailRegex = RegExp(
        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
      );
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Enter a valid email';
      }
      return null;
    };

    /// Password Validator
    textFieldModel2.inputTextControllerValidator =
        (BuildContext context, String? value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    };

    /// Confirm Password Validator
    textFieldModel3.inputTextControllerValidator =
        (BuildContext context, String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != textFieldModel2.inputTextController?.text) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  @override
  void dispose() {
    authHeaderModel.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    textFieldModel3.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
  }
}
