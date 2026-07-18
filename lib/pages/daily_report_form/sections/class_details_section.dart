import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/components/form_section_header/form_section_header_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '../daily_report_form_model.dart';

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
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: _buildDropDownField(
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
            ),
            Expanded(
              flex: 1,
              child: _buildDropDownField(
                context,
                label: 'Subject',
                hint: 'Select Subject',
                icon: Icons.menu_book_rounded,
                options: model.subjectOptions,
                initialValue: model.dropdownValue2,
                onChanged: (val) {
                  model.dropdownValue2 = val;
                  onChanged();
                },
                controller: model.dropdownValueController2,
              ),
            ),
          ].divide(const SizedBox(width: 16.0)),
        ),
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
            leadingIcon: const Icon(
              Icons.bookmark_rounded,
              size: 24.0,
            ),
            leadingIconPresent: true,
            hint: 'Enter chapter name',
            variant: 'outlined',
          ),
        ),
      ].divide(const SizedBox(height: 16.0)),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: FlutterFlowTheme.of(context).labelMedium),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: FlutterFlowDropDown<String>(
            controller: controller!,
            options: options,
            onChanged: onChanged,
            width: fullWidth ? double.infinity : 200.0,
            height: 40.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            hintText: hint,
            icon: Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
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
