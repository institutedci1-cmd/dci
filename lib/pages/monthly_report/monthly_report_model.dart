import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'monthly_report_widget.dart' show MonthlyReportWidget;
import 'package:flutter/material.dart';

class MonthlyReportModel extends FlutterFlowModel<MonthlyReportWidget> {
  String? selectedClass;
  FormFieldController<String>? classDropdownController;
  DateTime? selectedMonth;

  @override
  void initState(BuildContext context) {
    selectedMonth = DateTime.now();
  }

  @override
  void dispose() {}
}
