import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'attendance_tracker_widget.dart' show AttendanceTrackerWidget;
import 'package:flutter/material.dart';

class AttendanceTrackerModel extends FlutterFlowModel<AttendanceTrackerWidget> {
  // --- UI State ---
  bool isSaving = false;
  bool isAlreadySubmitted = false;
  bool sendWhatsAppAlerts = false;

  // --- Form Fields ---
  String? selectedClass;
  FormFieldController<String>? classDropdownController;
  DateTime? selectedDate;
  late TextFieldModel subjectFieldModel;
  late TextFieldModel searchFieldModel;

  // --- Component Models ---
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    buttonModel = createModel(context, () => ButtonModel());
    searchFieldModel = createModel(context, () => TextFieldModel());
    searchFieldModel.inputTextController = TextEditingController();
    
    subjectFieldModel = createModel(context, () => TextFieldModel());
    subjectFieldModel.inputTextController = TextEditingController();
    
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    buttonModel.dispose();
    searchFieldModel.dispose();
    subjectFieldModel.dispose();
  }
}
