import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/pages/attendance_report/attendance_report_widget.dart' show AttendanceReportWidget;
import 'package:flutter/material.dart';

class AttendanceReportModel extends FlutterFlowModel<AttendanceReportWidget> {
  String? selectedClass;
  FormFieldController<String>? classDropdownController;
  DateTime? selectedDate;
  TextEditingController? searchController;

  @override
  void initState(BuildContext context) {
    classDropdownController = FormFieldController<String>(null);
    selectedDate = DateTime.now();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController?.dispose();
  }
}
