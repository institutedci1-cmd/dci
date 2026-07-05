import '/components/button/button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'announcement_card_widget.dart' show AnnouncementCardWidget;
import 'package:flutter/material.dart';

class AnnouncementCardModel extends FlutterFlowModel<AnnouncementCardWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    buttonModel.dispose();
  }
}
