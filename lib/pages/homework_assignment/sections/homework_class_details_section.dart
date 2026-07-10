import 'package:flutter/material.dart';
import '/backend/services/app_constants.dart';
import '../../../../shared/app_style.dart';
import '../../../../components/shared/app_dropdown.dart';
import '../../../../components/shared/app_card.dart';
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
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppDropdown(
                  label: 'Class',
                  hintText: 'Select Class',
                  options: AppConstants.classOptions,
                  value: model.dropdownValue1,
                  onChanged: (val) {
                    model.dropdownValue1 = val;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppDropdown(
                  label: 'Subject',
                  hintText: 'Select Subject',
                  options: AppConstants.subjectOptions,
                  value: model.dropdownValue2,
                  onChanged: (val) {
                    model.dropdownValue2 = val;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown(
            label: 'Teacher',
            hintText: 'Select Teacher',
            options: AppConstants.teacherOptions,
            value: model.dropdownValue3,
            onChanged: (val) {
              model.dropdownValue3 = val;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
