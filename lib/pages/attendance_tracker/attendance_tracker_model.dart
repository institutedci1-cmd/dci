import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'attendance_tracker_widget.dart' show AttendanceTrackerWidget;
import 'package:flutter/material.dart';

class AttendanceTrackerModel extends FlutterFlowModel<AttendanceTrackerWidget> {
  ///  State fields for stateful widgets in this page.
  
  // State field for Class Dropdown
  String? selectedClass;
  FormFieldController<String>? classDropdownController;

  // List of students fetched for the class
  List<Map<String, dynamic>> students = [];
  // Map of studentId to attendance status (Present, Absent, Leave)
  Map<String, String> attendanceMap = {};

  // Model for Save Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel.dispose();
  }
}
