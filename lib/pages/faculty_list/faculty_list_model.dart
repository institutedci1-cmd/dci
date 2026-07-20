import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/faculty_list/faculty_list_widget.dart' show FacultyListWidget;
import 'package:flutter/material.dart';

class FacultyListModel extends FlutterFlowModel<FacultyListWidget> {
  // State fields for search.
  TextEditingController? searchController;

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController?.dispose();
  }
}
