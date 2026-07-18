import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/form_label/form_label_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '../homework_assignment_model.dart';

class AssignmentDetailsSection extends StatelessWidget {
  const AssignmentDetailsSection({
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
        wrapWithModel(
          model: model.formLabelModel3,
          updateCallback: onChanged,
          child: const FormLabelWidget(label: 'Assignment Details'),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              wrapWithModel(
                model: model.textFieldModel1,
                updateCallback: onChanged,
                child: TextFieldWidget(
                  controller: model.textFieldModel1.inputTextController,
                  focusNode: model.textFieldModel1.inputFocusNode,
                  label: 'Homework Title',
                  labelPresent: true,
                  hint: 'e.g. Quadratic Equations Practice',
                  variant: 'ghost',
                ),
              ),
              Divider(height: 16.0, color: FlutterFlowTheme.of(context).alternate),
              wrapWithModel(
                model: model.textFieldModel2,
                updateCallback: onChanged,
                child: TextFieldWidget(
                  controller: model.textFieldModel2.inputTextController,
                  focusNode: model.textFieldModel2.inputFocusNode,
                  label: 'Description',
                  labelPresent: true,
                  hint: 'Describe the tasks or questions...',
                  variant: 'ghost',
                ),
              ),
            ].divide(const SizedBox(height: 16.0)),
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
    );
  }
}
