import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/pages/exams/add_exam_widget.dart' show AddExamWidget;
import 'package:flutter/material.dart';

class AddExamModel extends FlutterFlowModel<AddExamWidget> {
  // State fields for form.
  String? selectedClass;
  FormFieldController<String>? classDropdownController;
  
  String? selectedSubject;
  FormFieldController<String>? subjectDropdownController;

  late TextFieldModel venueModel;
  late TextFieldModel totalMarksModel;
  late TextFieldModel passingMarksModel;
  late TextFieldModel descriptionModel;
  
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
    buttonModel = createModel(context, () => ButtonModel());
    subjectDropdownController = FormFieldController<String>(null);
    venueModel = createModel(context, () => TextFieldModel());
    totalMarksModel = createModel(context, () => TextFieldModel());
    passingMarksModel = createModel(context, () => TextFieldModel());
    descriptionModel = createModel(context, () => TextFieldModel());
    
    classDropdownController = FormFieldController<String>(null);
    
    selectedDate = DateTime.now();
    startTime = const TimeOfDay(hour: 9, minute: 0);
    endTime = const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
    buttonModel.dispose();
    venueModel.dispose();
    totalMarksModel.dispose();
    passingMarksModel.dispose();
    descriptionModel.dispose();
  }
}
