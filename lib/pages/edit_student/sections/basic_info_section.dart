import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/drop_down/drop_down_widget.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/backend/services/app_constants.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/core/utils/responsive_utils.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/edit_student_model.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.model,
    required this.isAdmin,
    required this.onChanged,
  });

  final EditStudentModel model;
  final bool isAdmin;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        wrapWithModel(
          model: model.nameModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Full Name',
            hint: 'Enter student name',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ResponsiveUtils.responsiveRow(context, [
          wrapWithModel(
            model: model.studentIdModel,
            updateCallback: onChanged,
            child: TextFieldWidget(
              label: 'Student ID',
              hint: 'e.g. DCI-001',
              variant: 'outlined',
              readOnly: !isAdmin,
            ),
          ),
          wrapWithModel(
            model: model.rollNoModel,
            updateCallback: onChanged,
            child: const TextFieldWidget(
              label: 'Roll No',
              hint: 'e.g. 1',
              variant: 'outlined',
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        ResponsiveUtils.responsiveRow(context, [
          DropDownWidget(
            label: 'Class',
            controller: model.classDropdownController!,
            options: AppConstants.classOptions,
            onChanged: (val) {
              model.selectedClass = val;
              onChanged();
            },
            hint: 'Select Class',
          ),
          wrapWithModel(
            model: model.sectionModel,
            updateCallback: onChanged,
            child: const TextFieldWidget(
              label: 'Section',
              hint: 'e.g. A',
              variant: 'outlined',
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        ResponsiveUtils.responsiveRow(context, [
          wrapWithModel(
            model: model.genderModel,
            updateCallback: onChanged,
            child: const TextFieldWidget(
              label: 'Gender',
              hint: 'Male/Female',
              variant: 'outlined',
            ),
          ),
          wrapWithModel(
            model: model.dobModel,
            updateCallback: onChanged,
            child: const TextFieldWidget(
              label: 'Date of Birth',
              hint: 'DD/MM/YYYY',
              variant: 'outlined',
            ),
          ),
        ]),
      ],
    );
  }
}
