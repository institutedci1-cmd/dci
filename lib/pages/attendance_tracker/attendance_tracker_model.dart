import '/components/attendance_option/attendance_option_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'attendance_tracker_widget.dart' show AttendanceTrackerWidget;
import 'package:flutter/material.dart';

class AttendanceTrackerModel extends FlutterFlowModel<AttendanceTrackerWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AttendanceOption.
  late AttendanceOptionModel attendanceOptionModel1;
  // Model for AttendanceOption.
  late AttendanceOptionModel attendanceOptionModel2;
  // Model for AttendanceOption.
  late AttendanceOptionModel attendanceOptionModel3;
  // Model for AttendanceOption.
  late AttendanceOptionModel attendanceOptionModel4;
  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    attendanceOptionModel1 =
        createModel(context, () => AttendanceOptionModel());
    attendanceOptionModel2 =
        createModel(context, () => AttendanceOptionModel());
    attendanceOptionModel3 =
        createModel(context, () => AttendanceOptionModel());
    attendanceOptionModel4 =
        createModel(context, () => AttendanceOptionModel());
    textFieldModel = createModel(context, () => TextFieldModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    attendanceOptionModel1.dispose();
    attendanceOptionModel2.dispose();
    attendanceOptionModel3.dispose();
    attendanceOptionModel4.dispose();
    textFieldModel.dispose();
    buttonModel.dispose();
  }
}
