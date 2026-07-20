import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class EnterMarksModel extends FlutterFlowModel {
  // Map of studentId to marks controller
  final Map<String, TextEditingController> marksControllers = {};
  // Map of studentId to remarks controller
  final Map<String, TextEditingController> remarksControllers = {};

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    for (var controller in marksControllers.values) {
      controller.dispose();
    }
    for (var controller in remarksControllers.values) {
      controller.dispose();
    }
  }

  TextEditingController getMarksController(String studentId) {
    if (!marksControllers.containsKey(studentId)) {
      marksControllers[studentId] = TextEditingController();
    }
    return marksControllers[studentId]!;
  }

  TextEditingController getRemarksController(String studentId) {
    if (!remarksControllers.containsKey(studentId)) {
      remarksControllers[studentId] = TextEditingController();
    }
    return remarksControllers[studentId]!;
  }
}
