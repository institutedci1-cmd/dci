import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/button/button_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/edit_student_widget.dart' show EditStudentWidget;
import 'package:flutter/material.dart';

class EditStudentModel extends FlutterFlowModel<EditStudentWidget> {
  // Model for HeaderSection.
  late HeaderSectionModel headerSectionModel;
  
  // Basic Info
  late TextFieldModel nameModel;
  late TextFieldModel studentIdModel;
  late TextFieldModel rollNoModel;
  
  // Class Dropdown
  String? selectedClass;
  FormFieldController<String>? classDropdownController;

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
    nameModel.inputTextController ??= TextEditingController();
    
    studentIdModel = createModel(context, () => TextFieldModel());
    studentIdModel.inputTextController ??= TextEditingController();
    
    classDropdownController = FormFieldController<String>(null);
    
    rollNoModel = createModel(context, () => TextFieldModel());
    rollNoModel.inputTextController ??= TextEditingController();
    
    sectionModel = createModel(context, () => TextFieldModel());
    sectionModel.inputTextController ??= TextEditingController();
    
    genderModel = createModel(context, () => TextFieldModel());
    genderModel.inputTextController ??= TextEditingController();
    
    dobModel = createModel(context, () => TextFieldModel());
    dobModel.inputTextController ??= TextEditingController();
    
    parentNameModel = createModel(context, () => TextFieldModel());
    parentNameModel.inputTextController ??= TextEditingController();
    
    parentPhoneModel = createModel(context, () => TextFieldModel());
    parentPhoneModel.inputTextController ??= TextEditingController();
    
    altPhoneModel = createModel(context, () => TextFieldModel());
    altPhoneModel.inputTextController ??= TextEditingController();
    
    emailModel = createModel(context, () => TextFieldModel());
    emailModel.inputTextController ??= TextEditingController();

    villageCityModel = createModel(context, () => TextFieldModel());
    villageCityModel.inputTextController ??= TextEditingController();
    
    addressModel = createModel(context, () => TextFieldModel());
    addressModel.inputTextController ??= TextEditingController();
    
    pinCodeModel = createModel(context, () => TextFieldModel());
    pinCodeModel.inputTextController ??= TextEditingController();

    admissionDateModel = createModel(context, () => TextFieldModel());
    admissionDateModel.inputTextController ??= TextEditingController();
    
    batchModel = createModel(context, () => TextFieldModel());
    batchModel.inputTextController ??= TextEditingController();
    
    subjectsModel = createModel(context, () => TextFieldModel());
    subjectsModel.inputTextController ??= TextEditingController();
    
    feesStatusModel = createModel(context, () => TextFieldModel());
    feesStatusModel.inputTextController ??= TextEditingController();

    notesModel = createModel(context, () => TextFieldModel());
    notesModel.inputTextController ??= TextEditingController();
    
    saveButtonModel = createModel(context, () => ButtonModel());
    deleteButtonModel = createModel(context, () => ButtonModel());
  }

  void setFromStudent(Student s) {
    nameModel.inputTextController?.text = s.name;
    studentIdModel.inputTextController?.text = s.studentId;
    rollNoModel.inputTextController?.text = s.rollNo;
    
    selectedClass = s.className;
    classDropdownController?.value = s.className;

    sectionModel.inputTextController?.text = s.section ?? '';
    genderModel.inputTextController?.text = s.gender ?? '';
    dobModel.inputTextController?.text = s.dob ?? '';
    
    parentNameModel.inputTextController?.text = s.parentName ?? '';
    parentPhoneModel.inputTextController?.text = s.parentPhone ?? '';
    altPhoneModel.inputTextController?.text = s.altPhone ?? '';
    emailModel.inputTextController?.text = s.email ?? '';
    
    villageCityModel.inputTextController?.text = s.villageCity ?? '';
    addressModel.inputTextController?.text = s.address ?? '';
    pinCodeModel.inputTextController?.text = s.pinCode ?? '';

    admissionDateModel.inputTextController?.text = s.admissionDate ?? '';
    batchModel.inputTextController?.text = s.batch ?? '';
    subjectsModel.inputTextController?.text = s.subjects?.join(', ') ?? '';
    feesStatusModel.inputTextController?.text = s.feesStatus ?? '';
    
    notesModel.inputTextController?.text = s.notes ?? '';
    photoUrl = s.photoUrl;
  }

  Student toStudent(String docId, {Student? existing}) {
    return Student(
      id: docId,
      name: nameModel.inputTextController?.text ?? '',
      studentId: studentIdModel.inputTextController?.text ?? '',
      rollNo: rollNoModel.inputTextController?.text ?? '',
      className: selectedClass ?? '',
      section: sectionModel.inputTextController?.text,
      gender: genderModel.inputTextController?.text,
      dob: dobModel.inputTextController?.text,
      parentName: parentNameModel.inputTextController?.text,
      parentPhone: parentPhoneModel.inputTextController?.text,
      altPhone: altPhoneModel.inputTextController?.text,
      email: emailModel.inputTextController?.text,
      villageCity: villageCityModel.inputTextController?.text,
      address: addressModel.inputTextController?.text,
      pinCode: pinCodeModel.inputTextController?.text,
      admissionDate: admissionDateModel.inputTextController?.text,
      batch: batchModel.inputTextController?.text,
      subjects: subjectsModel.inputTextController?.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      feesStatus: feesStatusModel.inputTextController?.text,
      notes: notesModel.inputTextController?.text,
      photoUrl: photoUrl,
    );
  }

  @override
  void dispose() {
    headerSectionModel.dispose();
    nameModel.dispose();
    studentIdModel.dispose();
    rollNoModel.dispose();
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
