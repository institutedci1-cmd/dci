import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/edit_student_model.dart';

class ParentInfoSection extends StatelessWidget {
  const ParentInfoSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  final EditStudentModel model;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        wrapWithModel(
          model: model.parentNameModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Parent Name',
            hint: 'Father/Mother/Guardian name',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: model.parentPhoneModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Parent Phone',
            hint: '10-digit number',
            variant: 'outlined',
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: model.altPhoneModel,
                updateCallback: onChanged,
                child: const TextFieldWidget(
                  label: 'Alternate Phone',
                  hint: 'Optional',
                  variant: 'outlined',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: wrapWithModel(
                model: model.emailModel,
                updateCallback: onChanged,
                child: const TextFieldWidget(
                  label: 'Email Address',
                  hint: 'Optional',
                  variant: 'outlined',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
