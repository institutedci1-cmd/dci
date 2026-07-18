import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';

class AddUserModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for headerSection component.
  late HeaderSectionModel headerSectionModel;
  // State field(s) for name widget.
  late TextFieldModel nameModel;
  // State field(s) for email widget.
  late TextFieldModel emailModel;
  // State field(s) for designation widget.
  late TextFieldModel designationModel;
  // State field(s) for employeeId widget.
  late TextFieldModel employeeIdModel;
  // State field(s) for phone widget.
  late TextFieldModel phoneModel;
  // State field(s) for expertise widget.
  late TextFieldModel subjectExpertiseModel;
  // State field(s) for role dropdown.
  String? roleValue;
  FormFieldController<String>? roleValueController;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
    nameModel = createModel(context, () => TextFieldModel());
    emailModel = createModel(context, () => TextFieldModel());
    designationModel = createModel(context, () => TextFieldModel());
    employeeIdModel = createModel(context, () => TextFieldModel());
    phoneModel = createModel(context, () => TextFieldModel());
    subjectExpertiseModel = createModel(context, () => TextFieldModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    headerSectionModel.dispose();
    nameModel.dispose();
    emailModel.dispose();
    designationModel.dispose();
    employeeIdModel.dispose();
    phoneModel.dispose();
    subjectExpertiseModel.dispose();
  }
}
