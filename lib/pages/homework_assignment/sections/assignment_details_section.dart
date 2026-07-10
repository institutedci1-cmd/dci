import 'package:flutter/material.dart';
import '../../../../shared/app_style.dart';
import '../../../../components/shared/app_card.dart';
import '../../../../components/shared/app_text_field.dart';
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
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            label: 'Assignment Title',
            hintText: 'e.g. Quadratic Equations Practice',
            controller: model.textFieldModel1.inputTextController,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Description',
            hintText: 'Describe the tasks or questions for students...',
            controller: model.textFieldModel2.inputTextController,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
