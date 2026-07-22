import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/flutter_flow/form_field_controller.dart';
import 'package:d_c_i_teacher_app/components/form_section_header/form_section_header_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/core/utils/responsive_utils.dart';
import 'package:d_c_i_teacher_app/pages/daily_report_form/daily_report_form_model.dart';

class ClassDetailsSection extends StatelessWidget {
  const ClassDetailsSection({
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
          model: model.formSectionHeaderModel1,
          updateCallback: onChanged,
          child: FormSectionHeaderWidget(
            icon: Icon(
              Icons.school_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            title: 'Class Details',
          ),
        ),
        ResponsiveUtils.responsiveRow(context, [
          _buildDropDownField(
            context,
            label: 'Class',
            hint: 'Select Class',
            options: model.classOptions,
            initialValue: model.dropdownValue1,
            onChanged: (val) {
              model.dropdownValue1 = val;
              onChanged();
            },
            controller: model.dropdownValueController1,
          ),
          _buildDropDownField(
            context,
            label: 'Subject',
            hint: 'Select Subject',
            options: model.subjectOptions,
            initialValue: model.dropdownValue2,
            onChanged: (val) {
              model.dropdownValue2 = val;
              onChanged();
            },
            controller: model.dropdownValueController2,
          ),
        ]),
        _buildDropDownField(
          context,
          label: 'Teacher',
          hint: 'Select Teacher',
          icon: Icons.person_rounded,
          options: model.teacherOptions,
          initialValue: model.dropdownValue3,
          onChanged: (val) {
            model.dropdownValue3 = val;
            onChanged();
          },
          controller: model.dropdownValueController3,
          fullWidth: true,
        ),
        wrapWithModel(
          model: model.textFieldModel3,
          updateCallback: onChanged,
          child: TextFieldWidget(
            controller: model.textFieldModel3.inputTextController,
            focusNode: model.textFieldModel3.inputFocusNode,
            label: 'Chapter',
            labelPresent: true,
            leadingIcon: Icon(
              Icons.bookmark_rounded,
              size: 20.0,
              color: FlutterFlowTheme.of(context).primary,
            ),
            leadingIconPresent: true,
            hint: 'Enter chapter name',
            variant: 'outlined',
          ),
        ),
      ].divide(const SizedBox(height: 12.0)),
    );
  }

  Widget _buildDropDownField(
    BuildContext context, {
    required String label,
    required String hint,
    required List<String> options,
    required String? initialValue,
    required Function(String?) onChanged,
    FormFieldController<String>? controller,
    IconData icon = Icons.arrow_drop_down_rounded,
    bool fullWidth = false,
  }) {
    return DropDownWidget(
      label: label,
      hint: hint,
      options: options,
      controller: controller,
      onChanged: onChanged,
      fullWidth: fullWidth,
      icon: Icon(icon, color: AppColors.textSecondary, size: 24),
    );
  }
}
