import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_drop_down.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/components/form_label/form_label_widget.dart';
import 'package:d_c_i_teacher_app/pages/homework_assignment/homework_assignment_model.dart';

class HomeworkClassDetailsSection extends StatelessWidget {
  const HomeworkClassDetailsSection({
    super.key,
    required this.model,
    required this.onChanged,
    required this.classOptions,
    required this.subjectOptions,
    required this.teacherOptions,
  });

  final HomeworkAssignmentModel model;
  final VoidCallback onChanged;
  final List<String> classOptions;
  final List<String> subjectOptions;
  final List<String> teacherOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabeledDropDown(
          context,
          model: model.formLabelModel1,
          label: 'Select Class',
          initialValue: model.dropdownValue1 ?? (classOptions.isNotEmpty ? classOptions.last : ''),
          options: classOptions.isEmpty ? ['No Classes'] : classOptions,
          controller: model.dropdownValueController1,
          onChanged: (val) {
            model.dropdownValue1 = val;
            onChanged();
          },
        ),
        _buildLabeledDropDown(
          context,
          model: model.formLabelModel2,
          label: 'Subject',
          initialValue: model.dropdownValue2 ?? (subjectOptions.isNotEmpty ? subjectOptions.first : ''),
          options: subjectOptions.isEmpty ? ['No Subjects'] : subjectOptions,
          controller: model.dropdownValueController2,
          icon: Icons.menu_book_rounded,
          onChanged: (val) {
            model.dropdownValue2 = val;
            onChanged();
          },
        ),
        _buildLabeledDropDown(
          context,
          model: null,
          label: 'Assigned By (Teacher)',
          initialValue: model.dropdownValue3 ?? (teacherOptions.isNotEmpty ? teacherOptions.first : ''),
          options: teacherOptions.isEmpty ? ['No Teachers'] : teacherOptions,
          controller: model.dropdownValueController3,
          icon: Icons.person_rounded,
          onChanged: (val) {
            model.dropdownValue3 = val;
            onChanged();
          },
        ),
      ].divide(const SizedBox(height: 12.0)),
    );
  }

  Widget _buildLabeledDropDown(
    BuildContext context, {
    required String label,
    required String initialValue,
    required List<String> options,
    required Function(String?) onChanged,
    required FormFieldController<String>? controller,
    FlutterFlowModel? model,
    IconData icon = Icons.arrow_drop_down_rounded,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (model != null)
          wrapWithModel(
            model: model,
            updateCallback: () => onChanged(initialValue),
            child: FormLabelWidget(label: label),
          )
        else
          FormLabelWidget(label: label),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FlutterFlowDropDown<String>(
            controller: controller!,
            options: options,
            onChanged: onChanged,
            width: double.infinity,
            height: 48.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            hintText: 'Choose...',
            icon: Icon(icon, color: FlutterFlowTheme.of(context).secondaryText, size: 24.0),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 1.0,
            borderRadius: 12.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            hidesUnderline: true,
          ),
        ),
      ],
    );
  }
}
