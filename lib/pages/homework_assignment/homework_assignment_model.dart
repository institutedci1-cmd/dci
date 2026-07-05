import '/components/button/button_widget.dart';
import '/components/form_label/form_label_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'homework_assignment_widget.dart' show HomeworkAssignmentWidget;
import 'package:flutter/material.dart';

class HomeworkAssignmentModel
    extends FlutterFlowModel<HomeworkAssignmentWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;
  // Model for FormLabel.
  late FormLabelModel formLabelModel1;
  // State field(s) for Dropdown widget.
  String? dropdownValue1;
  FormFieldController<String>? dropdownValueController1;
  // Model for FormLabel.
  late FormLabelModel formLabelModel2;
  // State field(s) for Dropdown widget.
  String? dropdownValue2;
  FormFieldController<String>? dropdownValueController2;
  // Model for FormLabel.
  late FormLabelModel formLabelModel3;
  // Model for TextField.
  late TextFieldModel textFieldModel1;
  // Model for TextField.
  late TextFieldModel textFieldModel2;
  // Model for FormLabel.
  late FormLabelModel formLabelModel4;
  // State field(s) for due date.
  DateTime? dueDate;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for Button.
  late ButtonModel buttonModel3;

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
    formLabelModel1 = createModel(context, () => FormLabelModel());
    formLabelModel2 = createModel(context, () => FormLabelModel());
    formLabelModel3 = createModel(context, () => FormLabelModel());
    textFieldModel1 = createModel(context, () => TextFieldModel());
    textFieldModel2 = createModel(context, () => TextFieldModel());
    formLabelModel4 = createModel(context, () => FormLabelModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    buttonModel3 = createModel(context, () => ButtonModel());

    textFieldModel1.inputTextControllerValidator =
        (BuildContext context, String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Homework title is required.';
      }
      return null;
    };

    textFieldModel2.inputTextControllerValidator =
        (BuildContext context, String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Description is required.';
      }
      return null;
    };
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
    formLabelModel1.dispose();
    formLabelModel2.dispose();
    formLabelModel3.dispose();
    textFieldModel1.dispose();
    textFieldModel2.dispose();
    formLabelModel4.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
    buttonModel3.dispose();
  }
}
