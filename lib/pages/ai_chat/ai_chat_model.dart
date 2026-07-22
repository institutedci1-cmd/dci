import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class AIChatModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.
  final listViewController = ScrollController();
  // State field(s) for chatInput widget.
  FocusNode? chatInputFocusNode;
  TextEditingController? chatInputTextController;
  String? Function(BuildContext, String?)? chatInputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    listViewController.dispose();
    chatInputFocusNode?.dispose();
    chatInputTextController?.dispose();
  }
}
