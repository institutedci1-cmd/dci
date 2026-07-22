import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/pages/homework_assignment/homework_assignment_model.dart';

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
          model: model.textFieldModel1,
          updateCallback: onChanged,
          child: TextFieldWidget(
            controller: model.textFieldModel1.inputTextController,
            focusNode: model.textFieldModel1.inputFocusNode,
            label: 'Homework Title',
            labelPresent: true,
            hint: 'e.g. Quadratic Equations Practice',
            variant: 'outlined',
          ),
        ),
        wrapWithModel(
          model: model.textFieldModel2,
          updateCallback: onChanged,
          child: TextFieldWidget(
            controller: model.textFieldModel2.inputTextController,
            focusNode: model.textFieldModel2.inputFocusNode,
            label: 'Description',
            labelPresent: true,
            hint: 'Describe the tasks or questions...',
            variant: 'outlined',
            maxLines: 4,
          ),
        ),
      ].divide(const SizedBox(height: 12.0)),
    );
  }
}
