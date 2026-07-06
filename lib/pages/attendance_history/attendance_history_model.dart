import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'attendance_history_widget.dart' show AttendanceHistoryWidget;
import 'package:flutter/material.dart';

class AttendanceHistoryModel extends FlutterFlowModel<AttendanceHistoryWidget> {
  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
  }
}
