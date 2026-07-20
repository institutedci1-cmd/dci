import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/edit_profile/edit_profile_widget.dart' show EditProfileWidget;
import 'package:flutter/material.dart';

class EditProfileModel extends FlutterFlowModel<EditProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;
  // Model for TextField (Name).
  late TextFieldModel textFieldModel1;
  // Model for TextField (Designation).
  late TextFieldModel textFieldModel2;
  // Model for TextField (Phone).
  late TextFieldModel textFieldModel3;
  // Model for TextField (Qualification).
  late TextFieldModel textFieldModel4;
  // Model for TextField (Subject Expertise).
  late TextFieldModel textFieldModel5;
  // Model for TextField (Experience).
  late TextFieldModel textFieldModel6;
  // Model for TextField (Employee ID).
  late TextFieldModel textFieldModel7;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    textFieldModel3 = createModel(context, () => TextFieldModel());
    textFieldModel4 = createModel(context, () => TextFieldModel());
    textFieldModel5 = createModel(context, () => TextFieldModel());
    textFieldModel6 = createModel(context, () => TextFieldModel());
    textFieldModel7 = createModel(context, () => TextFieldModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    textFieldModel3.dispose();
    textFieldModel4.dispose();
    textFieldModel5.dispose();
    textFieldModel6.dispose();
    textFieldModel7.dispose();
    buttonModel.dispose();
  }
}
