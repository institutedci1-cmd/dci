import 'package:flutter/material.dart';
import '/backend/services/app_constants.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/components/form_label/form_label_widget.dart';
import '../homework_assignment_model.dart';

class HomeworkClassDetailsSection extends StatelessWidget {
  const HomeworkClassDetailsSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final HomeworkAssignmentModel model;
  final VoidCallback onChanged;

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
          initialValue: model.dropdownValue1 ?? AppConstants.classOptions.last,
          options: AppConstants.classOptions,
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
          initialValue: model.dropdownValue2 ?? AppConstants.subjectOptions.first,
          options: AppConstants.subjectOptions,
          controller: model.dropdownValueController2,
          icon: Icons.menu_book_rounded,
          onChanged: (val) {
            model.dropdownValue2 = val;
            onChanged();
          },
        ),
        _buildLabeledDropDown(
          context,
          model: null, // Model logic could be improved here
          label: 'Assigned By (Teacher)',
          initialValue: model.dropdownValue3 ?? AppConstants.teacherOptions.first,
          options: AppConstants.teacherOptions,
          controller: model.dropdownValueController3,
          icon: Icons.person_rounded,
          onChanged: (val) {
            model.dropdownValue3 = val;
            onChanged();
          },
        ),
      ].divide(const SizedBox(height: 16.0)),
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
          padding: const EdgeInsets.all(16.0),
          child: FlutterFlowDropDown<String>(
            controller: controller ??= FormFieldController<String>(initialValue),
            options: options,
            onChanged: onChanged,
            width: 200.0,
            height: 40.0,
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
