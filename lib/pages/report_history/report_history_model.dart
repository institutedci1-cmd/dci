import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'report_history_widget.dart' show ReportHistoryWidget;
import 'package:flutter/material.dart';

class ReportHistoryModel extends FlutterFlowModel<ReportHistoryWidget> {
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
