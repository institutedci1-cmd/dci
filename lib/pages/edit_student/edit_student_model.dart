import '/components/header_section/header_section_widget.dart';
import '/components/button/button_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'edit_student_widget.dart' show EditStudentWidget;
import 'package:flutter/material.dart';

class EditStudentModel extends FlutterFlowModel<EditStudentWidget> {
  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;
  
  // Basic Info
  late TextFieldModel nameModel;
  late TextFieldModel studentIdModel;
  late TextFieldModel rollNoModel;
  late TextFieldModel classModel;
  late TextFieldModel sectionModel;
  late TextFieldModel genderModel;
  late TextFieldModel dobModel;
  
  // Parent Info
  late TextFieldModel parentNameModel;
  late TextFieldModel parentPhoneModel;
  late TextFieldModel altPhoneModel;
  late TextFieldModel emailModel;
  
  // Address
  late TextFieldModel villageCityModel;
  late TextFieldModel addressModel;
  late TextFieldModel pinCodeModel;

  // Academic Info
  late TextFieldModel admissionDateModel;
  late TextFieldModel batchModel;
  late TextFieldModel subjectsModel;
  late TextFieldModel feesStatusModel;
  
  // Profile
  String? photoUrl;
  late TextFieldModel notesModel;

  // Buttons
  late ButtonModel saveButtonModel;
  late ButtonModel deleteButtonModel;

  @override
  void initState(BuildContext context) {
    headerSectionModel = createModel(context, () => HeaderSectionModel());
    
    nameModel = createModel(context, () => TextFieldModel());
    studentIdModel = createModel(context, () => TextFieldModel());
    rollNoModel = createModel(context, () => TextFieldModel());
    classModel = createModel(context, () => TextFieldModel());
    sectionModel = createModel(context, () => TextFieldModel());
    genderModel = createModel(context, () => TextFieldModel());
    dobModel = createModel(context, () => TextFieldModel());
    
    parentNameModel = createModel(context, () => TextFieldModel());
    parentPhoneModel = createModel(context, () => TextFieldModel());
    altPhoneModel = createModel(context, () => TextFieldModel());
    emailModel = createModel(context, () => TextFieldModel());

    villageCityModel = createModel(context, () => TextFieldModel());
    addressModel = createModel(context, () => TextFieldModel());
    pinCodeModel = createModel(context, () => TextFieldModel());

    admissionDateModel = createModel(context, () => TextFieldModel());
    batchModel = createModel(context, () => TextFieldModel());
    subjectsModel = createModel(context, () => TextFieldModel());
    feesStatusModel = createModel(context, () => TextFieldModel());

    notesModel = createModel(context, () => TextFieldModel());
    
    saveButtonModel = createModel(context, () => ButtonModel());
    deleteButtonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
    
    nameModel.dispose();
    studentIdModel.dispose();
    rollNoModel.dispose();
    classModel.dispose();
    sectionModel.dispose();
    genderModel.dispose();
    dobModel.dispose();
    
    parentNameModel.dispose();
    parentPhoneModel.dispose();
    altPhoneModel.dispose();
    emailModel.dispose();

    villageCityModel.dispose();
    addressModel.dispose();
    pinCodeModel.dispose();

    admissionDateModel.dispose();
    batchModel.dispose();
    subjectsModel.dispose();
    feesStatusModel.dispose();

    notesModel.dispose();
    
    saveButtonModel.dispose();
    deleteButtonModel.dispose();
  }
}
