import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/pages/student_list/student_list_widget.dart' show StudentListWidget;
import 'package:flutter/material.dart';

class StudentListModel extends FlutterFlowModel<StudentListWidget> {
  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;
  // State field(s) for Search widget.
  TextEditingController? searchController;
  late TextFieldModel searchFieldModel;
  // State field(s) for Dropdown (Class Filter).
  String? dropdownValue;
  FormFieldController<String>? dropdownValueController;

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
    searchFieldModel = createModel(context, () => TextFieldModel());
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
    searchFieldModel.dispose();
  }
}
