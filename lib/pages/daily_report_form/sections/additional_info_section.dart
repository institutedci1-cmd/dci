import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/form_section_header/form_section_header_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/daily_report_form_model.dart';

class AdditionalInfoSection extends StatelessWidget {
  const AdditionalInfoSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final DailyReportFormModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapWithModel(
          model: model.formSectionHeaderModel4,
          updateCallback: onChanged,
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.assignment_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Additional Info',
          ),
        ),
        wrapWithModel(
          model: model.textFieldModel5,
          updateCallback: onChanged,
          child: TextFieldWidget(
            controller: model.textFieldModel5.inputTextController,
            focusNode: model.textFieldModel5.inputFocusNode,
            label: 'Homework Assigned',
            labelPresent: true,
            leadingIcon: Icon(
              Icons.edit_note_rounded,
              size: 20.0,
              color: FlutterFlowTheme.of(context).primary,
            ),
            leadingIconPresent: true,
            hint: 'Describe the homework...',
            variant: 'outlined',
          ),
        ),
        wrapWithModel(
          model: model.textFieldModel6,
          updateCallback: onChanged,
          child: TextFieldWidget(
            controller: model.textFieldModel6.inputTextController,
            focusNode: model.textFieldModel6.inputFocusNode,
            label: 'Remarks',
            labelPresent: true,
            leadingIcon: Icon(
              Icons.notes_rounded,
              size: 20.0,
              color: FlutterFlowTheme.of(context).primary,
            ),
            leadingIconPresent: true,
            hint: 'Any other observations...',
            variant: 'outlined',
          ),
        ),
      ].divide(const SizedBox(height: 12.0)),
    );
  }
}
