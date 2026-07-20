import 'package:flutter/material.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/edit_student_model.dart';

class AcademicInfoSection extends StatelessWidget {
  const AcademicInfoSection({
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
        Row(
          children: [
            Expanded(
              child: wrapWithModel(
                model: model.admissionDateModel,
                updateCallback: onChanged,
                child: const TextFieldWidget(
                  label: 'Admission Date',
                  hint: 'DD/MM/YYYY',
                  variant: 'outlined',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: wrapWithModel(
                model: model.batchModel,
                updateCallback: onChanged,
                child: const TextFieldWidget(
                  label: 'Batch',
                  hint: 'e.g. 2024-25',
                  variant: 'outlined',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: model.subjectsModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Subjects',
            hint: 'Math, Science, etc. (Comma separated)',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: model.feesStatusModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Fees Status',
            hint: 'Paid/Pending/Partial',
            variant: 'outlined',
          ),
        ),
        const SizedBox(height: 12),
        wrapWithModel(
          model: model.notesModel,
          updateCallback: onChanged,
          child: const TextFieldWidget(
            label: 'Additional Notes',
            hint: 'Health issues, interests, etc.',
            variant: 'outlined',
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
