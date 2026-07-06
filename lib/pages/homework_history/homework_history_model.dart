import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'homework_history_widget.dart' show HomeworkHistoryWidget;
import 'package:flutter/material.dart';

class HomeworkHistoryModel extends FlutterFlowModel<HomeworkHistoryWidget> {
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
