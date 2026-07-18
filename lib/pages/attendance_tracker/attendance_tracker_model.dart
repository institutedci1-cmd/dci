import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'attendance_tracker_widget.dart' show AttendanceTrackerWidget;
import 'package:flutter/material.dart';

class AttendanceTrackerModel extends FlutterFlowModel<AttendanceTrackerWidget> {
  // State fields for Class Dropdown
  String? selectedClass;
  FormFieldController<String>? classDropdownController;

  // State field for Date
  DateTime? selectedDate;

  // State field for Subject Dropdown
  String? selectedSubject;
  FormFieldController<String>? subjectDropdownController;

  // Search field
  late TextFieldModel searchFieldModel;
  String searchQuery = '';

  // Map of studentId to attendance status (Present, Absent)
  Map<String, String> attendanceMap = {};

  // Model for Save Button.
  late ButtonModel buttonModel;

  // Dynamic list for subjects
  List<String> subjectOptions = [];

  @override
  void initState(BuildContext context) {
    buttonModel = createModel(context, () => ButtonModel());
    searchFieldModel = createModel(context, () => TextFieldModel());
    searchFieldModel.inputTextController ??= TextEditingController();
    
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    buttonModel.dispose();
    searchFieldModel.dispose();
  }
}
