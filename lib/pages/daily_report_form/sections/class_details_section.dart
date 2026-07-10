import 'package:flutter/material.dart';
import '/backend/services/app_constants.dart';
import '../../../../shared/app_style.dart';
import '../../../../components/shared/app_dropdown.dart';
import '../../../../components/shared/app_text_field.dart';
import '../../../../components/shared/app_card.dart';
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppDropdown(
                  label: 'Class',
                  hintText: 'Select Class',
                  options: AppConstants.classOptions,
                  controller: model.dropdownValueController1,
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
                  controller: model.dropdownValueController2,
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
            controller: model.dropdownValueController3,
            onChanged: (val) {
              model.dropdownValue3 = val;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Chapter / Topic',
            hintText: 'Enter lesson topic',
            controller: model.textFieldModel3.inputTextController,
            prefixIcon: Icons.bookmark_outline_rounded,
          ),
        ],
      ),
    );
  }
}
