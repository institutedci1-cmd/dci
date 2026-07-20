import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/homework_history/homework_history_widget.dart' show HomeworkHistoryWidget;
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
